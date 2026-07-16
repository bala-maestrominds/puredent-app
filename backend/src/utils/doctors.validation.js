import { z } from 'zod';

const workingHourSchema = z.object({
  day: z.enum(['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']),
  startTime: z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/, 'startTime must be HH:mm'),
  endTime: z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/, 'endTime must be HH:mm'),
});

// Multipart/form-data (used by the doctor photo upload) sends every field as a
// plain string, including JSON-encoded ones like workingHours. This helper
// accepts either an already-parsed array (JSON requests) or a JSON string
// (multipart requests) and normalizes both into a validated array.
const workingHoursField = z
  .union([z.array(workingHourSchema), z.string()])
  .optional()
  .transform((val, ctx) => {
    if (val === undefined || val === '') return [];
    if (Array.isArray(val)) return val;
    try {
      const parsed = JSON.parse(val);
      const result = z.array(workingHourSchema).safeParse(parsed);
      if (!result.success) {
        ctx.addIssue({ code: z.ZodIssueCode.custom, message: 'Invalid workingHours JSON' });
        return z.NEVER;
      }
      return result.data;
    } catch {
      ctx.addIssue({ code: z.ZodIssueCode.custom, message: 'workingHours must be valid JSON' });
      return z.NEVER;
    }
  });


export const createDoctorSchema = z.object({
  name: z.string().min(2).max(120),
  specialty: z.string().min(2).max(120),
  bio: z.string().max(2000).optional(),
  photoUrl: z.string().url().optional().or(z.literal('')),
  email: z.string().email().optional(),
  phone: z.string().min(6).max(20).optional(),
  experienceYears: z.coerce.number().int().min(0).max(80).optional(),
  consultationFee: z.coerce.number().min(0).optional(),
  rating: z.coerce.number().min(0).max(5).optional(),
  reviews: z.coerce.number().int().min(0).optional(),
  experience: z.string().max(60).optional(),
  education: z.string().max(200).optional(),
  languages: z.union([z.array(z.string()), z.string()]).optional().transform((val) => {
    if (val === undefined) return undefined;
    if (Array.isArray(val)) return val;
    try {
      return JSON.parse(val);
    } catch {
      return val.split(',').map((s) => s.trim());
    }
  }),

  services: z.array(z.string().length(24, 'invalid service id')).optional(),
  workingHours: workingHoursField,
  slotDurationMinutes: z.coerce.number().int().positive().max(240).optional(),
});

// Same shape but every field optional, for PATCH.
export const updateDoctorSchema = createDoctorSchema.partial();

export const availabilityQuerySchema = z.object({
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'date must be YYYY-MM-DD'),
});