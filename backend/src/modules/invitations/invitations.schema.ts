import { z } from 'zod';

export const submitBuwohSchema = z.object({
  body: z.object({
    contributions: z.array(
      z.object({
        type: z.string().min(1),
        amount: z.number().min(1),
        unit: z.string().min(1),
        notes: z.string().optional(),
      })
    ).min(1, 'At least one contribution is required'),
  }),
  params: z.object({
    eventId: z.string().uuid(),
  }),
});

export type SubmitBuwohInput = z.infer<typeof submitBuwohSchema>['body'];
