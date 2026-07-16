import jwt from 'jsonwebtoken';
import { env } from '../config/env.js';
import { ApiError } from '../utils/ApiError.js';

/**
 * Requires a valid access token. Populates req.user = { id, role }.
 */
export function requireAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const [scheme, token] = header.split(' ');

  if (scheme !== 'Bearer' || !token) {
    return next(new ApiError(401, 'Authentication required'));
  }

  try {
    const payload = jwt.verify(token, env.jwtAccessSecret);
    req.user = { id: payload.sub, role: payload.role };
    return next();
  } catch {
    return next(new ApiError(401, 'Invalid or expired access token'));
  }
}

/**
 * Attaches req.user if a valid token is present, but never rejects the request.
 * Useful for endpoints that behave differently for guests vs logged-in users.
 */
export function attachUserIfPresent(req, res, next) {
  const header = req.headers.authorization || '';
  const [scheme, token] = header.split(' ');

  if (scheme === 'Bearer' && token) {
    try {
      const payload = jwt.verify(token, env.jwtAccessSecret);
      req.user = { id: payload.sub, role: payload.role };
    } catch {
      // ignore invalid token for optional auth
    }
  }
  next();
}

export function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return next(new ApiError(403, 'You do not have permission to perform this action'));
    }
    next();
  };
}
