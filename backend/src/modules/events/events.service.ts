import prisma from '../../config/prisma';
import { CreateEventInput, UpdateGuestStatusInput, AddManualGuestInput } from './events.schema';

export class EventsService {
  static async listHostedEvents(hostId: string, status?: string) {
    const whereClause: any = { hostId, deletedAt: null };
    if (status) {
      whereClause.status = status;
    }

    const events = await prisma.event.findMany({
      where: whereClause,
      include: {
        _count: {
          select: { guests: true },
        },
      },
      orderBy: { eventDate: 'desc' },
    });

    // Formatting response to match API contract
    return Promise.all(
      events.map(async (event: any) => {
        const guestsAttended = await prisma.eventGuest.count({
          where: { eventId: event.id, status: 'attended' },
        });

        const guestsExpected = await prisma.eventGuest.count({
          where: { eventId: event.id, status: { in: ['attended', 'validated'] } },
        });

        const totalGuests = event._count.guests;
        const progressPercentage = guestsExpected === 0 ? 0 : Math.round((guestsAttended / guestsExpected) * 100);

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
          guestsExpected,
          guestsTotal: totalGuests,
          progressPercentage,
        };
      })
    );
  }

  static async createEvent(hostId: string, data: CreateEventInput, coverImageUrl?: string) {
    let addressId: string | undefined;

    if (data.address) {
      const newAddress = await prisma.address.create({
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

    const newEvent = await prisma.event.create({
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
      await prisma.eventExpectedContribution.createMany({
        data: contributionsData,
      });
    }

    return newEvent;
  }

  static async getEventRecap(eventId: string, hostId: string) {
    const event = await prisma.event.findFirst({
      where: { id: eventId, hostId, deletedAt: null },
    });

    if (!event) throw new Error('Event not found');

    const guests = await prisma.eventGuest.findMany({
      where: { eventId },
      include: {
        guest: { select: { id: true, name: true, photoUrl: true } },
        contributions: true,
      },
    });

    // Aggregate contributions (simplified logic for Recap)
    const summary: any = {};
    const formattedGuests = guests.map((g: any) => {
      // Build summary
      g.contributions.forEach((c: any) => {
        const key = c.itemType; // 'uang', 'beras', etc.
        if (!summary[key]) summary[key] = 0;
        summary[key] += Number(c.amount);
      });

      return {
        guestId: g.guest.id,
        name: g.guest.name,
        avatarUrl: g.guest.photoUrl,
        status: g.status,
        timeArrived: g.timeArrived,
        contributions: g.contributions.map((c: any) => ({
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

  static async listEventGuests(eventId: string, hostId: string, status?: string) {
    const event = await prisma.event.findFirst({
      where: { id: eventId, hostId, deletedAt: null },
    });
    if (!event) throw new Error('Event not found');

    const whereClause: any = { eventId };
    if (status) whereClause.status = status;

    const guests = await prisma.eventGuest.findMany({
      where: whereClause,
      include: {
        guest: { select: { id: true, name: true } },
        contributions: true,
      },
    });

    return guests.map((g: any) => ({
      guestId: g.guest.id,
      name: g.guest.name,
      status: g.status,
      timeArrived: g.timeArrived,
      contributions: g.contributions.map((c: any) => ({
        type: c.itemType,
        value: `${c.amount} ${c.unit}`,
      })),
    }));
  }

  static async updateGuestStatus(eventId: string, guestId: string, hostId: string, data: UpdateGuestStatusInput) {
    const event = await prisma.event.findFirst({
      where: { id: eventId, hostId, deletedAt: null },
    });
    if (!event) throw new Error('Event not found');

    const guestRecord = await prisma.eventGuest.findFirst({
      where: { eventId, guestId },
    });

    if (!guestRecord) throw new Error('Guest record not found');

    const updateData: any = { status: data.status };
    if (data.status === 'attended') {
      updateData.timeArrived = new Date();
    }

    await prisma.eventGuest.update({
      where: { id: guestRecord.id },
      data: updateData,
    });

    return { message: `Guest status updated to ${data.status}` };
  }

  static async listReturnFavorEvents(userId: string) {
    // 1. Get all events hosted by the current user
    const myEvents = await prisma.event.findMany({
      where: { hostId: userId, deletedAt: null },
      select: { id: true },
    });
    const myEventIds = myEvents.map((e) => e.id);

    // 2. Get all guests who attended those events
    const myGuests = await prisma.eventGuest.findMany({
      where: {
        eventId: { in: myEventIds },
        status: { in: ['attended', 'validated'] },
      },
      select: { guestId: true },
    });
    const guestIds = Array.from(new Set(myGuests.map((g) => g.guestId)));

    // 3. Find active events hosted by those guests
    const returnFavorEvents = await prisma.event.findMany({
      where: {
        hostId: { in: guestIds },
        status: 'active',
        deletedAt: null,
      },
      orderBy: { eventDate: 'asc' },
    });

    return returnFavorEvents.map((event: any) => ({
      id: event.id,
      title: event.title,
      type: event.eventType,
      locationName: event.locationName,
      date: event.eventDate.toISOString().split('T')[0],
      imageUrl: event.coverImageUrl,
      status: event.status,
    }));
  }

  static async addManualGuest(eventId: string, hostId: string, data: AddManualGuestInput) {
    // Check if event exists and belongs to host
    const event = await prisma.event.findFirst({
      where: { id: eventId, hostId, deletedAt: null },
    });
    if (!event) throw new Error('Acara tidak ditemukan atau Anda tidak berwenang');

    // Find the guest user by email
    const guestUser = await prisma.user.findUnique({
      where: { email: data.email },
    });
    if (!guestUser) throw new Error('Pengguna dengan email tersebut tidak ditemukan di database');

    if (guestUser.id === hostId) {
      throw new Error('Anda tidak bisa menambahkan diri sendiri sebagai tamu');
    }

    // Check if guest is already added
    const existingGuest = await prisma.eventGuest.findFirst({
      where: { eventId, guestId: guestUser.id },
    });
    if (existingGuest) {
      throw new Error('Tamu ini sudah terdaftar di dalam acara ini');
    }

    // Create guest record and their contributions
    const newGuest = await prisma.eventGuest.create({
      data: {
        eventId,
        guestId: guestUser.id,
        status: 'validated', // Manual additions are automatically validated
        contributions: {
          create: data.contributions.map((c) => ({
            itemType: c.type,
            amount: c.amount,
            unit: c.unit,
            notes: c.notes,
          })),
        },
      },
      include: {
        guest: { select: { name: true } },
        contributions: true,
      },
    });

    return {
      message: 'Tamu manual berhasil ditambahkan',
      guest: {
        guestId: newGuest.guestId,
        name: newGuest.guest.name,
        status: newGuest.status,
        contributions: newGuest.contributions.map((c) => ({
          type: c.itemType,
          value: `${c.amount} ${c.unit}`,
        })),
      },
    };
  }
}
