import mongoose from 'mongoose';

const workingHourSchema = new mongoose.Schema(
  {
    day: {
      type: String,
      enum: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
      required: true,
    },
    startTime: { type: String, required: true }, // "HH:mm"
    endTime: { type: String, required: true }, // "HH:mm"
  },
  { _id: false }
);

const doctorSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    specialty: { type: String, required: true, trim: true },
    bio: { type: String, default: '' },
    photoUrl: { type: String, default: '' },
    email: { type: String, trim: true, lowercase: true },
    phone: { type: String, trim: true },
    experienceYears: { type: Number, default: 0 },
    consultationFee: { type: Number, default: 0 },
    rating: { type: Number, default: 0, min: 0, max: 5 },
    reviews: { type: Number, default: 0, min: 0 },
    experience: { type: String, default: '' },
    education: { type: String, default: '' },
    languages: { type: [String], default: [] },
    services: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Service' }],
    workingHours: { type: [workingHourSchema], default: [] },
    slotDurationMinutes: { type: Number, default: 30 },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

doctorSchema.index({ isActive: 1 });

export const Doctor = mongoose.model('Doctor', doctorSchema);
