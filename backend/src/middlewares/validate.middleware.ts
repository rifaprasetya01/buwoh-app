import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';

export const validate = (schema: ZodSchema) => {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const validated: any = await schema.parseAsync({
        body: req.body,
        query: req.query,
        params: req.params,
      });
      
      // Replace original data with validated/transformed data
      req.body = validated.body;
      Object.assign(req.query, validated.query);
      Object.assign(req.params, validated.params);
      
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        console.error(`[${new Date().toISOString()}] Validation failed for ${req.method} ${req.url}`);
        console.error('Input Body:', JSON.stringify(req.body, null, 2));
        console.error('Errors:', JSON.stringify(error.issues, null, 2));
        
        res.status(400).json({
          message: 'Validation failed',
          errors: error.issues,
        });
      } else {
        next(error);
      }
    }
  };
};
