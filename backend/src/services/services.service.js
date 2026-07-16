import { Service } from '../models/services.model.js';
import { Doctor } from '../models/doctors.model.js';
import { ApiError } from '../utils/ApiError.js';
import { slugify } from '../utils/services.validation.js';

async function listServices({ category } = {}) {
  if (category) {
    return Service.find({ category }).sort({ name: 1 });
  }
  return Service.find({}).sort({ name: 1 });
}

// Finds the top-rated active doctor who offers the given service, so the
// service detail page can show a "best specialist" card.
async function findBestSpecialist(serviceId) {
  return Doctor.findOne({ services: serviceId, isActive: true })
    .sort({ rating: -1, reviews: -1 })
    .select('name specialty photoUrl experienceYears consultationFee rating reviews')
    .lean();
}

async function withBestSpecialist(service) {
  if (!service) return service;
  const bestSpecialist = await findBestSpecialist(service._id);
  const plain = typeof service.toObject === 'function' ? service.toObject() : service;
  return { ...plain, bestSpecialist: bestSpecialist || null };
}

async function getServiceBySlug(slug) {
  const service = await Service.findOne({ slug, isActive: true });
  if (!service) throw new ApiError(404, 'Service not found');
  return withBestSpecialist(service);
}

async function getServiceById(id) {
  const service = await Service.findById(id);
  if (!service) throw new ApiError(404, 'Service not found');
  return withBestSpecialist(service);
}

async function ensureUniqueSlug(baseSlug, excludeId) {
  let slug = baseSlug;
  let suffix = 1;
  while (
    await Service.exists({ slug, ...(excludeId ? { _id: { $ne: excludeId } } : {}) })
  ) {
    suffix += 1;
    slug = `${baseSlug}-${suffix}`;
  }
  return slug;
}

async function createService(data) {
  const baseSlug = slugify(data.slug || data.name);
  const slug = await ensureUniqueSlug(baseSlug);
  return Service.create({ ...data, slug });
}

async function updateService(id, data) {
  const payload = { ...data };
  if (payload.slug || payload.name) {
    const baseSlug = slugify(payload.slug || payload.name);
    payload.slug = await ensureUniqueSlug(baseSlug, id);
  }
  const service = await Service.findByIdAndUpdate(id, payload, {
    new: true,
    runValidators: true,
  });
  if (!service) throw new ApiError(404, 'Service not found');
  return service;
}

async function deleteService(id) {
  const service = await Service.findByIdAndDelete(id);
  if (!service) throw new ApiError(404, 'Service not found');
  return service;
}

export const servicesService = {
  listServices,
  getServiceBySlug,
  getServiceById,
  createService,
  updateService,
  deleteService,
};
