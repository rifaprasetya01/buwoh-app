import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../models/event_model.dart';
import 'create_event_screen.dart';
import 'invitation_detail_screen.dart';
import 'invitations_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // Color Tokens (accessible from child widgets)
  static const primary = Color(0xFF134231);
  static const primaryContainer = Color(0xFF2D5A47);
  static const onSurface = Color(0xFF191C1B);
  static const onSurfaceVariant = Color(0xFF414944);
  static const outlineVariant = Color(0xFFC0C8C2);
  static const surfaceContainerLow = Color(0xFFF2F4F2);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const background = Color(0xFFF8FAF8);
  static const tertiary = Color(0xFF705D00);
  static const tertiaryContainer = Color(0xFFC9A900);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchEvents();
      context.read<EventProvider>().fetchUpcomingEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeScreen.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top App Bar ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: HomeScreen.primaryContainer,
                              image: context.watch<AuthProvider>().userPhotoUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(context.watch<AuthProvider>().userPhotoUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: context.watch<AuthProvider>().userPhotoUrl == null
                                ? const Icon(Icons.person, color: Colors.white, size: 22)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.watch<AuthProvider>().userName,
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: HomeScreen.onSurface,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: HomeScreen.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        context.watch<AuthProvider>().userAddress.isNotEmpty
                                            ? context.watch<AuthProvider>().userAddress
                                            : 'Belum diatur',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 11,
                                          color: HomeScreen.onSurfaceVariant.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.tune_outlined,
                              color: HomeScreen.onSurface,
                              size: 22,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Keluar'),
                                  content: const Text('Yakin ingin keluar dari akun?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(ctx);
                                        await context.read<AuthProvider>().logout();
                                        if (context.mounted) {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                                            (route) => false,
                                          );
                                        }
                                      },
                                      child: const Text('Keluar', style: TextStyle(color: Color(0xFFBA1A1A))),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: Stack(
                              children: [
                                const Icon(
                                  Icons.notifications_outlined,
                                  color: HomeScreen.onSurface,
                                  size: 22,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFBA1A1A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Greeting ─────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
                      child: Row(
                        children: [
                          Text(
                            _getGreeting(),
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: HomeScreen.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('👋', style: TextStyle(fontSize: 26)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Undangan Terbaru ─────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Undangan Terbaru',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: HomeScreen.onSurface,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const InvitationsScreen(),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: HomeScreen.primaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Horizontal scroll undangan ───────────────────────
                    SizedBox(
                      height: 190,
                      child: Consumer<EventProvider>(
                        builder: (context, eventProvider, _) {
                          if (eventProvider.isLoading) {
                            return const Center(child: CircularProgressIndicator(color: HomeScreen.primary));
                          }
                          
                          if (eventProvider.error != null) {
                            return Center(child: Text('Gagal memuat: ${eventProvider.error}'));
                          }
                          
                          final events = eventProvider.events;
                          
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: events.length + 1,
                            separatorBuilder: (context, index) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return _BuatAcaraCard();
                              }
                              final event = events[index - 1];
                              // Simple date extraction (e.g. "Minggu, 24 Okt" -> "24 OKT")
                              final dateParts = event.tanggal.split(' ');
                              String shortDate = event.tanggal;
                              if (dateParts.length >= 3) {
                                shortDate = '${dateParts[1]} ${dateParts[2]}';
                              }

                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InvitationDetailScreen(
                                      namaAcara: event.nama,
                                      namaHost: event.host,
                                      tanggal: event.tanggal,
                                      waktu: event.waktu,
                                      lokasi: event.lokasi,
                                      jenis: event.jenis.toUpperCase(),
                                      isPrioritas: event.isBalasBudi,
                                      imageUrl: event.imageUrl,
                                    ),
                                  ),
                                ),
                                child: _UndanganCard(
                                  nama: event.nama,
                                  tanggal: shortDate.toUpperCase(),
                                  jenis: event.jenis.toUpperCase(),
                                  subtitle: event.lokasi,
                                  isHighlighted: index == 1, // Highlight the first real event
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Agenda Mendatang ─────────────────────────────────
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Agenda Mendatang',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: HomeScreen.onSurface,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Agenda Card ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Consumer<EventProvider>(
                        builder: (context, eventProvider, _) {
                          if (eventProvider.isUpcomingLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(color: HomeScreen.primary),
                              ),
                            );
                          }
                          
                          if (eventProvider.upcomingError != null) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Gagal memuat agenda: ${eventProvider.upcomingError}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: HomeScreen.onSurfaceVariant),
                                ),
                              ),
                            );
                          }

                          if (eventProvider.upcomingEvents.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: HomeScreen.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: HomeScreen.outlineVariant.withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.event_busy, size: 48, color: HomeScreen.outlineVariant),
                                  SizedBox(height: 16),
                                  Text(
                                    'Belum ada agenda di sekitarmu',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      color: HomeScreen.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Tampilkan agenda terdekat (item pertama)
                          final event = eventProvider.upcomingEvents.first;
                          return _AgendaCard(event: event);
                        },
                      ),
                    ),
                  ],
                ),
              ),
                  // Riwayat (Placeholder)
                  const Center(
                    child: Text(
                      "Halaman Riwayat\n(Dalam Pengembangan)",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: HomeScreen.onSurfaceVariant),
                    ),
                  ),
                  // Profil
                  const ProfileScreen(),
                ],
              ),
            ),

            // ── Bottom Navigation Bar ────────────────────────────────────
            _BottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }
}

