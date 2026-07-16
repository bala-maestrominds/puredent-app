import { Router } from 'express';
import { servicesController } from '../controllers/services.controller.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { validateRequest } from '../middleware/validateRequest.js';
import { uploadServiceImage } from '../middleware/upload.middleware.js';
import { requireAuth, requireRole } from '../middleware/auth.middleware.js';
import { createServiceSchema, updateServiceSchema } from '../utils/services.validation.js';

const router = Router();

// --- Public (used by the patient-facing website) ---
router.get('/', asyncHandler(servicesController.list));
router.get('/:idOrSlug', asyncHandler(servicesController.getByIdOrSlug));

// --- Admin only ---
router.post(
  '/',
  requireAuth,
  requireRole('admin'),
  uploadServiceImage.single('image'),
  validateRequest(createServiceSchema),
  asyncHandler(servicesController.create)
);

router.patch(
  '/:id',
  requireAuth,
  requireRole('admin'),
  uploadServiceImage.single('image'),
  validateRequest(updateServiceSchema),
  asyncHandler(servicesController.update)
);

router.delete('/:id', requireAuth, requireRole('admin'), asyncHandler(servicesController.remove));

export default router;
