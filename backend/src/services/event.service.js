const prisma = require('../lib/prisma');
const ApiError = require('../utils/ApiError');

/**
 * Helper: Serialize BigInt fields in event objects
 */
const serializeEvent = (event) => {
  const serialized = { ...event };
  if (serialized.id) serialized.id = serialized.id.toString();
  if (serialized.userId) serialized.userId = serialized.userId.toString();
  if (serialized.locationLat) serialized.locationLat = parseFloat(serialized.locationLat);
  if (serialized.locationLng) serialized.locationLng = parseFloat(serialized.locationLng);

  // Serialize nested relations
  if (serialized.user) {
    serialized.user = { ...serialized.user, id: serialized.user.id.toString() };
  }
  if (serialized.eventGuests) {
    serialized.eventGuests = serialized.eventGuests.map((g) => ({
      ...g,
      id: g.id.toString(),
    }));
  }
  if (serialized._count) {
    serialized._count = serialized._count;
  }
  return serialized;
};

/**
 * BR-01: Cek overlap jadwal acara untuk user yang sama
 */
const checkScheduleOverlap = async (userId, startDatetime, endDatetime, excludeEventId = null) => {
  const where = {
    userId: BigInt(userId),
    status: { not: 'cancelled' },
    startDatetime: { lt: new Date(endDatetime) },
    endDatetime: { gt: new Date(startDatetime) },
  };

  if (excludeEventId) {
    where.id = { not: BigInt(excludeEventId) };
  }

  const overlapping = await prisma.event.findFirst({ where });
  if (overlapping) {
    throw ApiError.conflict(
      `Jadwal bertabrakan dengan acara "${overlapping.title}" (${overlapping.startDatetime.toISOString()} - ${overlapping.endDatetime.toISOString()}).`
    );
  }
};

/**
 * Buat acara baru
 */
const createEvent = async (userId, data) => {
  // BR-01: Cek overlap
  await checkScheduleOverlap(userId, data.startDatetime, data.endDatetime);

  // Verify category exists
  const category = await prisma.eventCategory.findUnique({
    where: { id: data.eventCategoryId },
  });
  if (!category) {
    throw ApiError.notFound('Kategori acara tidak ditemukan.');
  }

  const event = await prisma.event.create({
    data: {
      userId: BigInt(userId),
      eventCategoryId: data.eventCategoryId,
      title: data.title,
      description: data.description || null,
      locationName: data.locationName,
      locationAddress: data.locationAddress,
      locationLat: data.locationLat || null,
      locationLng: data.locationLng || null,
      startDatetime: new Date(data.startDatetime),
      endDatetime: new Date(data.endDatetime),
      maxGuests: data.maxGuests || null,
      coverImageUrl: data.coverImageUrl || null,
      status: 'draft',
    },
    include: {
      eventCategory: true,
    },
  });

  return serializeEvent(event);
};

/**
 * List acara publik (published)
 */