// ── Buat Acara Card ─────────────────────────────────────────────────────────
class _BuatAcaraCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateEventScreen()),
        );
      },
      child: Container(
        width: 140,
        height: 190,
        decoration: BoxDecoration(
          color: HomeScreen.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: HomeScreen.outlineVariant.withValues(alpha: 0.4),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: HomeScreen.primaryContainer,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            const Text(
              'Buat\nAcara',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: HomeScreen.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Undangan Card ───────────────────────────────────────────────────────────
class _UndanganCard extends StatelessWidget {
  final String nama;
  final String tanggal;
  final String jenis;
  final String? subtitle;
  final bool isHighlighted;

  const _UndanganCard({
    required this.nama,
    required this.tanggal,
    required this.jenis,
    this.subtitle,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 190,
      decoration: BoxDecoration(
        color: isHighlighted
            ? HomeScreen.primaryContainer
            : HomeScreen.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: HomeScreen.primary.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge jenis
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? HomeScreen.tertiaryContainer
                  : HomeScreen.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              jenis,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isHighlighted
                    ? const Color(0xFF4C3F00)
                    : HomeScreen.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Spacer(),
          Text(
            nama,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isHighlighted ? Colors.white : HomeScreen.onSurface,
              height: 1.3,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 10,
                color: isHighlighted
                    ? Colors.white.withValues(alpha: 0.7)
                    : HomeScreen.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 11,
                color: isHighlighted
                    ? Colors.white.withValues(alpha: 0.8)
                    : HomeScreen.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                tanggal,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isHighlighted
                      ? Colors.white.withValues(alpha: 0.8)
                      : HomeScreen.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Agenda Card ─────────────────────────────────────────────────────────────
class _AgendaCard extends StatelessWidget {
  final EventModel event;

  const _AgendaCard({required this.event});

  @override
  Widget build(BuildContext context) {
    // Extract date for badge (e.g. "Minggu, 24 Okt" -> "OKT" and "24")
    final dateParts = event.tanggal.split(' ');
    String month = 'BLN';
    String day = '--';
    if (dateParts.length >= 3) {
      day = dateParts[1];
      month = dateParts[2].toUpperCase();
    }

    // Extract distance from lokasiDisplay (e.g. "Lokasi • 1.3km")
    final lokasiParts = event.lokasiDisplay.split(' • ');
    String distanceStr = lokasiParts.length > 1 ? lokasiParts[1] : '- km';

    return Container(
      decoration: BoxDecoration(
        color: HomeScreen.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1B).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + tanggal badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  event.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: HomeScreen.surfaceContainerLow,
                    child: const Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: HomeScreen.outlineVariant,
                    ),
                  ),
                ),
              ),
              // Tanggal badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: HomeScreen.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        month,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        day,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Detail
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul + jarak
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.nama,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: HomeScreen.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: HomeScreen.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        distanceStr,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Host
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: HomeScreen.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      event.host,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: HomeScreen.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Lokasi
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: HomeScreen.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.lokasi,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: HomeScreen.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Waktu
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_outlined,
                      size: 14,
                      color: HomeScreen.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      event.waktu,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: HomeScreen.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // CTA Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InvitationDetailScreen(
                          namaAcara: event.nama,
                          namaHost: event.host,
                          tanggal: event.tanggal,
                          waktu: event.waktu,
                          lokasi: event.lokasiDisplay,
                          jenis: event.jenis.toUpperCase(),
                          subtitle: event.lokasi,
                          isPrioritas: event.isBalasBudi,
                          jarakKm: distanceStr,
                          imageUrl: event.imageUrl,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HomeScreen.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Lihat Undangan',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Navigation Bar ───────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const _BottomNavBar({required this.selectedIndex, required this.onItemTapped});

  static const _items = [
    {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Beranda'},
    {'icon': Icons.history_outlined, 'activeIcon': Icons.history, 'label': 'Riwayat'},
    {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Profil'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: HomeScreen.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1B).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final isSelected = selectedIndex == i;
          return GestureDetector(
            onTap: () => onItemTapped(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? HomeScreen.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected
                        ? item['activeIcon'] as IconData
                        : item['icon'] as IconData,
                    color: isSelected
                        ? HomeScreen.primary
                        : HomeScreen.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? HomeScreen.primary
                          : HomeScreen.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
