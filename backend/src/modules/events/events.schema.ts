import { z } from 'zod';

export const createEventSchema = z.object({
  body: z.object({
    title: z.string().min(1, 'Title is required'),
    type: z.string().min(1, 'Type is required'),
    date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date format (YYYY-MM-DD)'),
    startTime: z.string().regex(/^\d{2}:\d{2}$/, 'Invalid time format (HH:MM)'),
    endTime: z.string().regex(/^\d{2}:\d{2}$/, 'Invalid time format (HH:MM)'),
    locationName: z.string().min(1, 'Location name is required'),
    mapLink: z.string().url().optional().or(z.literal('')),
    description: z.string().optional(),
    
    // Preprocess to handle stringified JSON from multipart/form-data
    address: z.preprocess((val) => {
      if (typeof val === 'string') {
        try { return JSON.parse(val); } catch (e) { return val; }
      }
      return val;
    }, z.object({
      street: z.string().optional(),
      rtRw: z.string().optional(),
      village: z.string().optional(),
      district: z.string().optional(),
      city: z.string().optional(),
      province: z.string().optional(),
      postalCode: z.string().optional(),
      latitude: z.preprocess((val) => (typeof val === 'string' ? parseFloat(val) : val), z.number().optional()),
      longitude: z.preprocess((val) => (typeof val === 'string' ? parseFloat(val) : val), z.number().optional()),
    }).optional()),

    expectedContributions: z.preprocess((val) => {
      if (typeof val === 'string') {
        try { return JSON.parse(val); } catch (e) { return val; }
      }
      return val;
    }, z.array(z.string()).optional()),
  }).refine((data) => data.startTime < data.endTime, {
    message: "Jam Selesai harus setelah Jam Mulai",
    path: ["endTime"],
  }),
});

export const updateGuestStatusSchema = z.object({
  body: z.object({
    status: z.enum(['pending', 'validated', 'rejected', 'attended', 'absent']),
  }),
  params: z.object({
    eventId: z.string().uuid(),
    guestId: z.string().uuid(),
  }),
});

export const addManualGuestSchema = z.object({
  body: z.object({
    email: z.string().email('Format email tidak valid'),
    contributions: z.array(
      z.object({
        type: z.string().min(1),
        amount: z.number().min(1),
        unit: z.string().min(1),
        notes: z.string().optional(),
      })
    ).min(1, 'Minimal satu kontribusi harus dipilih'),
  }),
  params: z.object({
    eventId: z.string().uuid(),
  }),
});

export type CreateEventInput = z.infer<typeof createEventSchema>['body'];
export type UpdateGuestStatusInput = z.infer<typeof updateGuestStatusSchema>['body'];
export type AddManualGuestInput = z.infer<typeof addManualGuestSchema>['body'];
