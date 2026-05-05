import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'create_event_screen.dart';
import 'dashboard_screen.dart';
import 'invitation_detail_screen.dart';
import 'history_screen.dart';

import 'profile_screen.dart';
import 'notifications_screen.dart';

// ── Color Tokens (Global Scope) ───────────────────────────────────────────
const _primary = Color(0xFF134231);
const _primaryContainer = Color(0xFF2D5A47);
const _onSurface = Color(0xFF191C1B);
const _onSurfaceVariant = Color(0xFF414944);
const _surfaceContainerLowest = Color(0xFFFFFFFF);
const _background = Color(0xFFF8FAF8);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isBottomNavVisible = true;

  String _nama = 'Budi';
  String _alamat = 'Jakarta Selatan';
  String? _fotoPath;
  late List<Map<String, dynamic>> _myEvents;

  @override
  void initState() {
    super.initState();
    _myEvents = [
      {
        'nama': 'Aqiqah Anak Budi',
        'lokasi': 'Balai Kartini, Jakarta',
        'imageUrl':
            'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
      },
      {
        'nama': 'Nikahan Sari',
        'lokasi': 'Gedung Serbaguna, Jakarta',
        'imageUrl':
            'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800',
      },
    ];
  }

  List<Widget> _buildPages() {
    return [
      _HomeContent(
        nama: _nama,
        alamat: _alamat,
        fotoPath: _fotoPath,
        myEvents: _myEvents,
        onEventCreated: (event) {
          setState(() {
            _myEvents.insert(0, event);
          });
        },
      ),
      const HistoryScreen(),
      ProfileScreen(
        nama: _nama,
        alamat: _alamat,
        fotoPath: _fotoPath,
        onProfileUpdated: (result) {
          setState(() {
            if (result['nama'] != null &&
                result['nama'].toString().isNotEmpty) {
              _nama = result['nama'];
            }
            if (result['alamat'] != null &&
                result['alamat'].toString().isNotEmpty) {
              _alamat = result['alamat'];
            }
            if (result['fotoPath'] != null) {
              _fotoPath = result['fotoPath'];
            }
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: _background,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (_isBottomNavVisible) {
              setState(() => _isBottomNavVisible = false);
            }
          } else if (notification.direction == ScrollDirection.forward) {
            if (!_isBottomNavVisible) {
              setState(() => _isBottomNavVisible = true);
            }
          }
          return false;
        },
        child: IndexedStack(index: _currentIndex, children: _buildPages()),
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _isBottomNavVisible ? Offset.zero : const Offset(0, 1),
        child: _BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final String nama;
  final String alamat;
  final String? fotoPath;
  final List<Map<String, dynamic>> myEvents;
  final Function(Map<String, dynamic>) onEventCreated;

  const _HomeContent({
    required this.nama,
    required this.alamat,
    this.fotoPath,
    required this.myEvents,
    required this.onEventCreated,
  });

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  Future<void> _navigateToCreateEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateEventScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      widget.onEventCreated(result);
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                            image: widget.fotoPath != null
                                ? DecorationImage(
                                    image:
                                        (kIsWeb
                                                ? NetworkImage(widget.fotoPath!)
                                                : FileImage(
                                                    File(widget.fotoPath!),
                                                  ))
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                  )
                                : const DecorationImage(
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
                              Text(
                                widget.nama,
                                style: const TextStyle(
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
                                  Expanded(
                                    child: Text(
                                      widget.alamat,
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 11,
                                        color: _onSurfaceVariant.withValues(
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
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(
                            Icons.tune_outlined,
                            color: _onSurfaceVariant,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: _onSurfaceVariant,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── My Event Card ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _MyEventCard(
                      events: widget.myEvents,
                      nama: widget.nama,
                      fotoPath: widget.fotoPath,
                      onTap: () {
                        // Jika sudah ada acara, buka Dashboard
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DashboardScreen(
                              nama: widget.nama,
                              fotoPath: widget.fotoPath,
                            ),
                          ),
                        );
                      },
                      onAddTap: _navigateToCreateEvent,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Undangan Terbaru Header ──────────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Undangan Terbaru',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Vertical list undangan ───────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _HomeInvitationCard(
                          jenis: 'BUKA BUDI',
                          nama: 'Areta & Fajar',
                          host: 'Keluarga Besar Bpk. Rudi',
                          tanggal: 'Sabtu, 14 Jun 2025',
                          lokasi: 'Kediaman Bpk. Rudi, Jakarta',
                          imageUrl:
                              'https://images.unsplash.com/photo-1529543544282-ea669407fca3?w=600',
                          isPrioritas: true,
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
                        ),
                        const SizedBox(height: 12),
                        _HomeInvitationCard(
                          jenis: 'KHITANAN',
                          nama: 'Bpk. Slamet',
                          host: 'Bpk. Slamet Widodo',
                          tanggal: 'Minggu, 15 Sep 2025',
                          lokasi: 'Gedung Serbaguna Hl, Jakarta',
                          imageUrl:
                              'https://images.unsplash.com/photo-1511895426328-dc8714191011?w=600',
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
                                imageUrl:
                                    'https://images.unsplash.com/photo-1511895426328-dc8714191011?w=600',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── My Event Card ──────────────────────────────────────────────────────────
class _MyEventCard extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final String nama;
  final String? fotoPath;
  final VoidCallback onTap;
  final VoidCallback onAddTap;

  const _MyEventCard({
    required this.events,
    required this.nama,
    this.fotoPath,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasEvent = events.isNotEmpty;
    final Map<String, dynamic>? latestEvent = hasEvent ? events.first : null;
    final String? fotoPath = latestEvent?['fotoPath'];
    final String? imageUrl = latestEvent?['imageUrl'];

    ImageProvider? imageProvider;
    if (fotoPath != null) {
      imageProvider = kIsWeb
          ? NetworkImage(fotoPath)
          : FileImage(File(fotoPath));
    } else if (imageUrl != null) {
      imageProvider = NetworkImage(imageUrl);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFF134231),
          borderRadius: BorderRadius.circular(24),
          image: imageProvider != null
              ? DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.3),
                    BlendMode.darken,
                  ),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF134231).withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Acara saya',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (!hasEvent)
                    Text(
                      'Buat acara sekarang',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: onAddTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Home Invitation Card ─────────────────────────────────────────────────────
class _HomeInvitationCard extends StatelessWidget {
  final String jenis;
  final String nama;
  final String host;
  final String tanggal;
  final String lokasi;
  final String imageUrl;
  final bool isPrioritas;
  final VoidCallback onTap;

  const _HomeInvitationCard({
    required this.jenis,
    required this.nama,
    required this.host,
    required this.tanggal,
    required this.lokasi,
    required this.imageUrl,
    this.isPrioritas = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: const Color(0xFFE6E9E7),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFFC0C8C2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        jenis,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF134231),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nama,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF191C1B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    host,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      color: Color(0xFF414944),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: Color(0xFF414944),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tanggal,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: Color(0xFF414944),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Navigation Bar ───────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

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
    return SafeArea(
      bottom: true,
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 8),
        decoration: BoxDecoration(
          color: _surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF191C1B).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (i) {
            final isSelected = currentIndex == i;
            return GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? _items[i]['activeIcon'] as IconData
                          : _items[i]['icon'] as IconData,
                      color: isSelected ? _primary : _onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _items[i]['label'] as String,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected ? _primary : _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