const listPublicEvents = async ({ page, limit, status, categoryId, search }) => {
  const where = {};

  // Default: hanya tampilkan yang published
  where.status = status || 'published';

  if (categoryId) {
    where.eventCategoryId = categoryId;
  }

  if (search) {
    where.OR = [
      { title: { contains: search } },
      { locationName: { contains: search } },
    ];
  }

  const skip = (page - 1) * limit;

  const [events, total] = await Promise.all([
    prisma.event.findMany({
      where,
      skip,
      take: limit,
      orderBy: { startDatetime: 'desc' },
      include: {
        eventCategory: true,
        user: {
          select: { id: true, name: true, profilePhotoUrl: true },
        },
        _count: {
          select: { eventGuests: true },
        },
      },
    }),
    prisma.event.count({ where }),
  ]);

  return {
    events: events.map(serializeEvent),
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
};

/**
 * List acara milik user (dashboard)
 */
const listMyEvents = async (userId, { page, limit, status }) => {
  const where = { userId: BigInt(userId) };
  if (status) where.status = status;

  const skip = (page - 1) * limit;

  const [events, total] = await Promise.all([
    prisma.event.findMany({
      where,
      skip,
      take: limit,
      orderBy: { startDatetime: 'desc' },
      include: {
        eventCategory: true,
        _count: {
          select: { eventGuests: true },
        },
      },
    }),
    prisma.event.count({ where }),
  ]);

  return {
    events: events.map(serializeEvent),
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
};

/**
 * Get event detail by ID
 */
const getEventById = async (eventId) => {
  const event = await prisma.event.findUnique({
    where: { id: BigInt(eventId) },
    include: {
      eventCategory: true,
      user: {
        select: { id: true, name: true, profilePhotoUrl: true },
      },
      giftRecommendations: {
        include: { giftCategory: true },
      },
      _count: {
        select: { eventGuests: true },
      },
    },
  });

  if (!event) {
    throw ApiError.notFound('Acara tidak ditemukan.');
  }

  return serializeEvent(event);
};

/**
 * Update acara (hanya owner)
 */
const updateEvent = async (eventId, userId, data) => {
  const event = await prisma.event.findUnique({
    where: { id: BigInt(eventId) },
  });

  if (!event) throw ApiError.notFound('Acara tidak ditemukan.');
  if (event.userId.toString() !== userId.toString()) {
    throw ApiError.forbidden('Anda bukan pemilik acara ini.');
  }

  // BR-01: Cek overlap jika tanggal berubah
  const newStart = data.startDatetime || event.startDatetime;
  const newEnd = data.endDatetime || event.endDatetime;
  if (data.startDatetime || data.endDatetime) {
    await checkScheduleOverlap(userId, newStart, newEnd, eventId);
  }

  const updated = await prisma.event.update({
    where: { id: BigInt(eventId) },
    data: {
      ...(data.eventCategoryId && { eventCategoryId: data.eventCategoryId }),
      ...(data.title && { title: data.title }),
      ...(data.description !== undefined && { description: data.description || null }),
      ...(data.locationName && { locationName: data.locationName }),
      ...(data.locationAddress && { locationAddress: data.locationAddress }),
      ...(data.locationLat !== undefined && { locationLat: data.locationLat }),
      ...(data.locationLng !== undefined && { locationLng: data.locationLng }),
      ...(data.startDatetime && { startDatetime: new Date(data.startDatetime) }),
      ...(data.endDatetime && { endDatetime: new Date(data.endDatetime) }),
      ...(data.maxGuests !== undefined && { maxGuests: data.maxGuests }),
      ...(data.coverImageUrl !== undefined && { coverImageUrl: data.coverImageUrl || null }),
    },
    include: { eventCategory: true },
  });

  return serializeEvent(updated);
};

/**
 * Update status acara + trigger notifikasi balas budi saat publish
 */
const updateStatus = async (eventId, userId, newStatus) => {
  const event = await prisma.event.findUnique({
    where: { id: BigInt(eventId) },
  });

  if (!event) throw ApiError.notFound('Acara tidak ditemukan.');
  if (event.userId.toString() !== userId.toString()) {
    throw ApiError.forbidden('Anda bukan pemilik acara ini.');
  }

  // Validasi transisi status
  const validTransitions = {
    draft: ['published', 'cancelled'],
    published: ['ongoing', 'cancelled'],
    ongoing: ['completed', 'cancelled'],
    completed: [],
    cancelled: [],
  };

  if (!validTransitions[event.status]?.includes(newStatus)) {
    throw ApiError.badRequest(
      `Tidak bisa mengubah status dari "${event.status}" ke "${newStatus}".`
    );
  }

  const updated = await prisma.event.update({
    where: { id: BigInt(eventId) },
    data: { status: newStatus },
    include: { eventCategory: true },
  });

  // Trigger notifikasi balas budi ketika publish (draft → published)
  if (event.status === 'draft' && newStatus === 'published') {
    await triggerBalasBudiNotifications(event.userId, BigInt(eventId));
  }

  return serializeEvent(updated);
};

/**
 * Trigger Balas Budi Notifications
 * Cari semua user yang pernah hadir di acara milik userId
 * dan buat notifikasi "balas_budi" untuk mereka
 */
const triggerBalasBudiNotifications = async (eventOwnerId, newEventId) => {
  // Cari semua user yang pernah present di acara milik owner
  const pastGuests = await prisma.eventGuest.findMany({
    where: {
      event: { userId: eventOwnerId },
      attendanceStatus: 'present',
      userId: { not: eventOwnerId },
    },
    select: { userId: true },
    distinct: ['userId'],
  });

  if (pastGuests.length === 0) return;

  // Get event details untuk pesan notifikasi
  const newEvent = await prisma.event.findUnique({
    where: { id: newEventId },
    select: { title: true },
  });

  const ownerUser = await prisma.user.findUnique({
    where: { id: eventOwnerId },
    select: { name: true },
  });

  // Buat notifikasi untuk setiap past guest
  const notifications = pastGuests.map((guest) => ({
    recipientUserId: guest.userId,
    senderUserId: eventOwnerId,
    relatedEventId: newEventId,
    type: 'balas_budi',
    title: 'Waktunya Balas Budi! 🤝',
    message: `${ownerUser.name} baru saja membuat acara "${newEvent.title}". Kamu pernah hadir di acaranya. Waktunya balas budi!`,
    isRead: false,
  }));

  await prisma.notification.createMany({ data: notifications });
};

/**
 * Delete event (hanya draft)
 */
const deleteEvent = async (eventId, userId) => {
  const event = await prisma.event.findUnique({
    where: { id: BigInt(eventId) },
  });

  if (!event) throw ApiError.notFound('Acara tidak ditemukan.');
  if (event.userId.toString() !== userId.toString()) {
    throw ApiError.forbidden('Anda bukan pemilik acara ini.');
  }

  if (event.status !== 'draft') {
    throw ApiError.badRequest('Hanya acara berstatus "draft" yang bisa dihapus.');
  }

  await prisma.event.delete({ where: { id: BigInt(eventId) } });
};

module.exports = {
  createEvent,
  listPublicEvents,
  listMyEvents,
  getEventById,
  updateEvent,
  updateStatus,
  deleteEvent,
};
