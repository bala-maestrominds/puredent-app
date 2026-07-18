import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import { appointmentsController } from '../controllers/appointments.controller.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { validateRequest } from '../middleware/validateRequest.js';
import { requireAuth, requireRole } from '../middleware/auth.middleware.js';
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


const bookingLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many booking attempts. Please try again later.' },
});


router.post(
  '/',
  bookingLimiter,
  requireAuth,
  validateRequest(createAppointmentSchema),
  asyncHandler(appointmentsController.create)
);
router.get('/mine', requireAuth, asyncHandler(appointmentsController.listMine));
router.get('/:id/pdf', asyncHandler(appointmentsController.downloadPdf));

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


router.patch(
  '/:id/pay',
  requireAuth,
  validateRequest(payBalanceSchema),
  asyncHandler(appointmentsController.payBalance)
);

router.get('/:id', asyncHandler(appointmentsController.getById));

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