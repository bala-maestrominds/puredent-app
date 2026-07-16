import { Router } from 'express';
import { adminController } from '../controllers/admin.controller.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { requireAuth, requireRole } from '../middleware/auth.middleware.js';

const router = Router();

// Everything here is for the Flutter admin app only.
router.use(requireAuth, requireRole('admin'));

router.get('/stats', asyncHandler(adminController.stats));
router.get('/patients', asyncHandler(adminController.patients));
router.get('/revenue', asyncHandler(adminController.revenue));
router.get('/patients/:email/appointments', asyncHandler(adminController.patientAppointments));

export default router;
