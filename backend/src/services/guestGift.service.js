const prisma = require('../lib/prisma');
const ApiError = require('../utils/ApiError');

/**
 * Helper: Serialize
 */
const serializeGift = (gift) => ({
  ...gift,
  id: gift.id.toString(),
  eventGuestId: gift.eventGuestId.toString(),
  quantity: parseFloat(gift.quantity),
});

/**
 * BR-05: Cek apakah bawaan masih bisa diubah (hanya saat status pending)
 */
const checkEditableGuest = async (guestId) => {
  const guest = await prisma.eventGuest.findUnique({
    where: { id: BigInt(guestId) },
  });

  if (!guest) throw ApiError.notFound('Data tamu tidak ditemukan.');

  if (guest.applicationStatus !== 'pending') {
    throw ApiError.badRequest(
      'Bawaan tidak bisa diubah setelah pengajuan diterima/ditolak.'
    );
  }

  return guest;
};

/**
 * Tambah bawaan ke pengajuan
 * BR-05: Hanya saat pending
 * BR-08: quantity > 0 (validated by Joi + DB)
 */
const addGift = async (guestId, userId, data) => {
  const guest = await checkEditableGuest(guestId);

  // Pastikan user adalah pemilik pengajuan
  if (guest.userId.toString() !== userId.toString()) {
    throw ApiError.forbidden('Anda bukan pemilik pengajuan ini.');
  }

  // Verify gift category exists
  const category = await prisma.giftCategory.findUnique({
    where: { id: data.giftCategoryId },
  });
  if (!category) {
    throw ApiError.notFound('Kategori bawaan tidak ditemukan.');
  }

  const gift = await prisma.guestGift.create({
    data: {
      eventGuestId: BigInt(guestId),
      giftCategoryId: data.giftCategoryId,
      quantity: data.quantity,
      notes: data.notes || null,
    },
    include: { giftCategory: true },
  });

  return serializeGift(gift);
};

/**
 * List bawaan milik satu pengajuan
 */
const listGifts = async (guestId) => {
  const guest = await prisma.eventGuest.findUnique({
    where: { id: BigInt(guestId) },
  });

  if (!guest) throw ApiError.notFound('Data tamu tidak ditemukan.');

  const gifts = await prisma.guestGift.findMany({
    where: { eventGuestId: BigInt(guestId) },
    include: { giftCategory: true },
    orderBy: { createdAt: 'asc' },
  });

  return gifts.map(serializeGift);
};

/**
 * Update bawaan
 * BR-05: Hanya saat pending
 */
const updateGift = async (guestId, giftId, userId, data) => {
  const guest = await checkEditableGuest(guestId);

  if (guest.userId.toString() !== userId.toString()) {
    throw ApiError.forbidden('Anda bukan pemilik pengajuan ini.');
  }

  const gift = await prisma.guestGift.findUnique({
    where: { id: BigInt(giftId) },
  });

  if (!gift) throw ApiError.notFound('Bawaan tidak ditemukan.');
  if (gift.eventGuestId.toString() !== guestId.toString()) {
    throw ApiError.badRequest('Bawaan tidak terdaftar di pengajuan ini.');
  }

  const updated = await prisma.guestGift.update({
    where: { id: BigInt(giftId) },
    data: {
      ...(data.giftCategoryId && { giftCategoryId: data.giftCategoryId }),
      ...(data.quantity && { quantity: data.quantity }),
      ...(data.notes !== undefined && { notes: data.notes || null }),
    },
    include: { giftCategory: true },
  });

  return serializeGift(updated);
};

/**
 * Hapus bawaan
 * BR-05: Hanya saat pending
 */
const deleteGift = async (guestId, giftId, userId) => {
  const guest = await checkEditableGuest(guestId);

  if (guest.userId.toString() !== userId.toString()) {
    throw ApiError.forbidden('Anda bukan pemilik pengajuan ini.');
  }

  const gift = await prisma.guestGift.findUnique({
    where: { id: BigInt(giftId) },
  });

  if (!gift) throw ApiError.notFound('Bawaan tidak ditemukan.');
  if (gift.eventGuestId.toString() !== guestId.toString()) {
    throw ApiError.badRequest('Bawaan tidak terdaftar di pengajuan ini.');
  }

  // Pastikan masih ada gift lain setelah delete (BR-04)
  const giftCount = await prisma.guestGift.count({
    where: { eventGuestId: BigInt(guestId) },
  });

  if (giftCount <= 1) {
    throw ApiError.badRequest('Tidak bisa menghapus bawaan terakhir. Minimal harus ada 1 bawaan.');
  }

  await prisma.guestGift.delete({ where: { id: BigInt(giftId) } });
};

module.exports = {
  addGift,
  listGifts,
  updateGift,
  deleteGift,
};
