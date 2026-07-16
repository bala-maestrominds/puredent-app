import mongoose from 'mongoose';

const processStepSchema = new mongoose.Schema(
  {
    step: { type: Number, required: true, min: 1 },
    title: { type: String, required: true, trim: true },
    description: { type: String, default: '', trim: true },
  },
  { _id: false }
);

const serviceSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    slug: { type: String, required: true, lowercase: true, trim: true },
    category: { type: String, trim: true, default: 'General' },
    shortDescription: { type: String, default: '' },
    description: { type: String, default: '' }, 
    imageUrl: { type: String, default: '' },
    priceFrom: { type: Number, min: 0, default: null },
    durationMinutes: { type: Number, required: true, min: 5 },
    isActive: { type: Boolean, default: true },
    // --- New fields for the service detail page ---
    keyBenefits: { type: [String], default: [] },
    process: { type: [processStepSchema], default: [] },
  },
  { timestamps: true }
);

serviceSchema.index({ slug: 1 }, { unique: true });
serviceSchema.index({ category: 1 });

export const Service = mongoose.model('Service', serviceSchema);
