import { servicesService } from '../services/services.service.js';

async function list(req, res) {
  const { category } = req.query;
  const services = await servicesService.listServices({ category });
  res.json({ data: services });
}

async function getByIdOrSlug(req, res) {
  const { idOrSlug } = req.params;
  const isObjectId = /^[a-f\d]{24}$/i.test(idOrSlug);
  const data = isObjectId
    ? await servicesService.getServiceById(idOrSlug)
    : await servicesService.getServiceBySlug(idOrSlug);
  res.json({ data });
}

async function create(req, res) {
  const {
    name,
    slug,
    category,
    shortDescription,
    description,
    priceFrom,
    durationMinutes,
    keyBenefits,
    process,
  } = req.body;

  const payload = {
    name: name?.trim(),
    slug,
    category: category?.trim() || 'General',
    shortDescription: shortDescription?.trim() || '',
    description: description?.trim() || '',
    priceFrom: priceFrom ?? null,
    durationMinutes,
    imageUrl: req.file ? `/uploads/${req.file.filename}` : (req.body.imageUrl || ''),
    keyBenefits: keyBenefits ?? [],
    process: process ?? [],
  };

  const service = await servicesService.createService(payload);
  res.status(201).json({ data: service });
}

async function update(req, res) {
  const payload = { ...req.body };
  if (req.file) {
    payload.imageUrl = `/uploads/${req.file.filename}`;
  }
  const service = await servicesService.updateService(req.params.id, payload);
  res.json({ data: service });
}

async function remove(req, res) {
  await servicesService.deleteService(req.params.id);
  res.status(204).send();
}

export const servicesController = {
  list,
  getByIdOrSlug,
  create,
  update,
  remove,
};
