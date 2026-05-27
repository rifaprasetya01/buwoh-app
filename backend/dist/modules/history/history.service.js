"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.HistoryService = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
class HistoryService {
    static async getHistory(guestId, filter) {
        const whereClause = {
            guestId,
            status: { in: ['validated', 'attended'] },
            deletedAt: null,
        };
        if (filter && filter !== 'Semua') {
            whereClause.event = { eventType: filter };
        }
        const histories = await prisma_1.default.eventGuest.findMany({
            where: whereClause,
            include: {
                event: {
                    include: { host: { select: { name: true } } },
                },
                contributions: true,
            },
            orderBy: { createdAt: 'desc' },
        });
        return histories.map((h) => ({
            historyId: h.id,
            eventId: h.event.id,
            title: h.event.title,
            hostName: h.event.host.name,
            date: h.event.eventDate.toISOString().split('T')[0],
            locationName: h.event.locationName,
            type: h.event.eventType,
            status: h.status,
            contributions: h.contributions.map((c) => ({
                type: c.itemType,
                value: `${c.amount} ${c.unit}`,
            })),
        }));
    }
    static async getHistoryDetails(historyId, guestId) {
        const history = await prisma_1.default.eventGuest.findFirst({
            where: { id: historyId, guestId, deletedAt: null },
            include: {
                event: {
                    include: {
                        host: { select: { name: true, photoUrl: true } },
                        address: true,
                    },
                },
                contributions: true,
            },
        });
        if (!history)
            throw new Error('History record not found');
        return {
            historyId: history.id,
            eventId: history.event.id,
            title: history.event.title,
            type: history.event.eventType,
            hostName: history.event.host.name,
            hostAvatarUrl: history.event.host.photoUrl,
            date: history.event.eventDate.toISOString().split('T')[0],
            locationName: history.event.locationName,
            address: history.event.address,
            status: history.status,
            contributions: history.contributions.map((c) => ({
                type: c.itemType,
                value: `${c.amount} ${c.unit}`,
                notes: c.notes,
            })),
        };
    }
}
exports.HistoryService = HistoryService;
