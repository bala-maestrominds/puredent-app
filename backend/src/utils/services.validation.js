import { z } from 'zod';

const slugify = (str) =>
  str
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '');

// Doctor/admin forms may submit these as JSON strings (multipart form data),
// so accept either an already-parsed array or a JSON-encoded string.
const jsonArray = (itemSchema) =>
  z
    .union([z.array(itemSchema), z.string()])
    .optional()
    .transform((val) => {
      if (val === undefined || val === '') return undefined;
      if (typeof val === 'string') {
        try {
          const parsed = JSON.parse(val);
          return Array.isArray(parsed) ? parsed : undefined;
        } catch {
          return undefined;
        }
      }
      return val;
    })
    .pipe(z.array(itemSchema).optional());

const processStepSchema = z.object({
  step: z.coerce.number().int().min(1),
  title: z.string().min(1).max(120),
  description: z.string().max(500).optional().default(''),
});

export const createServiceSchema = z.object({
  name: z.string().min(2).max(120),
  slug: z
    .string()
    .min(2)
    .max(140)
    .optional()
    .or(z.literal(''))
    .transform((val) => (val ? slugify(val) : undefined)),
  category: z.string().max(60).optional(),
  shortDescription: z.string().max(300).optional(),
  description: z.string().max(5000).optional(),
  imageUrl: z.string().optional(),
  priceFrom: z.coerce.number().min(0).optional().nullable(),
  durationMinutes: z.coerce.number().int().min(5).max(600),
  keyBenefits: jsonArray(z.string().min(1).max(120)),
  process: jsonArray(processStepSchema),
});

// Same shape but every field optional, for PATCH.
export const updateServiceSchema = createServiceSchema.partial();

export { slugify };
