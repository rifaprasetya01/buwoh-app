"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.EventsService = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
class EventsService {
    static async listHostedEvents(hostId, status) {
        const whereClause = { hostId, deletedAt: null };
        if (status) {
            whereClause.status = status;
        }
        const events = await prisma_1.default.event.findMany({
            where: whereClause,
            include: {
                _count: {
                    select: { guests: true },
                },
            },
            orderBy: { eventDate: 'desc' },
        });
        // Formatting response to match API contract
        return Promise.all(events.map(async (event) => {
            const guestsAttended = await prisma_1.default.eventGuest.count({
                where: { eventId: event.id, status: { in: ['attended', 'validated'] } },
            });
            const totalGuests = event._count.guests;
            const progressPercentage = totalGuests === 0 ? 0 : Math.round((guestsAttended / totalGuests) * 100);
            return {
                id: event.id,
                title: event.title,
                type: event.eventType,
                locationName: event.locationName,
                date: event.eventDate.toISOString().split('T')[0],
                startTime: event.startTime ? event.startTime.toISOString().split('T')[1].substring(0, 5) : null,
                endTime: event.endTime ? event.endTime.toISOString().split('T')[1].substring(0, 5) : null,
                imageUrl: event.coverImageUrl,
                status: event.status,
                isPriority: event.isPriority,
                guestsAttended,
                guestsTotal: totalGuests,
                progressPercentage,
            };
        }));
    }
    static async createEvent(hostId, data, coverImageUrl) {
        let addressId;
        if (data.address) {
            const newAddress = await prisma_1.default.address.create({
                data: {
                    street: data.address.street,
                    rt_rw: data.address.rtRw,
                    village: data.address.village,
                    district: data.address.district,
                    city: data.address.city,
                    province: data.address.province,
                    postal_code: data.address.postalCode,
                    latitude: data.address.latitude,
                    longitude: data.address.longitude,
                },
            });
            addressId = newAddress.id;
        }
        // Parse time strings into Date objects
        let start, end;
        if (data.startTime) {
            start = new Date(`1970-01-01T${data.startTime}:00Z`);
        }
        if (data.endTime) {
            end = new Date(`1970-01-01T${data.endTime}:00Z`);
        }
        const newEvent = await prisma_1.default.event.create({
            data: {
                hostId,
                title: data.title,
                eventType: data.type,
                eventDate: new Date(data.date),
                startTime: start,
                endTime: end,
                locationName: data.locationName,
                mapLink: data.mapLink,
                description: data.description,
                coverImageUrl,
                addressId,
            },
        });
        if (data.expectedContributions && data.expectedContributions.length > 0) {
            const contributionsData = data.expectedContributions.map((itemType) => ({
                eventId: newEvent.id,
                itemType,
            }));
            await prisma_1.default.eventExpectedContribution.createMany({
                data: contributionsData,
            });
        }
        return newEvent;
    }
    static async getEventRecap(eventId, hostId) {
        const event = await prisma_1.default.event.findFirst({
            where: { id: eventId, hostId, deletedAt: null },
        });
        if (!event)
            throw new Error('Event not found');
        const guests = await prisma_1.default.eventGuest.findMany({
            where: { eventId },
            include: {
                guest: { select: { id: true, name: true, photoUrl: true } },
                contributions: true,
            },
        });
        // Aggregate contributions (simplified logic for Recap)
        const summary = {};
        const formattedGuests = guests.map((g) => {
            // Build summary
            g.contributions.forEach((c) => {
                const key = c.itemType; // 'uang', 'beras', etc.
                if (!summary[key])
                    summary[key] = 0;
                summary[key] += Number(c.amount);
            });
            return {
                guestId: g.guest.id,
                name: g.guest.name,
                avatarUrl: g.guest.photoUrl,
                status: g.status,
                contributions: g.contributions.map((c) => ({
                    type: c.itemType,
                    value: `${c.amount} ${c.unit}`,
                })),
            };
        });
        return {
            eventId: event.id,
            title: event.title,
            date: event.eventDate.toISOString().split('T')[0],
            totalGuests: guests.length,
            summary,
            guests: formattedGuests,
        };
    }
    static async listEventGuests(eventId, hostId, status) {
        const event = await prisma_1.default.event.findFirst({
            where: { id: eventId, hostId, deletedAt: null },
        });
        if (!event)
            throw new Error('Event not found');
        const whereClause = { eventId };
        if (status)
            whereClause.status = status;
        const guests = await prisma_1.default.eventGuest.findMany({
            where: whereClause,
            include: {
                guest: { select: { id: true, name: true } },
                contributions: true,
            },
        });
        return guests.map((g) => ({
            guestId: g.guest.id,
            name: g.guest.name,
            status: g.status,
            timeArrived: g.timeArrived,
            contributions: g.contributions.map((c) => ({
                type: c.itemType,
                value: `${c.amount} ${c.unit}`,
            })),
        }));
    }
    static async updateGuestStatus(eventId, guestId, hostId, data) {
        const event = await prisma_1.default.event.findFirst({
            where: { id: eventId, hostId, deletedAt: null },
        });
        if (!event)
            throw new Error('Event not found');
        const guestRecord = await prisma_1.default.eventGuest.findFirst({
            where: { eventId, guestId },
        });
        if (!guestRecord)
            throw new Error('Guest record not found');
        const updateData = { status: data.status };
        if (data.status === 'attended') {
            updateData.timeArrived = new Date();
        }
        await prisma_1.default.eventGuest.update({
            where: { id: guestRecord.id },
            data: updateData,
        });
        return { message: `Guest status updated to ${data.status}` };
    }
}
exports.EventsService = EventsService;
