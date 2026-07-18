import mongoose from 'mongoose';

const appointmentSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null, index: true },
    appointmentCode: { type: String, required: true, unique: true, index: true },
    verificationToken: { type: String, required: true },
    doctor: { type: mongoose.Schema.Types.ObjectId, ref: 'Doctor', required: true },
    doctorName: { type: String, required: true },
    doctorSpecialty: { type: String, default: '' },
    service: { type: mongoose.Schema.Types.ObjectId, ref: 'Service', required: true },
    serviceName: { type: String, required: true },
    servicePrice: { type: Number, default: 0 },
    serviceDurationMinutes: { type: Number, default: 30 },
    date: { type: String, required: true }, // "YYYY-MM-DD"
    time: { type: String, required: true }, // "HH:mm"
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
    paymentOption: {
      type: String,
      enum: ['Full Payment', 'Consultation Fee Only'],
      default: 'Full Payment',
    },
    consultationFee: { type: Number, default: 0 },
    amount: { type: Number, default: 0 },
    amountPaid: { type: Number, default: 0 },
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
    rescheduleCount: { type: Number, default: 0 },
    originalDate: { type: String, default: null },
    originalTime: { type: String, default: null },
    lastRescheduledAt: { type: Date, default: null },
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