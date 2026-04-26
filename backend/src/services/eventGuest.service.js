const prisma = require('../lib/prisma');
const ApiError = require('../utils/ApiError');

/**
 * Helper: Serialize BigInt
 */
const serializeGuest = (guest) => {
  const s = { ...guest };
  if (s.id) s.id = s.id.toString();
  if (s.eventId) s.eventId = s.eventId.toString();
  if (s.userId) s.userId = s.userId.toString();
  if (s.user) s.user = { ...s.user, id: s.user.id.toString() };
  if (s.guestGifts) {
    s.guestGifts = s.guestGifts.map((g) => ({
      ...g,
      id: g.id.toString(),
      eventGuestId: g.eventGuestId.toString(),
      quantity: parseFloat(g.quantity),
    }));
  }
  return s;
};

/**
 * Apply sebagai tamu ke acara (dengan bawaan)
 * BR-02: Tidak bisa apply ke acara sendiri
 * BR-03: Unique constraint (event_id, user_id) — handled by DB
 * BR-04: Wajib ada minimal 1 gift
 * BR-06: Cek max_guests
 */
const applyAsGuest = async (eventId, userId, { notesFromGuest, gifts }) => {
  const event = await prisma.event.findUnique({
    where: { id: BigInt(eventId) },
  });

  if (!event) throw ApiError.notFound('Acara tidak ditemukan.');

  // Hanya bisa apply ke acara yang published
  if (event.status !== 'published') {
    throw ApiError.badRequest('Hanya bisa mendaftar ke acara yang sudah dipublish.');
  }

  // BR-02: Tidak bisa apply ke acara sendiri
  if (event.userId.toString() === userId.toString()) {
    throw ApiError.badRequest('Tidak bisa mendaftar ke acara milik sendiri.');
  }

  // BR-06: Cek max_guests
  if (event.maxGuests) {
    const acceptedCount = await prisma.eventGuest.count({
      where: {
        eventId: BigInt(eventId),
        applicationStatus: 'accepted',
      },
    });
    if (acceptedCount >= event.maxGuests) {
      throw ApiError.badRequest('Kuota tamu sudah penuh.');
    }
  }

  // BR-04: Minimal 1 gift (sudah di-validate Joi, tapi double check)
  if (!gifts || gifts.length === 0) {
    throw ApiError.badRequest('Wajib mengisi minimal 1 bawaan.');
  }

  // Create event_guest + guest_gifts dalam satu transaksi
  const eventGuest = await prisma.$transaction(async (tx) => {
    const guest = await tx.eventGuest.create({
      data: {
        eventId: BigInt(eventId),
        userId: BigInt(userId),
        notesFromGuest: notesFromGuest || null,
        applicationStatus: 'pending',
      },
    });

    // Create gifts
    const giftData = gifts.map((gift) => ({
      eventGuestId: guest.id,
      giftCategoryId: gift.giftCategoryId,
      quantity: gift.quantity,
      notes: gift.notes || null,
    }));

    await tx.guestGift.createMany({ data: giftData });

    // Return dengan relasi
    return tx.eventGuest.findUnique({
      where: { id: guest.id },
      include: {
        guestGifts: { include: { giftCategory: true } },
        user: { select: { id: true, name: true } },
      },
    });
  });

  // Kirim notifikasi ke pemilik acara
  await prisma.notification.create({
    data: {
      recipientUserId: event.userId,
      senderUserId: BigInt(userId),
      relatedEventId: BigInt(eventId),
      type: 'new_applicant',
      title: 'Pengajuan Tamu Baru 📩',
      message: `Ada tamu baru yang mengajukan diri untuk acara "${event.title}".`,
    },
  });

  return serializeGuest(eventGuest);
};

/**
 * List tamu acara (owner only)
 */
const listEventGuests = async (eventId, userId) => {
  const event = await prisma.event.findUnique({
    where: { id: BigInt(eventId) },
  });

  if (!event) throw ApiError.notFound('Acara tidak ditemukan.');

  // BR-07: Hanya pemilik yang bisa lihat daftar tamu
  if (event.userId.toString() !== userId.toString()) {
    throw ApiError.forbidden('Anda bukan pemilik acara ini.');
  }

  const guests = await prisma.eventGuest.findMany({
    where: { eventId: BigInt(eventId) },
    include: {
      user: {
        select: { id: true, name: true, email: true, phoneNumber: true, profilePhotoUrl: true },
      },
      guestGifts: {
        include: { giftCategory: true },
      },
    },
    orderBy: { appliedAt: 'desc' },
  });

  return guests.map(serializeGuest);
};

/**
 * Terima/tolak pengajuan tamu
 * BR-06: Cek max_guests sebelum menerima
 * BR-07: Hanya pemilik acara
 */
