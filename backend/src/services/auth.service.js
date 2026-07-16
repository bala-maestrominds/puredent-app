import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { User } from '../models/user.model.js';
import { ApiError } from '../utils/ApiError.js';
import { env } from '../config/env.js';

const SALT_ROUNDS = 10;

function signAccessToken(user) {
  return jwt.sign({ sub: user._id.toString(), role: user.role }, env.jwtAccessSecret, {
    expiresIn: env.jwtAccessExpiresIn,
  });
}

function signRefreshToken(user) {
  return jwt.sign({ sub: user._id.toString(), jti: crypto.randomUUID() }, env.jwtRefreshSecret, {
    expiresIn: env.jwtRefreshExpiresIn,
  });
}

function hashToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

async function issueTokens(user) {
  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);
  user.refreshTokenHash = hashToken(refreshToken);
  user.lastLoginAt = new Date();
  await user.save();
  return { accessToken, refreshToken };
}

async function register({ name, email, password, phone }) {
  const existing = await User.findOne({ email });
  if (existing) {
    throw new ApiError(409, 'An account with this email already exists');
  }

  const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);
  const user = await User.create({ name, email, passwordHash, phone: phone || '' });

  const tokens = await issueTokens(user);
  return { user: user.toPublicJSON(), ...tokens };
}

async function login({ email, password }) {
  const user = await User.findOne({ email });
  if (!user || !user.isActive) {
    throw new ApiError(401, 'Invalid email or password');
  }

  const matches = await bcrypt.compare(password, user.passwordHash);
  if (!matches) {
    throw new ApiError(401, 'Invalid email or password');
  }

  const tokens = await issueTokens(user);
  return { user: user.toPublicJSON(), ...tokens };
}

async function refresh({ refreshToken }) {
  let payload;
  try {
    payload = jwt.verify(refreshToken, env.jwtRefreshSecret);
  } catch {
    throw new ApiError(401, 'Invalid or expired refresh token');
  }

  const user = await User.findById(payload.sub);
  if (!user || !user.isActive || user.refreshTokenHash !== hashToken(refreshToken)) {
    throw new ApiError(401, 'Invalid or expired refresh token');
  }

  const tokens = await issueTokens(user);
  return { user: user.toPublicJSON(), ...tokens };
}

async function logout(userId) {
  await User.findByIdAndUpdate(userId, { refreshTokenHash: null });
}

async function getProfile(userId) {
  const user = await User.findById(userId);
  if (!user) throw new ApiError(404, 'User not found');
  return user.toPublicJSON();
}

async function updateProfile(userId, updates) {
  const user = await User.findByIdAndUpdate(userId, updates, { new: true, runValidators: true });
  if (!user) throw new ApiError(404, 'User not found');
  return user.toPublicJSON();
}

async function changePassword(userId, { currentPassword, newPassword }) {
  const user = await User.findById(userId);
  if (!user) throw new ApiError(404, 'User not found');

  const matches = await bcrypt.compare(currentPassword, user.passwordHash);
  if (!matches) throw new ApiError(400, 'Current password is incorrect');

  user.passwordHash = await bcrypt.hash(newPassword, SALT_ROUNDS);
  user.refreshTokenHash = null; // force re-login on other devices
  await user.save();
}

export const authService = {
  register,
  login,
  refresh,
  logout,
  getProfile,
  updateProfile,
  changePassword,
};
