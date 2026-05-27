"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.InvitationsService = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
// Helper function to calculate distance using Haversine formula
function calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Radius of the Earth in km
    const dLat = (lat2 - lat1) * (Math.PI / 180);
    const dLon = (lon2 - lon1) * (Math.PI / 180);
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * (Math.PI / 180)) *
            Math.cos(lat2 * (Math.PI / 180)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}
class InvitationsService {
    static async listInvitations(guestId, search, type) {
        const user = await prisma_1.default.user.findUnique({
            where: { id: guestId },
            include: { address: true },
        });
        const whereClause = {
            hostId: { not: guestId },
            status: 'active',
            deletedAt: null,
        };
        if (search) {
            whereClause.title = { contains: search };
        }
        if (type) {
            whereClause.eventType = type;
        }
        const events = await prisma_1.default.event.findMany({
            where: whereClause,
            include: {
                host: { select: { name: true } },
                address: true,
            },
            orderBy: { eventDate: 'asc' },
        });
        return events.map((event) => {
            let distanceKm = null;
            // Calculate distance if both user and event have coordinates
            if (user?.address?.latitude &&
                user?.address?.longitude &&
                event.address?.latitude &&
                event.address?.longitude) {
                distanceKm = calculateDistance(Number(user.address.latitude), Number(user.address.longitude), Number(event.address.latitude), Number(event.address.longitude));
                distanceKm = Math.round(distanceKm * 10) / 10; // Round to 1 decimal place
            }
            return {
                eventId: event.id,
                type: event.eventType,
                title: event.title,
                hostName: event.host.name,
                date: event.eventDate.toISOString().split('T')[0],
                time: event.startTime ? event.startTime.toISOString().split('T')[1].substring(0, 5) : null,
                locationName: event.locationName,
                distanceKm,
                imageUrl: event.coverImageUrl,
                isPriority: event.isPriority,
            };
        });
    }
    static async getInvitationDetails(eventId) {
        const event = await prisma_1.default.event.findFirst({
            where: { id: eventId, status: 'active', deletedAt: null },
            include: {
                host: { select: { name: true, photoUrl: true } },
                address: true,
                expectedContributions: true,
            },
        });
        if (!event)
            throw new Error('Event not found');
        return {
            eventId: event.id,
            title: event.title,
            type: event.eventType,
            hostName: event.host.name,
            hostAvatarUrl: event.host.photoUrl,
            date: event.eventDate.toISOString().split('T')[0],
            startTime: event.startTime ? event.startTime.toISOString().split('T')[1].substring(0, 5) : null,
            endTime: event.endTime ? event.endTime.toISOString().split('T')[1].substring(0, 5) : null,
            locationName: event.locationName,
            address: event.address,
            mapLink: event.mapLink,
            description: event.description,
            imageUrl: event.coverImageUrl,
            expectedContributions: event.expectedContributions.map((ec) => ec.itemType),
        };
    }
    static async submitBuwoh(eventId, guestId, data) {
        // Check if event exists and is active
        const event = await prisma_1.default.event.findFirst({
            where: { id: eventId, status: 'active', deletedAt: null },
        });
        if (!event)
            throw new Error('Event not found or inactive');
        // Check if user is already a guest
        const existingGuest = await prisma_1.default.eventGuest.findFirst({
            where: { eventId, guestId },
        });
        if (existingGuest) {
            throw new Error('You have already submitted a buwoh intention for this event');
        }
        // Create Guest record and contributions
        const newGuest = await prisma_1.default.eventGuest.create({
            data: {
                eventId,
                guestId,
                status: 'pending',
                contributions: {
                    create: data.contributions.map((c) => ({
                        itemType: c.type,
                        amount: c.amount,
                        unit: c.unit,
                        notes: c.notes,
                    })),
                },
            },
        });
        return { message: 'Buwoh intention submitted successfully. Waiting for host validation.' };
    }
}
exports.InvitationsService = InvitationsService;
