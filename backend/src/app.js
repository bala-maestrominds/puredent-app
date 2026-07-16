import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import path from 'path';
import { fileURLToPath } from 'url';
import { env } from './config/env.js';
import { errorHandler } from './middleware/errorHandler.js';
import { ApiError } from './utils/ApiError.js';
import doctorsRoutes from './routes/doctors.routes.js';
import servicesRoutes from './routes/services.routes.js';
import contactRoutes from './routes/contact.routes.js';
import appointmentsRoutes from './routes/appointments.routes.js'
import authRoutes from './routes/auth.routes.js'
import adminRoutes from './routes/admin.routes.js'

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export function createApp() {
  const app = express();

  app.use(cors({ origin: env.clientOrigin }));
  app.use(express.json());
  app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
  app.use(morgan('dev'));

  app.get('/health', (req, res) => res.json({ status: 'ok' }));

  app.use('/api/auth', authRoutes);
  app.use('/api/doctors', doctorsRoutes);
  app.use('/api/services', servicesRoutes);
  app.use('/api/contact', contactRoutes);
   app.use('/api/appointments', appointmentsRoutes); 
  app.use('/api/admin', adminRoutes);

  app.use((req, res, next) => {
    next(new ApiError(404, `Route not found: ${req.method} ${req.originalUrl}`));
  });

  app.use(errorHandler);

  return app;
}