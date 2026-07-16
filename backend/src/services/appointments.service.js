import { Appointment } from '../models/appointments.model.js';
import { Doctor } from '../models/doctors.model.js';
import { Service } from '../models/services.model.js';
import { ApiError } from '../utils/ApiError.js';
import {
  generateAppointmentCode,
  signAppointmentCode,
  verifyAppointmentToken,
  generateQrDataUrl,
  generateAppointmentPdf,
} from '../utils/appointmentTicket.js';
import { createTransporter, buildAppointmentEmail } from '../utils/mailer.js';

// The consultation fee is a flat, site-wide amount (not per-doctor/service).
// When a patient pays "Consultation Fee Only", this is what's collected now,
// and it's deducted from the total treatment cost to arrive at the balance
// due after check-in.
export const CONSULTATION_FEE = 100;

async function createUniqueCode() {
  for (let attempt = 0; attempt < 5; attempt += 1) {
    const code = generateAppointmentCode();
    // eslint-disable-next-line no-await-in-loop
    const existing = await Appointment.exists({ appointmentCode: code });
    if (!existing) return code;
  }
  throw new ApiError(500, 'Could not generate a unique booking code, please try again.');
}

async function assertSlotIsFree(doctorId, date, time, excludeId = null) {
  const query = {
    doctor: doctorId,
    date,
    time,
    status: { $ne: 'Cancelled' },
  };
  if (excludeId) query._id = { $ne: excludeId };

  const clash = await Appointment.findOne(query);
  if (clash) {
    throw new ApiError(409, 'This time slot has just been booked. Please choose another slot.');
  }
}

async function createAppointment(payload, userId = null) {
  const { doctorId, serviceId, date, time } = payload;

  const [doctor, service] = await Promise.all([
    Doctor.findById(doctorId),
    Service.findById(serviceId),
  ]);

  if (!doctor || !doctor.isActive) throw new ApiError(404, 'Selected doctor is not available.');
  if (!service) throw new ApiError(404, 'Selected service was not found.');

  await assertSlotIsFree(doctorId, date, time);

  const appointmentCode = await createUniqueCode();
  const verificationToken = signAppointmentCode(appointmentCode);

  // --- Payment breakdown -----------------------------------------------
  // The patient can either settle the full treatment cost now, or pay just
  // the doctor's consultation fee and clear the remaining balance after
  // the treatment (tracked via `balanceDue` for the admin dashboard).
  const totalAmount = service.priceFrom || 0;
  const consultationFee = Math.min(CONSULTATION_FEE, totalAmount);
  const paymentOption = payload.paymentOption || 'Full Payment';
  const collectibleNow = paymentOption === 'Consultation Fee Only'
    ? Math.min(consultationFee, totalAmount)
    : totalAmount;

  // No real payment gateway is wired up yet -- appointments booked with "Pay at
  // Clinic" stay pending, other methods are treated as paid at booking time
  // (for whichever portion -- full or consultation-only -- was selected).
  const isPaidUpfront = Boolean(payload.paymentMethod) && payload.paymentMethod !== 'Pay at Clinic';
  const amountPaid = isPaidUpfront ? collectibleNow : 0;
  const balanceDue = Math.max(totalAmount - amountPaid, 0);
  let paymentStatus = 'pending';
  if (amountPaid > 0) {
    paymentStatus = balanceDue <= 0 ? 'paid' : 'partially_paid';
  }

  const appointment = await Appointment.create({
    user: userId || null,
    appointmentCode,
    verificationToken,
    doctor: doctor._id,
    doctorName: doctor.name,
    doctorSpecialty: doctor.specialty,
    service: service._id,
    serviceName: service.name,
    servicePrice: service.priceFrom || 0,
    serviceDurationMinutes: service.durationMinutes || 30,
    date,
    time,
    patientName: payload.patientName.trim(),
    patientEmail: payload.patientEmail.trim().toLowerCase(),
    patientPhone: payload.patientPhone.trim(),
    patientAge: payload.patientAge ?? null,
    patientGender: payload.patientGender || '',
    notes: payload.notes?.trim() || '',
    paymentMethod: payload.paymentMethod || 'Pay at Clinic',
    paymentOption,
    consultationFee,
    amount: totalAmount,
    amountPaid,
    balanceDue,
    paymentStatus,
  });

  const qrCodeDataUrl = await generateQrDataUrl(appointment);

  // Email delivery must never block/fail the booking itself -- if SMTP isn't
  // configured or the send fails, the appointment is still confirmed and the
  // patient can still view/download the ticket from the confirmation screen.
  let emailSent = false;
  try {
    await sendAppointmentEmail(appointment);
    emailSent = true;
    appointment.emailSent = true;
    appointment.emailSentAt = new Date();
    await appointment.save();
  } catch (err) {
    console.error('[appointments] failed to send confirmation email:', err.message);
  }

  return { appointment, qrCodeDataUrl, emailSent };
}

