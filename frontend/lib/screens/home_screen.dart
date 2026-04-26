import 'package:flutter/material.dart';
import 'create_event_screen.dart';
import 'invitation_detail_screen.dart';
import 'invitations_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Color Tokens
  static const _primary = Color(0xFF134231);
  static const _primaryContainer = Color(0xFF2D5A47);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _outlineVariant = Color(0xFFC0C8C2);
  static const _surfaceContainerLow = Color(0xFFF2F4F2);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _background = Color(0xFFF8FAF8);
  static const _tertiary = Color(0xFF705D00);
  static const _tertiaryContainer = Color(0xFFC9A900);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                              color: _primaryContainer,
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://i.pravatar.cc/150?img=3',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Budi',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _onSurface,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: _onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Jakarta Selatan',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 11,
                                        color: _onSurfaceVariant.withValues(
                                          alpha: 0.8,
                                        ),
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
                              color: _onSurface,
                              size: 22,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Stack(
                              children: [
                                const Icon(
                                  Icons.notifications_outlined,
                                  color: _onSurface,
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
                              color: _onSurface,
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
                              color: _onSurface,
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
                                color: _primaryContainer,
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
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          // Buat Acara card
                          _BuatAcaraCard(),
                          const SizedBox(width: 12),
                          // Undangan card 1 - highlighted
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const InvitationDetailScreen(
                                  namaAcara: 'Buka Budi Areta & Fajar',
                                  namaHost: 'Keluarga Besar Bpk. Rudi',
                                  tanggal: 'Sabtu, 14 Jun 2025',
                                  waktu: '09.00 - 14.00 WIB',
                                  lokasi: 'Kediaman Bpk. Rudi, Jakarta',
                                  jenis: 'BUKA BUDI',
                                  isPrioritas: true,
                                  imageUrl:
                                      'https://images.unsplash.com/photo-1529543544282-ea669407fca3?w=600',
                                ),
                              ),
                            ),
                            child: _UndanganCard(
                              nama: 'Areta & Fajar',
                              tanggal: 'Sabtu, 09.00',
                              jenis: 'BUKA BUDI',
                              isHighlighted: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Undangan card 2
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const InvitationDetailScreen(
                                  namaAcara: 'Khitanan Putra Bpk. Slamet',
                                  namaHost: 'Bpk. Slamet Widodo',
                                  tanggal: 'Minggu, 15 Sep 2025',
                                  waktu: '08.00 - 13.00 WIB',
                                  lokasi: 'Gedung Serbaguna Hl, Jakarta',
                                  jenis: 'KHITANAN',
                                  subtitle: 'Putra dari Bpk. Slamet Widodo',
                                  imageUrl:
                                      'https://images.unsplash.com/photo-1511895426328-dc8714191011?w=600',
                                ),
                              ),
                            ),
                            child: _UndanganCard(
                              nama: 'Putra Bpk. Slamet',
                              tanggal: '15 SEP',
                              jenis: 'KHITANAN',
                              subtitle: 'Gedung Serbaguna Hl',
                              isHighlighted: false,
                            ),
                          ),
                        ],
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
                          color: _onSurface,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Agenda Card ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _AgendaCard(),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom Navigation Bar ────────────────────────────────────
            _BottomNavBar(),
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
          color: HomeScreen._surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: HomeScreen._outlineVariant.withValues(alpha: 0.4),
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
                color: HomeScreen._primaryContainer,
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
                color: HomeScreen._onSurfaceVariant,
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
            ? HomeScreen._primaryContainer
            : HomeScreen._surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: HomeScreen._primary.withValues(alpha: 0.10),
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
                  ? HomeScreen._tertiaryContainer
                  : HomeScreen._surfaceContainerLow,
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
                    : HomeScreen._onSurfaceVariant,
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
              color: isHighlighted ? Colors.white : HomeScreen._onSurface,
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
                    : HomeScreen._onSurfaceVariant,
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
                    : HomeScreen._onSurfaceVariant,
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
                      : HomeScreen._onSurfaceVariant,
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
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HomeScreen._surfaceContainerLowest,
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
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: HomeScreen._surfaceContainerLow,
                    child: const Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: HomeScreen._outlineVariant,
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
                    color: HomeScreen._primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'OKT',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        '12',
                        style: TextStyle(
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
                    const Expanded(
                      child: Text(
                        'Pernikahan Dimas & Ratna',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: HomeScreen._onSurface,
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
                        color: HomeScreen._primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '1.3km',
                        style: TextStyle(
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
                const Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: HomeScreen._onSurfaceVariant,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Bpk. Bambang Hermawan',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: HomeScreen._onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Lokasi
                const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: HomeScreen._onSurfaceVariant,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Balai Sudirman, Tebet, Jakarta Selatan',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: HomeScreen._onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Waktu
                const Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 14,
                      color: HomeScreen._onSurfaceVariant,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '19.00 - 21.00 WIB',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: HomeScreen._onSurfaceVariant,
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
                        builder: (_) => const InvitationDetailScreen(
                          namaAcara: 'Pernikahan Dimas & Ratna',
                          namaHost: 'Bpk. Bambang Hermawan',
                          tanggal: 'Sabtu, 12 Okt 2024',
                          waktu: '19.00 - 21.00 WIB',
                          lokasi: 'Balai Sudirman, Tebet, Jakarta Selatan',
                          jenis: 'PERNIKAHAN',
                          subtitle:
                              'Hajatan Keluarga Besar Bpk. Bambang Hermawan',
                          isPrioritas: true,
                          jarakKm: '1.3km',
                          imageUrl:
                              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600',
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HomeScreen._primary,
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
class _BottomNavBar extends StatefulWidget {
  @override
  State<_BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<_BottomNavBar> {
  int _selected = 0;

  final _items = const [
    {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Beranda'},
    {
      'icon': Icons.history_outlined,
      'activeIcon': Icons.history,
      'label': 'Riwayat',
    },
    {
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'label': 'Profil',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: HomeScreen._surfaceContainerLowest,
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
          final isSelected = _selected == i;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? HomeScreen._primary.withValues(alpha: 0.1)
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
                        ? HomeScreen._primary
                        : HomeScreen._onSurfaceVariant,
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
                          ? HomeScreen._primary
                          : HomeScreen._onSurfaceVariant,
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
