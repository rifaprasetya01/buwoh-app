"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.submitBuwohSchema = void 0;
const zod_1 = require("zod");
exports.submitBuwohSchema = zod_1.z.object({
    body: zod_1.z.object({
        contributions: zod_1.z.array(zod_1.z.object({
            type: zod_1.z.string().min(1),
            amount: zod_1.z.number().min(1),
            unit: zod_1.z.string().min(1),
            notes: zod_1.z.string().optional(),
        })).min(1, 'At least one contribution is required'),
    }),
    params: zod_1.z.object({
        eventId: zod_1.z.string().uuid(),
    }),
});
