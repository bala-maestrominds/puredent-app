import { authService } from '../services/auth.service.js';

async function register(req, res) {
  const result = await authService.register(req.body);
  res.status(201).json({ data: result });
}

async function login(req, res) {
  const result = await authService.login(req.body);
  res.json({ data: result });
}

async function refresh(req, res) {
  const result = await authService.refresh(req.body);
  res.json({ data: result });
}

async function logout(req, res) {
  await authService.logout(req.user.id);
  res.json({ data: { success: true } });
}

async function me(req, res) {
  const user = await authService.getProfile(req.user.id);
  res.json({ data: user });
}

async function updateMe(req, res) {
  const user = await authService.updateProfile(req.user.id, req.body);
  res.json({ data: user });
}

async function changePassword(req, res) {
  await authService.changePassword(req.user.id, req.body);
  res.json({ data: { success: true } });
}

export const authController = {
  register,
  login,
  refresh,
  logout,
  me,
  updateMe,
  changePassword,
};
