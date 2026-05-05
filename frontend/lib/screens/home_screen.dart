import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'create_event_screen.dart';
import 'dashboard_screen.dart';
import 'invitation_detail_screen.dart';
import 'history_screen.dart';

import 'profile_screen.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

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
      backgroundColor: AppColors.background,
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
        child: BuwohBottomNavBar(
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
                            color: AppColors.primaryContainer,
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
                                  color: AppColors.onSurface,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      widget.alamat,
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 11,
                                        color: AppColors.onSurfaceVariant.withValues(
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
                            color: AppColors.onSurfaceVariant,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.onSurfaceVariant,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── My Event Card ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: BuwohHeroEventCard(
                      events: widget.myEvents,
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
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Vertical list undangan ───────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        BuwohInvitationCard(
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
                        BuwohInvitationCard(
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

