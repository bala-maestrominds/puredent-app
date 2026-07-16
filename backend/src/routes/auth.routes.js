import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import { authController } from '../controllers/auth.controller.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { validateRequest } from '../middleware/validateRequest.js';
import { requireAuth } from '../middleware/auth.middleware.js';
import {
  registerSchema,
  loginSchema,
  refreshSchema,
  updateProfileSchema,
  changePasswordSchema,
} from '../utils/auth.validation.js';

const router = Router();

// Slow down brute-force / credential-stuffing attempts on auth endpoints.
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many attempts. Please try again later.' },
});

// --- Public ---
router.post('/register', authLimiter, validateRequest(registerSchema), asyncHandler(authController.register));
router.post('/login', authLimiter, validateRequest(loginSchema), asyncHandler(authController.login));
router.post('/refresh', authLimiter, validateRequest(refreshSchema), asyncHandler(authController.refresh));

// --- Authenticated ---
router.post('/logout', requireAuth, asyncHandler(authController.logout));
router.get('/me', requireAuth, asyncHandler(authController.me));
router.patch('/me', requireAuth, validateRequest(updateProfileSchema), asyncHandler(authController.updateMe));
router.post(
  '/change-password',
  requireAuth,
  validateRequest(changePasswordSchema),
  asyncHandler(authController.changePassword)
);

export default router;
