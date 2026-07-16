import { doctorsService } from '../services/doctors.service.js';

async function list(req, res) {
  const { specialty } = req.query;
  const doctors = await doctorsService.listDoctors({ specialty });
  res.json({ data : doctors });
}

async function getById(req, res) {
  const doctor = await doctorsService.getDoctorById(req.params.id);
  res.json({ data : doctor });
}


async function create(req, res) {
  const {
    name,
    specialty,
    email,
    phone,
    experienceYears,
    consultationFee,
    bio,
    workingHours,
  } = req.body;

  const payload = {
    name: name?.trim(),
    specialty,
    email: email?.trim(),
    phone: phone?.trim(),
    experienceYears: experienceYears ?? 0,
    consultationFee: consultationFee ?? 0,
    bio: bio?.trim() || '',
    workingHours: workingHours || [],
    photoUrl: req.file ? `/uploads/${req.file.filename}` : '',
  };

  const doctor = await doctorsService.createDoctor(payload);
  res.status(201).json({ data: doctor });
}

async function update(req, res) {
  const doctor = await doctorsService.updateDoctor(req.params.id, req.body);
  res.json({ data: doctor });
}

async function deactivate(req, res) {
  const doctor = await doctorsService.deactivateDoctor(req.params.id);
  res.json({ data: doctor });
}

async function availability(req, res) {
  const { date } = req.query;
  const slots = await doctorsService.getAvailability(req.params.id, date);
  res.json({ data: { doctorId: req.params.id, date, slots } });
}

export const doctorsController = {
  list,
  getById,
  create,
  update,
  deactivate,
  availability,
};