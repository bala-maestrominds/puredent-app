import { ApiError } from '../utils/ApiError.js';

export function errorHandler(err, req, res, next) {
  if (err instanceof ApiError) {
    return res.status(err.statusCode).json({
      error: err.message,
      details: err.details || undefined,
    });
  }

  // Mongoose validation errors -> 400
  if (err.name === 'ValidationError') {
    return res.status(400).json({ error: 'Validation failed', details: err.message });
  }

  // Malformed ObjectId in a route param (e.g. GET /doctors/not-a-valid-id) -> 400
  if (err.name === 'CastError') {
    return res.status(400).json({ error: `Invalid ${err.path}: ${err.value}` });
  }

  // Anything unexpected: log full detail server-side, never leak internals to the client.
  console.error('[unhandled error]', err);
  return res.status(500).json({ error: 'Something went wrong. Please try again later.' });


}
