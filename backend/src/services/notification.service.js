const prisma = require('../lib/prisma');
const ApiError = require('../utils/ApiError');

/**
 * Helper: Serialize
 */
const serializeNotification = (notif) => ({
  ...notif,
  id: notif.id.toString(),
  recipientUserId: notif.recipientUserId.toString(),
  senderUserId: notif.senderUserId?.toString() || null,
  relatedEventId: notif.relatedEventId?.toString() || null,
});

/**
 * List notifikasi milik user
 */
const listNotifications = async (userId, { page, limit, isRead, type }) => {
  const where = { recipientUserId: BigInt(userId) };

  if (isRead !== undefined) {
    where.isRead = isRead;
  }
  if (type) {
    where.type = type;
  }

  const skip = (page - 1) * limit;

  const [notifications, total, unreadCount] = await Promise.all([
    prisma.notification.findMany({
      where,
      skip,
      take: limit,
      orderBy: { createdAt: 'desc' },
      include: {
        sender: {
          select: { id: true, name: true, profilePhotoUrl: true },
        },
        relatedEvent: {
          select: { id: true, title: true },
        },
      },
    }),
    prisma.notification.count({ where }),
    prisma.notification.count({
      where: { recipientUserId: BigInt(userId), isRead: false },
    }),
  ]);

  return {
    notifications: notifications.map((n) => {
      const s = serializeNotification(n);
      if (s.sender) s.sender = { ...s.sender, id: s.sender.id.toString() };
      if (s.relatedEvent) s.relatedEvent = { ...s.relatedEvent, id: s.relatedEvent.id.toString() };
      return s;
    }),
    unreadCount,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
};

/**
 * Tandai notifikasi sudah dibaca
 */
const markAsRead = async (notificationId, userId) => {
  const notif = await prisma.notification.findUnique({
    where: { id: BigInt(notificationId) },
  });

  if (!notif) throw ApiError.notFound('Notifikasi tidak ditemukan.');
  if (notif.recipientUserId.toString() !== userId.toString()) {
    throw ApiError.forbidden('Bukan notifikasi milik Anda.');
  }

  const updated = await prisma.notification.update({
    where: { id: BigInt(notificationId) },
    data: {
      isRead: true,
      readAt: new Date(),
    },
  });

  return serializeNotification(updated);
};

/**
 * Tandai semua notifikasi sudah dibaca
 */
const markAllAsRead = async (userId) => {
  await prisma.notification.updateMany({
    where: {
      recipientUserId: BigInt(userId),
      isRead: false,
    },
    data: {
      isRead: true,
      readAt: new Date(),
    },
  });
};

module.exports = {
  listNotifications,
  markAsRead,
  markAllAsRead,
};
