import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF134231);
    const secondary = Color(0xFF436557);
    const tertiary = Color(0xFF705D00);
    const background = Color(0xFFF8FAF8);
    const onSurfaceVariant = Color(0xFF414944);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top App Bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Buwoh',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ───────────────────────────────────────────────
                    const Text(
                      'Notifikasi',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: primary,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pantau kontribusi komunitas dan acara hajatan di sekitarmu.',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Notification List ────────────────────────────────────
                    _NotificationItem(
                      icon: Icons.volunteer_activism,
                      title: 'Pengingat Balas Budi Keluarga Bpk. Hardi',
                      time: '2j',
                      iconBgColor: tertiary.withValues(alpha: 0.1),
                      iconColor: tertiary,
                      borderColor: primary,
                    ),
                    const SizedBox(height: 16),
                    _NotificationItem(
                      icon: Icons.event_available,
                      title: 'Acara Pernikahan Baru di Sekitarmu',
                      time: '5j',
                      iconBgColor: primary.withValues(alpha: 0.1),
                      iconColor: primary,
                      borderColor: primary.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    _NotificationItem(
                      icon: Icons.group_add,
                      title: 'Permintaan Jadi Saksi dari Siti Aminah',
                      time: '09:12',
                      iconBgColor: secondary.withValues(alpha: 0.1),
                      iconColor: secondary,
                      borderColor: primary.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    _NotificationItem(
                      icon: Icons.check_circle,
                      title: 'Kontribusi Bpk. Rahmat Terverifikasi',
                      time: 'Kemarin',
                      iconBgColor: const Color(0xFFD1FAE5), // emerald-100
                      iconColor: const Color(0xFF065F46),   // emerald-800
                      borderColor: primary.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final Color iconBgColor;
  final Color iconColor;
  final Color borderColor;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.time,
    required this.iconBgColor,
    required this.iconColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1B).withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191C1B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF717974),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