async function listAppointmentsByUser(userId) {
  return Appointment.find({ user: userId }).sort({ createdAt: -1 });
}

async function sendAppointmentEmail(appointment) {
  const transporter = createTransporter();
  const { subject, text, html } = buildAppointmentEmail(appointment);
  const pdfBuffer = await generateAppointmentPdf(appointment);

  await transporter.sendMail({
    from: `"PureDent Clinic" <${process.env.GMAIL_USER}>`,
    to: appointment.patientEmail,
    replyTo: process.env.ADMIN_EMAIL || process.env.GMAIL_USER,
    subject,
    text,
    html,
    attachments: [
      {
        filename: `${appointment.appointmentCode}-ticket.pdf`,
        content: pdfBuffer,
        contentType: 'application/pdf',
      },
    ],
  });
}

async function getAppointmentById(id) {
  const appointment = await Appointment.findById(id);
  if (!appointment) throw new ApiError(404, 'Appointment not found');
  return appointment;
}

async function listAppointments({ status, date, search, doctorId } = {}) {
  const query = {};
  if (status && status !== 'All') query.status = status;
  if (date) query.date = date;
  if (doctorId) query.doctor = doctorId;
  if (search) {
    const re = new RegExp(search.trim(), 'i');
    query.$or = [{ patientName: re }, { doctorName: re }, { appointmentCode: re }, { patientEmail: re }];
  }
  return Appointment.find(query).sort({ createdAt: -1 });
}

async function updateAppointmentStatus(id, status) {
  const appointment = await Appointment.findByIdAndUpdate(id, { status }, { new: true, runValidators: true });
  if (!appointment) throw new ApiError(404, 'Appointment not found');
  return appointment;
}

async function verifyAppointment({ code, token }) {
  const appointment = await Appointment.findOne({ appointmentCode: code.trim().toUpperCase() });
  if (!appointment) throw new ApiError(404, 'No appointment found for this QR code.');

  const isValid = verifyAppointmentToken(appointment.appointmentCode, token);
  if (!isValid) throw new ApiError(400, 'This QR code could not be verified.');

  if (appointment.status === 'Cancelled') {
    throw new ApiError(400, 'This appointment has been cancelled.');
  }

  return appointment;
}

async function checkInAppointment(id) {
  const appointment = await Appointment.findById(id);
  if (!appointment) throw new ApiError(404, 'Appointment not found');

  if (appointment.status === 'Cancelled') {
    throw new ApiError(400, 'This appointment has been cancelled.');
  }
  if (appointment.checkInStatus === 'checked_in') {
    throw new ApiError(409, `Patient already checked in at ${appointment.checkedInAt.toLocaleString()}.`);
  }

  appointment.checkInStatus = 'checked_in';
  appointment.checkedInAt = new Date();
  if (appointment.status === 'Confirmed' || appointment.status === 'Pending') {
    appointment.status = 'In-Progress';
  }
  await appointment.save();
  return appointment;
}

async function getAppointmentPdf(id) {
  const appointment = await getAppointmentById(id);
  const buffer = await generateAppointmentPdf(appointment);
  return { buffer, appointment };
}

// Ensures the requesting user is either the appointment's owner or an admin.
function assertCanManage(appointment, requester) {
  if (!requester) return; // internal/reception usage (no logged-in patient context)
  if (requester.role === 'admin') return;
  if (!appointment.user || appointment.user.toString() !== requester.id) {
    throw new ApiError(403, 'You do not have permission to manage this appointment.');
  }
}

