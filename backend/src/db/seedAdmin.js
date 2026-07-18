import bcrypt from 'bcryptjs';
import mongoose from 'mongoose';
import { connectDB } from '../config/db.js';
import { User } from '../models/user.model.js';


function parseArgs() {
  const args = process.argv.slice(2);
  const out = {};
  for (let i = 0; i < args.length; i += 1) {
    if (args[i].startsWith('--')) {
      out[args[i].slice(2)] = args[i + 1];
      i += 1;
    }
  }
  return out;
}

async function seedAdmin() {
  const { email, password, name } = parseArgs();

  const adminEmail = (email || process.env.ADMIN_SEED_EMAIL || 'admin@gmail.com').toLowerCase().trim();
  const adminPassword = password || process.env.ADMIN_SEED_PASSWORD || 'puredentadmin';
  const adminName = name || 'Clinic Admin';

  if (adminPassword.length < 8) {
    throw new Error('Admin password must be at least 8 characters');
  }

  await connectDB();

  const passwordHash = await bcrypt.hash(adminPassword, 10);

  const admin = await User.findOneAndUpdate(
    { email: adminEmail },
    {
      $set: {
        name: adminName,
        email: adminEmail,
        passwordHash,
        role: 'admin',
        isActive: true,
      },
    },
    { upsert: true, new: true, setDefaultsOnInsert: true }
  );

  console.log('[seedAdmin] admin user ready:');
  console.log(`  email:    ${admin.email}`);
  console.log(`  password: ${adminPassword}`);
  console.log(`  role:     ${admin.role}`);

  await mongoose.disconnect();
}

seedAdmin().catch((err) => {
  console.error('[seedAdmin] failed:', err);
  process.exit(1);
});
