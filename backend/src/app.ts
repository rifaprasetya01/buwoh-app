import express, { Request, Response } from 'express';
import cors from 'cors';
import path from 'path';

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Request Logger
app.use((req, res, next) => {
  const start = Date.now();
  console.log(`\n[${new Date().toISOString()}] ${req.method} ${req.url} - Request Received`);
  if (req.method !== 'GET') {
    console.log('Request Body:', JSON.stringify(req.body, null, 2));
  }
  
  // Intercept res.json to log response body on error
  const originalJson = res.json;
  res.json = function(body) {
    if (res.statusCode >= 400) {
      console.log(`Response Error Body (${res.statusCode}):`, JSON.stringify(body, null, 2));
    }
    return originalJson.call(this, body);
  };

  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url} - Status: ${res.statusCode} (${duration}ms)`);
    
    // Log for multipart requests since body is populated later by multer
    if (req.is('multipart/form-data') || req.is('multipart/*')) {
      console.log('Multipart Request Body:', JSON.stringify(req.body, null, 2));
      if ((req as any).file) console.log('Uploaded File:', (req as any).file);
      if ((req as any).files) console.log('Uploaded Files:', (req as any).files);
    }
  });
  
  next();
});
app.use(express.urlencoded({ extended: true }));

// Serve static files (uploads)
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Health Check
app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({ status: 'OK', message: 'BuwohApp API is running' });
});

import routes from './routes';

// Module Routes will be imported here
app.use('/api/v1', routes);

// 404 Handler
app.use((req: Request, res: Response) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Global Error Handler
app.use((err: any, req: Request, res: Response, next: any) => {
  const statusCode = err.status || err.statusCode || 500;
  console.error(`[${new Date().toISOString()}] ERROR ${req.method} ${req.url}`);
  console.error('Message:', err.message);
  console.error('Stack:', err.stack);
  
  res.status(statusCode).json({
    message: err.message || 'Internal Server Error',
    error: process.env.NODE_ENV === 'development' ? err : {}
  });
});

export default app;
