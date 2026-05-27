import { z } from 'zod';

export const updateProfileSchema = z.object({
  body: z.object({
    name: z.string().optional(),
    birthDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date format (YYYY-MM-DD)').optional(),
    address: z.object({
      street: z.string().optional(),
      rtRw: z.string().optional(),
      village: z.string().optional(),
      district: z.string().optional(),
      city: z.string().optional(),
      province: z.string().optional(),
      postalCode: z.string().optional(),
      latitude: z.preprocess((val) => (typeof val === 'string' ? parseFloat(val) : val), z.number().optional()),
      longitude: z.preprocess((val) => (typeof val === 'string' ? parseFloat(val) : val), z.number().optional()),
    }).optional(),
  }),
});

export type UpdateProfileInput = z.infer<typeof updateProfileSchema>['body'];
