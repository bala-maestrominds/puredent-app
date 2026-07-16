import mongoose from 'mongoose';
import { env } from './env.js';

export async function connectDB() {
  mongoose.set('strictQuery', true);
  // console.log(env.mongoUri);
  await mongoose.connect(env.mongoUri);
  console.log(`[db] connected to MongoDB (${mongoose.connection.name})`);

  mongoose.connection.on('error', (err) => {
    console.error('[db] connection error:', err);
  });

  mongoose.connection.on('disconnected', () => {
    console.warn('[db] disconnected');
  });
}
