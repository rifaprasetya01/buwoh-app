import prisma from '../../config/prisma';
import { SubmitBuwohInput } from './invitations.schema';

// Helper function to calculate distance using Haversine formula
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371; // Radius of the Earth in km
  const dLat = (lat2 - lat1) * (Math.PI / 180);
  const dLon = (lon2 - lon1) * (Math.PI / 180);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * (Math.PI / 180)) *
      Math.cos(lat2 * (Math.PI / 180)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function getProximityScore(userAddress: any, eventAddress: any): number {
  if (!userAddress || !eventAddress) return 4;

  const normalize = (s?: string | null) => (s ? s.toLowerCase().trim() : '');

  const uVillage = normalize(userAddress.village);
  const uDistrict = normalize(userAddress.district);
  const uCity = normalize(userAddress.city);
  const uProvince = normalize(userAddress.province);

  const eVillage = normalize(eventAddress.village);
  const eDistrict = normalize(eventAddress.district);
  const eCity = normalize(eventAddress.city);
  const eProvince = normalize(eventAddress.province);

  if (uProvince && uProvince === eProvince) {
    if (uCity && uCity === eCity) {
      if (uDistrict && uDistrict === eDistrict) {
        if (uVillage && uVillage === eVillage) {
          return 0; // Satu Desa
        }
        return 1; // Satu Kecamatan
      }
      return 2; // Satu Kota/Kabupaten
    }
    return 3; // Satu Provinsi
  }
  
  return 4; // Data tidak lengkap
}

export class InvitationsService {
  static async listInvitations(guestId: string, search?: string, type?: string) {
    const user = await prisma.user.findUnique({
      where: { id: guestId },
      include: { address: true },
    });

    // 1. Get all events hosted by the current user
    const myEvents = await prisma.event.findMany({
      where: { hostId: guestId, deletedAt: null },
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

    const whereClause: any = {
      status: 'active',
      deletedAt: null,
      hostId: {
        not: guestId,
      },
    };

    if (!search) {
      whereClause.hostId = {
        not: guestId,
        notIn: guestIds,
      };
      whereClause.guests = {
        none: {
          guestId,
          status: { in: ['validated', 'attended'] },
        },
      };
    } else {
      whereClause.OR = [
        { title: { contains: search } },
        { locationName: { contains: search } },
        { host: { name: { contains: search } } }
      ];
    }

    if (type) {
      whereClause.eventType = type;
    }

    const events = await prisma.event.findMany({
      where: whereClause,
      include: {
        host: { select: { name: true } },
        address: true,
        guests: {
          where: { guestId },
          select: { status: true },
        },
      },
    });

    const filteredAndMappedEvents = events.reduce((acc: any[], event: any) => {
      const uProvince = user?.address?.province?.toLowerCase().trim();
      const eProvince = event.address?.province?.toLowerCase().trim();
      
      // Eliminasi luar provinsi (hanya jika keduanya punya provinsi dan berbeda)
      if (uProvince && eProvince && uProvince !== eProvince) {
        return acc;
      }

      let distanceKm = null;
      if (
        user?.address?.latitude &&
        user?.address?.longitude &&
        event.address?.latitude &&
        event.address?.longitude
      ) {
        distanceKm = calculateDistance(
          Number(user.address.latitude),
          Number(user.address.longitude),
          Number(event.address.latitude),
          Number(event.address.longitude)
        );
        distanceKm = Math.round(distanceKm * 10) / 10;
      }

      const proximityScore = getProximityScore(user?.address, event.address);

      const startTimeStr = event.startTime ? event.startTime.toISOString().split('T')[1].substring(0, 5) : null;
      const endTimeStr = event.endTime ? event.endTime.toISOString().split('T')[1].substring(0, 5) : null;
      let timeFormatted = startTimeStr;
      if (startTimeStr && endTimeStr) {
        timeFormatted = `${startTimeStr} - ${endTimeStr}`;
      }

      const hasSubmitted = event.guests && event.guests.length > 0;

      acc.push({
        eventId: event.id,
        type: event.eventType,
        title: event.title,
        hostName: event.host.name,
        date: event.eventDate.toISOString().split('T')[0],
        time: timeFormatted,
        locationName: event.locationName,
        distanceKm,
        imageUrl: event.coverImageUrl,
        isPriority: event.isPriority,
        hasSubmitted,
        proximityScore,
        _rawEventDate: event.eventDate, // Untuk sorting sementara
      });

      return acc;
    }, []);

    // Urutkan berdasarkan: 1. Proximity Score, 2. Tanggal, 3. Jarak
    filteredAndMappedEvents.sort((a: any, b: any) => {
      if (a.proximityScore !== b.proximityScore) {
        return a.proximityScore - b.proximityScore;
      }
      
      const dateDiff = a._rawEventDate.getTime() - b._rawEventDate.getTime();
      if (dateDiff !== 0) {
        return dateDiff;
      }

      if (a.distanceKm !== null && b.distanceKm !== null) {
        return a.distanceKm - b.distanceKm;
      }

      return 0;
    });

    return filteredAndMappedEvents.map((e: any) => {
      delete e._rawEventDate;
      return e;
    });
  }

  static async getInvitationDetails(eventId: string) {
    const event = await prisma.event.findFirst({
      where: { id: eventId, status: 'active', deletedAt: null },
      include: {
        host: { select: { name: true, photoUrl: true } },
        address: true,
        expectedContributions: true,
      },
    });

    if (!event) throw new Error('Event not found');

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
      expectedContributions: event.expectedContributions.map((ec: any) => ec.itemType),
      isPriority: event.isPriority,
    };
  }

  static async submitBuwoh(eventId: string, guestId: string, data: SubmitBuwohInput) {
    // Check if event exists and is active
    const event = await prisma.event.findFirst({
      where: { id: eventId, status: 'active', deletedAt: null },
    });
    if (!event) throw new Error('Event not found or inactive');

    // Check if user is already a guest
    const existingGuest = await prisma.eventGuest.findFirst({
      where: { eventId, guestId },
    });

    if (existingGuest) {
      throw new Error('You have already submitted a buwoh intention for this event');
    }

    // Create Guest record and contributions
    const newGuest = await prisma.eventGuest.create({
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

  static async getMyBuwoh(eventId: string, guestId: string) {
    const event = await prisma.event.findFirst({
      where: { id: eventId, status: 'active', deletedAt: null },
    });
    if (!event) throw new Error('Event not found');

    const submission = await prisma.eventGuest.findFirst({
      where: { eventId, guestId },
      include: { contributions: true },
    });

    if (!submission) {
      throw new Error('Submission not found');
    }

    return {
      status: submission.status,
      eventDate: event.eventDate,
      contributions: submission.contributions.map((c) => ({
        type: c.itemType,
        amount: c.amount,
        unit: c.unit,
        notes: c.notes,
      })),
    };
  }

  static async updateBuwoh(eventId: string, guestId: string, data: SubmitBuwohInput) {
    const event = await prisma.event.findFirst({
      where: { id: eventId, status: 'active', deletedAt: null },
    });
    if (!event) throw new Error('Event not found or inactive');

    const submission = await prisma.eventGuest.findFirst({
      where: { eventId, guestId },
    });

    if (!submission) {
      throw new Error('Submission not found');
    }

    if (submission.status !== 'pending') {
      throw new Error('Cannot edit buwoh. Status is no longer pending.');
    }

    // Check if current date is before event date
    const today = new Date();
    today.setHours(0, 0, 0, 0); // Start of today
    const eDate = new Date(event.eventDate);
    eDate.setHours(0, 0, 0, 0);

    if (today > eDate) { // Or maybe >= ? The user said "Pending dan sebelum hari pelaksanaan", we'll use > eDate so they can edit on the day itself before it starts, or maybe >=. Let's just use "today > eDate".
      throw new Error('Cannot edit buwoh. Today is past the event date.');
    }

    await prisma.eventGuest.update({
      where: { id: submission.id },
      data: {
        contributions: {
          deleteMany: {},
          create: data.contributions.map((c) => ({
            itemType: c.type,
            amount: c.amount,
            unit: c.unit,
            notes: c.notes,
          })),
        },
      },
    });

    return { message: 'Buwoh intention updated successfully.' };
  }
}
