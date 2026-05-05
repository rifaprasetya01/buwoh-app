const prisma = require('../lib/prisma');
const ApiError = require('../utils/ApiError');

/**
 * Helper: Fungsi Haversine untuk menghitung jarak antara 2 koordinat (dalam km)
 */
const calculateDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371; // Radius bumi dalam km
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
};

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

  // --- UI Formatting (Backend Follows Frontend) ---
  const dStart = new Date(serialized.startDatetime);
  const dEnd = new Date(serialized.endDatetime);
  
  const formatterTanggal = new Intl.DateTimeFormat('id-ID', { weekday: 'long', day: '2-digit', month: 'short', year: 'numeric' });
  const formatterWaktu = new Intl.DateTimeFormat('id-ID', { hour: '2-digit', minute: '2-digit' });
  
  const formattedTanggal = formatterTanggal.format(dStart);
  let formattedWaktuStart = formatterWaktu.format(dStart).replace(':', '.');
  let formattedWaktuEnd = formatterWaktu.format(dEnd).replace(':', '.');
  
  let lokasiDisplay = `${serialized.locationName} • - km`;
  if (serialized.distanceKm !== undefined) {
    lokasiDisplay = `${serialized.locationName} • ${serialized.distanceKm.toFixed(1)}km`;
  }
  
  serialized.ui = {
    jenis: serialized.eventCategory?.name || 'Acara',
    jenisColor: serialized.eventCategory?.name === 'Pernikahan' ? 0xFF705D00 : 0xFF134231,
    nama: serialized.title,
    host: serialized.user?.name || 'Tuan Rumah',
    tanggal: formattedTanggal,
    waktu: `${formattedWaktuStart} - ${formattedWaktuEnd} WIB`,
    lokasi: serialized.locationName,
    lokasiDisplay: lokasiDisplay,
    imageUrl: serialized.coverImageUrl || 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=300',
    isBalasBudi: false, // Default false, will be overridden if true
    tag: serialized.eventCategory?.name || 'Acara'
  };

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

  // Create event + gift recommendations dalam satu transaksi
  const event = await prisma.$transaction(async (tx) => {
    const newEvent = await tx.event.create({
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
    });

    // Create gift recommendations jika ada
    if (data.giftRecommendations && data.giftRecommendations.length > 0) {
      const recData = data.giftRecommendations.map((rec) => ({
        eventId: newEvent.id,
        giftCategoryId: rec.giftCategoryId,
        suggestedQuantity: rec.suggestedQuantity || null,
        notes: rec.notes || null,
      }));
      await tx.eventGiftRecommendation.createMany({ data: recData });
    }

    // Return with relations
    return tx.event.findUnique({
      where: { id: newEvent.id },
      include: {
        eventCategory: true,
        giftRecommendations: {
          include: { giftCategory: true },
        },
      },
    });
  });

  return serializeEvent(event);
};

/**
 * List acara publik (published)
 */
const listPublicEvents = async ({ page = 1, limit = 10, status, categoryId, search, upcoming, lat, lng }) => {
  const where = {};
  page = parseInt(page) || 1;
  limit = parseInt(limit) || 10;

  // Default: hanya tampilkan yang published
  where.status = status || 'published';

  if (upcoming === 'true' || upcoming === true) {
    const now = Date.now();
    const nextWeek = new Date(now + 7 * 24 * 60 * 60 * 1000);
    const yesterday = new Date(now - 1 * 24 * 60 * 60 * 1000);
    
    where.startDatetime = { lte: nextWeek };
    where.endDatetime = { gte: yesterday };
  }

  if (categoryId) {
    where.eventCategoryId = parseInt(categoryId);
  }

  if (search) {
    where.OR = [
      { title: { contains: search } },
      { locationName: { contains: search } },
    ];
  }

  let events = await prisma.event.findMany({
    where,
    orderBy: { startDatetime: 'asc' }, // By default sort by date for upcoming
    include: {
      eventCategory: true,
      user: {
        select: { id: true, name: true, profilePhotoUrl: true },
      },
      _count: {
        select: { eventGuests: true },
      },
    },
  });

  // Calculate distance if lat and lng are provided
  if (lat !== undefined && lng !== undefined) {
    const userLat = parseFloat(lat);
    const userLng = parseFloat(lng);
    
    events = events.map(evt => {
      const eLat = parseFloat(evt.locationLat);
      const eLng = parseFloat(evt.locationLng);
      
      if (!isNaN(eLat) && !isNaN(eLng)) {
        evt.distanceKm = calculateDistance(userLat, userLng, eLat, eLng);
      }
      return evt;
    });

    // Sort by distance
    events.sort((a, b) => {
      const distA = a.distanceKm ?? Infinity;
      const distB = b.distanceKm ?? Infinity;
      if (distA !== distB) return distA - distB;
      return new Date(a.startDatetime) - new Date(b.startDatetime);
    });
  } else {
    // If no lat/lng, sort by date descending for normal list, ascending for upcoming
    events.sort((a, b) => {
      if (upcoming === 'true' || upcoming === true) {
         return new Date(a.startDatetime) - new Date(b.startDatetime);
      }
      return new Date(b.startDatetime) - new Date(a.startDatetime);
    });
  }

  // Manual pagination after sorting
  const total = events.length;
  const skip = (page - 1) * limit;
  const paginatedEvents = events.slice(skip, skip + limit);

  return {
    events: paginatedEvents.map(serializeEvent),
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
