"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateProfileSchema = void 0;
const zod_1 = require("zod");
exports.updateProfileSchema = zod_1.z.object({
    body: zod_1.z.object({
        name: zod_1.z.string().optional(),
        birthDate: zod_1.z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date format (YYYY-MM-DD)').optional(),
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
    }),
});
