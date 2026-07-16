import mongoose from 'mongoose';

const appointmentSchema = new mongoose.Schema(
  {
    // Optional link to the authenticated patient account that made this booking.
    // Guest bookings (no account) leave this null.
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null, index: true },

    // Human-friendly booking reference shown on the ticket/PDF and used for QR verification.
    appointmentCode: { type: String, required: true, unique: true, index: true },

    // HMAC token embedded in the QR code so the reception desk can verify authenticity
    // without trusting a bare, guessable ID.
    verificationToken: { type: String, required: true },

    // Snapshot of doctor/service at booking time so the ticket stays accurate
    // even if the doctor/service record changes later.
    doctor: { type: mongoose.Schema.Types.ObjectId, ref: 'Doctor', required: true },
    doctorName: { type: String, required: true },
    doctorSpecialty: { type: String, default: '' },

    service: { type: mongoose.Schema.Types.ObjectId, ref: 'Service', required: true },
    serviceName: { type: String, required: true },
    servicePrice: { type: Number, default: 0 },
    serviceDurationMinutes: { type: Number, default: 30 },

    date: { type: String, required: true }, // "YYYY-MM-DD"
    time: { type: String, required: true }, // "HH:mm"

    // Patient details collected on the booking form.
    patientName: { type: String, required: true, trim: true },
    patientEmail: { type: String, required: true, trim: true, lowercase: true },
    patientPhone: { type: String, required: true, trim: true },
    patientAge: { type: Number, default: null },
    patientGender: { type: String, enum: ['Male', 'Female', 'Other', ''], default: '' },
    notes: { type: String, default: '' },

    paymentMethod: {
      type: String,
      enum: ['Card', 'PayPal', 'Razorpay', 'Pay at Clinic'],
      default: 'Pay at Clinic',
    },

    // Whether the patient chose to settle the full treatment cost at booking
    // time, or just the doctor's consultation fee (with the remainder due
    // after treatment, tracked as `balanceDue` below).
    paymentOption: {
      type: String,
      enum: ['Full Payment', 'Consultation Fee Only'],
      default: 'Full Payment',
    },

    // Snapshot of the doctor's consultation fee at booking time, used when
    // paymentOption is 'Consultation Fee Only'.
    consultationFee: { type: Number, default: 0 },

    // Full treatment/service cost (kept in sync with servicePrice).
    amount: { type: Number, default: 0 },
    // Amount actually collected from the patient so far.
    amountPaid: { type: Number, default: 0 },
    // Remaining amount owed (amount - amountPaid), settled at/after treatment.
    balanceDue: { type: Number, default: 0 },

    paymentStatus: {
      type: String,
      enum: ['pending', 'partially_paid', 'paid'],
      default: 'pending',
    },

    status: {
      type: String,
      enum: ['Confirmed', 'Pending', 'In-Progress', 'Completed', 'Cancelled'],
      default: 'Confirmed',
    },

    checkInStatus: { type: String, enum: ['not_arrived', 'checked_in'], default: 'not_arrived' },
    checkedInAt: { type: Date, default: null },

    // Reschedule tracking -- original slot is preserved the first time the
    // appointment is moved, so the history isn't lost on repeated reschedules.
    rescheduleCount: { type: Number, default: 0 },
    originalDate: { type: String, default: null },
    originalTime: { type: String, default: null },
    lastRescheduledAt: { type: Date, default: null },

    // Cancellation tracking.
    cancelledAt: { type: Date, default: null },
    cancellationReason: { type: String, default: '' },
    cancelledBy: { type: String, enum: ['patient', 'clinic', null], default: null },

    emailSent: { type: Boolean, default: false },
    emailSentAt: { type: Date, default: null },
  },
  { timestamps: true }
);

appointmentSchema.index({ doctor: 1, date: 1, time: 1 });
appointmentSchema.index({ patientEmail: 1 });

export const Appointment = mongoose.model('Appointment', appointmentSchema);