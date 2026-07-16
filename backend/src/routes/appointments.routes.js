import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import { appointmentsController } from '../controllers/appointments.controller.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { validateRequest } from '../middleware/validateRequest.js';
import { attachUserIfPresent, requireAuth, requireRole } from '../middleware/auth.middleware.js';
import {
  createAppointmentSchema,
  updateStatusSchema,
  verifyAppointmentSchema,
  listAppointmentsQuerySchema,
  rescheduleAppointmentSchema,
  cancelAppointmentSchema,
  payBalanceSchema,
  updatePaymentSchema,
} from '../utils/appointments.validation.js';

const router = Router();

// Guard the public booking endpoint against abuse (it triggers DB writes,
// PDF generation, and an outbound email per request).
const bookingLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many booking attempts. Please try again later.' },
});

// --- Public (guest booking allowed; logged-in users get the appointment linked to their account) ---
router.post(
  '/',
  bookingLimiter,
  attachUserIfPresent,
  validateRequest(createAppointmentSchema),
  asyncHandler(appointmentsController.create)
);
router.get('/mine', requireAuth, asyncHandler(appointmentsController.listMine));
router.get('/:id/pdf', asyncHandler(appointmentsController.downloadPdf));

// Patient self-service: reschedule/cancel their own appointment (admins may
// also call these; ownership is enforced in the service layer).
router.patch(
  '/:id/reschedule',
  requireAuth,
  validateRequest(rescheduleAppointmentSchema),
  asyncHandler(appointmentsController.reschedule)
);
router.patch(
  '/:id/cancel',
  requireAuth,
  validateRequest(cancelAppointmentSchema),
  asyncHandler(appointmentsController.cancel)
);

// Patient self-service: pay the outstanding balance online (e.g. after
// being checked in, settle the remainder of a consultation-only booking,
// or pay in full). Feeds straight into the admin revenue dashboard.
router.patch(
  '/:id/pay',
  requireAuth,
  validateRequest(payBalanceSchema),
  asyncHandler(appointmentsController.payBalance)
);

router.get('/:id', asyncHandler(appointmentsController.getById));

// --- Reception / Admin ---
// Scans/lookups a QR payload {code, token} to pull up the patient's appointment.
router.post(
  '/verify',
  requireAuth,
  requireRole('admin'),
  validateRequest(verifyAppointmentSchema),
  asyncHandler(appointmentsController.verify)
);
router.post('/:id/checkin', requireAuth, requireRole('admin'), asyncHandler(appointmentsController.checkIn));
router.patch(
  '/:id/status',
  requireAuth,
  requireRole('admin'),
  validateRequest(updateStatusSchema),
  asyncHandler(appointmentsController.updateStatus)
);
router.patch(
  '/:id/payment',
  requireAuth,
  requireRole('admin'),
  validateRequest(updatePaymentSchema),
  asyncHandler(appointmentsController.updatePayment)
);
router.get(
  '/',
  requireAuth,
  requireRole('admin'),
  validateRequest(listAppointmentsQuerySchema, 'query'),
  asyncHandler(appointmentsController.list)
);

export default router;