async function rescheduleAppointment(id, { date, time }, requester = null) {
  const appointment = await Appointment.findById(id);
  if (!appointment) throw new ApiError(404, 'Appointment not found');

  assertCanManage(appointment, requester);

  if (appointment.status === 'Cancelled') {
    throw new ApiError(400, 'A cancelled appointment cannot be rescheduled.');
  }
  if (appointment.status === 'Completed') {
    throw new ApiError(400, 'A completed appointment cannot be rescheduled.');
  }

  await assertSlotIsFree(appointment.doctor, date, time, appointment._id);

  if (!appointment.originalDate) {
    appointment.originalDate = appointment.date;
    appointment.originalTime = appointment.time;
  }

  appointment.date = date;
  appointment.time = time;
  appointment.status = 'Confirmed';
  appointment.checkInStatus = 'not_arrived';
  appointment.checkedInAt = null;
  appointment.rescheduleCount += 1;
  appointment.lastRescheduledAt = new Date();

  await appointment.save();
  return appointment;
}

async function cancelAppointment(id, { reason } = {}, requester = null) {
  const appointment = await Appointment.findById(id);
  if (!appointment) throw new ApiError(404, 'Appointment not found');

  assertCanManage(appointment, requester);

  if (appointment.status === 'Cancelled') {
    throw new ApiError(400, 'This appointment is already cancelled.');
  }
  if (appointment.status === 'Completed') {
    throw new ApiError(400, 'A completed appointment cannot be cancelled.');
  }

  appointment.status = 'Cancelled';
  appointment.cancelledAt = new Date();
  appointment.cancellationReason = reason || '';
  appointment.cancelledBy = requester && requester.role !== 'admin' ? 'patient' : 'clinic';

  await appointment.save();
  return appointment;
}

// Patient-facing: pay the outstanding balance online from the app (e.g. the
// full treatment cost, or the remainder left after an earlier
// consultation-fee-only payment). No real payment gateway is wired up yet,
// so the "charge" is treated as successful immediately and the appointment
// is updated/persisted right away -- this is what feeds the admin revenue
// dashboard (which sums `amountPaid`).
async function payBalance(id, { paymentMethod } = {}, requester = null) {
  const appointment = await Appointment.findById(id);
  if (!appointment) throw new ApiError(404, 'Appointment not found');

  assertCanManage(appointment, requester);

  if (appointment.status === 'Cancelled') {
    throw new ApiError(400, 'This appointment has been cancelled.');
  }
  if (appointment.balanceDue <= 0) {
    throw new ApiError(400, 'There is no outstanding balance for this appointment.');
  }

  appointment.amountPaid = appointment.amount || 0;
  appointment.balanceDue = 0;
  appointment.paymentStatus = 'paid';
  if (paymentMethod) appointment.paymentMethod = paymentMethod;

  await appointment.save();
  return appointment;
}

// Admin-facing: reconcile the amount actually collected (e.g. once the
// remaining balance is settled at/after the visit).
async function updateAppointmentPayment(id, { paymentStatus, amountPaid }) {
  const appointment = await Appointment.findById(id);
  if (!appointment) throw new ApiError(404, 'Appointment not found');

  if (amountPaid !== undefined) {
    appointment.amountPaid = amountPaid;
    appointment.balanceDue = Math.max((appointment.amount || 0) - amountPaid, 0);
    if (paymentStatus === undefined) {
      appointment.paymentStatus = appointment.balanceDue <= 0
        ? 'paid'
        : (appointment.amountPaid > 0 ? 'partially_paid' : 'pending');
    }
  }
  if (paymentStatus !== undefined) {
    appointment.paymentStatus = paymentStatus;
    if (paymentStatus === 'paid') {
      appointment.amountPaid = appointment.amount || 0;
      appointment.balanceDue = 0;
    }
  }

  await appointment.save();
  return appointment;
}

export const appointmentsService = {
  createAppointment,
  getAppointmentById,
  listAppointments,
  listAppointmentsByUser,
  updateAppointmentStatus,
  verifyAppointment,
  checkInAppointment,
  getAppointmentPdf,
  rescheduleAppointment,
  cancelAppointment,
  payBalance,
  updateAppointmentPayment,
};