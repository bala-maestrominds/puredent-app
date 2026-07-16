import { adminService } from '../services/admin.service.js';

async function stats(req, res) {
  const data = await adminService.getDashboardStats();
  res.json({ data });
}

async function patients(req, res) {
  const { search } = req.query;
  const data = await adminService.listPatients({ search });
  res.json({ data });
}

async function revenue(req, res) {
  const { period } = req.query;
  const data = await adminService.getRevenue({ period });
  res.json({ data });
}

async function patientAppointments(req, res) {
  const data = await adminService.getPatientAppointments(req.params.email);
  res.json({ data });
}

export const adminController = {
  stats,
  patients,
  revenue,
  patientAppointments,
};
