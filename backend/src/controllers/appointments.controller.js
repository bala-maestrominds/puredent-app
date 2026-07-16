import { appointmentsService } from '../services/appointments.service.js';

async function create(req, res) {
  const { appointment, qrCodeDataUrl, emailSent } = await appointmentsService.createAppointment(
    req.body,
    req.user?.id || null
  );
  res.status(201).json({
    data: {
      appointment,
      qrCodeDataUrl,
      emailSent,
    },
  });
}

async function listMine(req, res) {
  const appointments = await appointmentsService.listAppointmentsByUser(req.user.id);
  res.json({ data: appointments });
}

async function list(req, res) {
  const { status, date, search, doctorId } = req.query;
  const appointments = await appointmentsService.listAppointments({ status, date, search, doctorId });
  res.json({ data: appointments });
}

async function getById(req, res) {
  const appointment = await appointmentsService.getAppointmentById(req.params.id);
  res.json({ data: appointment });
}

async function updateStatus(req, res) {
  const appointment = await appointmentsService.updateAppointmentStatus(req.params.id, req.body.status);
  res.json({ data: appointment });
}

async function verify(req, res) {
  const appointment = await appointmentsService.verifyAppointment(req.body);
  res.json({ data: appointment });
}

async function checkIn(req, res) {
  const appointment = await appointmentsService.checkInAppointment(req.params.id);
  res.json({ data: appointment });
}

async function downloadPdf(req, res) {
  const { buffer, appointment } = await appointmentsService.getAppointmentPdf(req.params.id);
  res.set({
    'Content-Type': 'application/pdf',
    'Content-Disposition': `inline; filename="${appointment.appointmentCode}-ticket.pdf"`,
    'Content-Length': buffer.length,
  });
  res.send(buffer);
}

async function reschedule(req, res) {
  const appointment = await appointmentsService.rescheduleAppointment(req.params.id, req.body, req.user);
  res.json({ data: appointment });
}

async function cancel(req, res) {
  const appointment = await appointmentsService.cancelAppointment(req.params.id, req.body, req.user);
  res.json({ data: appointment });
}

async function payBalance(req, res) {
  const appointment = await appointmentsService.payBalance(req.params.id, req.body, req.user);
  res.json({ data: appointment });
}

async function updatePayment(req, res) {
  const appointment = await appointmentsService.updateAppointmentPayment(req.params.id, req.body);
  res.json({ data: appointment });
}

export const appointmentsController = {
  create,
  list,
  listMine,
  getById,
  updateStatus,
  verify,
  checkIn,
  downloadPdf,
  reschedule,
  cancel,
  payBalance,
  updatePayment,
};