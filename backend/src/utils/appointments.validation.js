import { z } from 'zod';

const objectId = z.string().length(24, 'invalid id');

export const createAppointmentSchema = z.object({
  doctorId: objectId,
  serviceId: objectId,
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'date must be YYYY-MM-DD'),
  time: z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/, 'time must be HH:mm'),

  patientName: z.string().min(2).max(120),
  patientEmail: z.string().email(),
  patientPhone: z.string().min(6).max(20),
  patientAge: z.coerce.number().int().min(0).max(130).optional(),
  patientGender: z.enum(['Male', 'Female', 'Other']).optional(),
  notes: z.string().max(1000).optional().default(''),

  paymentMethod: z.enum(['Card', 'PayPal', 'Razorpay', 'Pay at Clinic']).optional(),
  paymentOption: z.enum(['Full Payment', 'Consultation Fee Only']).optional(),
});

export const updateStatusSchema = z.object({
  status: z.enum(['Confirmed', 'Pending', 'In-Progress', 'Completed', 'Cancelled']),
});

export const verifyAppointmentSchema = z.object({
  code: z.string().min(3),
  token: z.string().min(3),
});

export const listAppointmentsQuerySchema = z.object({
  status: z.string().optional(),
  date: z.string().optional(),
  search: z.string().optional(),
  doctorId: objectId.optional(),
});

export const rescheduleAppointmentSchema = z.object({
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'date must be YYYY-MM-DD'),
  time: z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/, 'time must be HH:mm'),
});

export const cancelAppointmentSchema = z.object({
  reason: z.string().max(500).optional().default(''),
});

export const payBalanceSchema = z.object({
  paymentMethod: z.enum(['Card', 'PayPal', 'Razorpay']).optional().default('Card'),
});

export const updatePaymentSchema = z.object({
  paymentStatus: z.enum(['pending', 'partially_paid', 'paid']).optional(),
  amountPaid: z.coerce.number().min(0).optional(),
}).refine((data) => data.paymentStatus !== undefined || data.amountPaid !== undefined, {
  message: 'Provide paymentStatus and/or amountPaid',
});