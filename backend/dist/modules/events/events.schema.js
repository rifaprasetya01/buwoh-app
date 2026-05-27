"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateGuestStatusSchema = exports.createEventSchema = void 0;
const zod_1 = require("zod");
exports.createEventSchema = zod_1.z.object({
    body: zod_1.z.object({
        title: zod_1.z.string().min(1, 'Title is required'),
        type: zod_1.z.string().min(1, 'Type is required'),
        date: zod_1.z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date format (YYYY-MM-DD)'),
        startTime: zod_1.z.string().regex(/^\d{2}:\d{2}$/, 'Invalid time format (HH:MM)').optional(),
        endTime: zod_1.z.string().regex(/^\d{2}:\d{2}$/, 'Invalid time format (HH:MM)').optional(),
        locationName: zod_1.z.string().min(1, 'Location name is required'),
        mapLink: zod_1.z.string().url().optional().or(zod_1.z.literal('')),
        description: zod_1.z.string().optional(),
        // Address object mapped from flattened strings or nested JSON
        address: zod_1.z.object({
            street: zod_1.z.string().optional(),
            rtRw: zod_1.z.string().optional(),
            village: zod_1.z.string().optional(),
            district: zod_1.z.string().optional(),
            city: zod_1.z.string().optional(),
            province: zod_1.z.string().optional(),
            postalCode: zod_1.z.string().optional(),
            latitude: zod_1.z.preprocess((val) => (typeof val === 'string' ? parseFloat(val) : val), zod_1.z.number().optional()),
            longitude: zod_1.z.preprocess((val) => (typeof val === 'string' ? parseFloat(val) : val), zod_1.z.number().optional()),
        }).optional(),
        expectedContributions: zod_1.z.array(zod_1.z.string()).optional(),
    }),
});
exports.updateGuestStatusSchema = zod_1.z.object({
    body: zod_1.z.object({
        status: zod_1.z.enum(['pending', 'validated', 'rejected', 'attended', 'absent']),
    }),
    params: zod_1.z.object({
        eventId: zod_1.z.string().uuid(),
        guestId: zod_1.z.string().uuid(),
    }),
});
