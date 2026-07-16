import mongoose from 'mongoose';

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, trim: true, lowercase: true, unique: true, index: true },
    passwordHash: { type: String, required: true },
    phone: { type: String, trim: true, default: '' },
    dateOfBirth: { type: String, default: '' }, // "YYYY-MM-DD"
    gender: { type: String, enum: ['Male', 'Female', 'Other', ''], default: '' },
    avatarUrl: { type: String, default: '' },
    role: { type: String, enum: ['patient', 'admin'], default: 'patient' },
    isActive: { type: Boolean, default: true },
    lastLoginAt: { type: Date, default: null },
    refreshTokenHash: { type: String, default: null },
  },
  { timestamps: true }
);

userSchema.methods.toPublicJSON = function toPublicJSON() {
  return {
    id: this._id,
    name: this.name,
    email: this.email,
    phone: this.phone,
    dateOfBirth: this.dateOfBirth,
    gender: this.gender,
    avatarUrl: this.avatarUrl,
    role: this.role,
    createdAt: this.createdAt,
  };
};

export const User = mongoose.model('User', userSchema);
