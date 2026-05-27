import prisma from '../../config/prisma';

export class HistoryService {
  static async getHistory(guestId: string, filter?: string) {
    const whereClause: any = {
      guestId,
      deletedAt: null,
    };

    if (filter && filter !== 'Semua') {
      const lowerFilter = filter.toLowerCase();
      whereClause.contributions = {
        some: {
          itemType: lowerFilter,
        },
      };
    }

    const histories = await prisma.eventGuest.findMany({
      where: whereClause,
      include: {
        event: {
          include: { host: { select: { name: true } } },
        },
        contributions: true,
      },
      orderBy: { createdAt: 'desc' },
    });

    return histories.map((h: any) => ({
      historyId: h.id,
      eventId: h.event.id,
      title: h.event.title,
      hostName: h.event.host.name,
      date: h.event.eventDate.toISOString().split('T')[0],
      locationName: h.event.locationName,
      type: h.event.eventType,
      status: h.status,
      isPriority: h.event.isPriority,
      contributions: h.contributions.map((c: any) => ({
        type: c.itemType,
        value: `${c.amount} ${c.unit}`,
      })),
    }));
  }

  static async getHistoryDetails(historyId: string, guestId: string) {
    const history = await prisma.eventGuest.findFirst({
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

    if (!history) throw new Error('History record not found');

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
      contributions: history.contributions.map((c: any) => ({
        type: c.itemType,
        value: `${c.amount} ${c.unit}`,
        notes: c.notes,
      })),
    };
  }
}