const updateGuestStatus = async (eventId, guestId, userId, { applicationStatus, rejectionReason }) => {
  const event = await prisma.event.findUnique({
    where: { id: BigInt(eventId) },
  });

  if (!event) throw ApiError.notFound('Acara tidak ditemukan.');

  // BR-07: Hanya pemilik acara
  if (event.userId.toString() !== userId.toString()) {
    throw ApiError.forbidden('Anda bukan pemilik acara ini.');
  }

  const guest = await prisma.eventGuest.findUnique({
    where: { id: BigInt(guestId) },
  });

  if (!guest) throw ApiError.notFound('Data tamu tidak ditemukan.');
  if (guest.eventId.toString() !== eventId.toString()) {
    throw ApiError.badRequest('Tamu tidak terdaftar di acara ini.');
  }

  if (guest.applicationStatus !== 'pending') {
    throw ApiError.badRequest('Pengajuan ini sudah direspons sebelumnya.');
  }

  // BR-06: Cek max_guests sebelum accept
  if (applicationStatus === 'accepted' && event.maxGuests) {
    const acceptedCount = await prisma.eventGuest.count({
      where: {
        eventId: BigInt(eventId),
        applicationStatus: 'accepted',
      },
    });
    if (acceptedCount >= event.maxGuests) {
      throw ApiError.badRequest('Kuota tamu sudah penuh. Tidak bisa menerima lagi.');
    }
  }

  const updated = await prisma.eventGuest.update({
    where: { id: BigInt(guestId) },
    data: {
      applicationStatus,
      rejectionReason: applicationStatus === 'rejected' ? (rejectionReason || null) : null,
      respondedAt: new Date(),
    },
    include: {
      user: { select: { id: true, name: true } },
    },
  });

  // Kirim notifikasi ke tamu
  const notifType = applicationStatus === 'accepted'
    ? 'application_accepted'
    : 'application_rejected';
  const notifTitle = applicationStatus === 'accepted'
    ? 'Pengajuan Diterima ✅'
    : 'Pengajuan Ditolak ❌';
  const notifMessage = applicationStatus === 'accepted'
    ? `Pengajuan kamu ke acara "${event.title}" telah diterima!`
    : `Pengajuan kamu ke acara "${event.title}" ditolak.${rejectionReason ? ` Alasan: ${rejectionReason}` : ''}`;

  await prisma.notification.create({
    data: {
      recipientUserId: guest.userId,
      senderUserId: event.userId,
      relatedEventId: BigInt(eventId),
      type: notifType,
      title: notifTitle,
      message: notifMessage,
    },
  });

  return serializeGuest(updated);
};

/**
 * Verifikasi kehadiran tamu (hari-H)
 * BR-07: Hanya pemilik acara
 */
const updateAttendance = async (eventId, guestId, userId, { attendanceStatus }) => {
  const event = await prisma.event.findUnique({
    where: { id: BigInt(eventId) },
  });

  if (!event) throw ApiError.notFound('Acara tidak ditemukan.');

  // BR-07: Hanya pemilik acara
  if (event.userId.toString() !== userId.toString()) {
    throw ApiError.forbidden('Anda bukan pemilik acara ini.');
  }

  const guest = await prisma.eventGuest.findUnique({
    where: { id: BigInt(guestId) },
  });

  if (!guest) throw ApiError.notFound('Data tamu tidak ditemukan.');
  if (guest.applicationStatus !== 'accepted') {
    throw ApiError.badRequest('Hanya tamu yang sudah diterima yang bisa diverifikasi kehadirannya.');
  }

  const updated = await prisma.eventGuest.update({
    where: { id: BigInt(guestId) },
    data: {
      attendanceStatus,
      verifiedAt: new Date(),
    },
    include: {
      user: { select: { id: true, name: true } },
    },
  });

  // Notifikasi ke tamu
  if (attendanceStatus === 'present') {
    await prisma.notification.create({
      data: {
        recipientUserId: guest.userId,
        senderUserId: event.userId,
        relatedEventId: BigInt(eventId),
        type: 'attendance_verified',
        title: 'Kehadiran Diverifikasi ✅',
        message: `Kehadiranmu di acara "${event.title}" telah diverifikasi. Terima kasih!`,
      },
    });
  }

  return serializeGuest(updated);
};

/**
 * Verifikasi bawaan tamu (gift verified)
 * BR-07: Hanya pemilik acara
 */
const verifyGift = async (eventId, guestId, userId) => {
  const event = await prisma.event.findUnique({
    where: { id: BigInt(eventId) },
  });

  if (!event) throw ApiError.notFound('Acara tidak ditemukan.');

  if (event.userId.toString() !== userId.toString()) {
    throw ApiError.forbidden('Anda bukan pemilik acara ini.');
  }

  const guest = await prisma.eventGuest.findUnique({
    where: { id: BigInt(guestId) },
  });

  if (!guest) throw ApiError.notFound('Data tamu tidak ditemukan.');

  const updated = await prisma.eventGuest.update({
    where: { id: BigInt(guestId) },
    data: { giftVerified: true },
    include: {
      user: { select: { id: true, name: true } },
      guestGifts: { include: { giftCategory: true } },
    },
  });

  return serializeGuest(updated);
};

module.exports = {
  applyAsGuest,
  listEventGuests,
  updateGuestStatus,
  updateAttendance,
  verifyGift,
};
