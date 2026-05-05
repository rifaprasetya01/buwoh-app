import 'package:flutter/material.dart';
import 'invitation_detail_screen.dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({super.key});

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  int _selectedFilter = 0;
  final _searchCtrl = TextEditingController();

  static const _primary = Color(0xFF134231);
  static const _primaryContainer = Color(0xFF2D5A47);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _outline = Color(0xFF717974);
  static const _surfaceContainerHigh = Color(0xFFE6E9E7);
  static const _surfaceContainerLow = Color(0xFFF2F4F2);
  static const _background = Color(0xFFF8FAF8);

  final _filters = ['Semua', 'Pernikahan', 'Khitanan', 'Tasyakuran'];

  final _allInvitations = const [
    _Invitation(
      jenis: 'Undangan Pernikahan',
      jenisColor: Color(0xFF705D00),
      nama: 'Pernikahan Anisa & Bayu',
      host: 'Bpk. Haji Sulaiman',
      tanggal: 'Minggu, 24 Okt 2024',
      waktu: '09.00 - 21.00 WIB',
      lokasi: 'Griya Ageng, Solo',
      lokasiDisplay: 'Griya Ageng, Solo • 2.4 km',
      imageUrl:
          'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=300',
      isBalasBudi: true,
      tag: 'Pernikahan',
    ),
    _Invitation(
      jenis: 'Khitanan',
      jenisColor: Color(0xFF134231),
      nama: 'Syukuran Khitan Ahmad',
      host: 'Keluarga Bpk. Bambang',
      tanggal: 'Sabtu, 30 Okt 2024',
      waktu: '08.00 - 13.00 WIB',
      lokasi: 'Balai Desa Sukamaju',
      lokasiDisplay: 'Balai Desa Sukamaju • 0.8 km',
      imageUrl:
          'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=300',
      isBalasBudi: false,
      tag: 'Khitanan',
    ),
    _Invitation(
      jenis: 'Tasyakuran',
      jenisColor: Color(0xFF134231),
      nama: 'Tasyakuran Rumah Baru',
      host: 'Ibu Retno & Keluarga',
      tanggal: 'Jumat, 05 Nov 2024',
      waktu: '10.00 - 14.00 WIB',
      lokasi: 'Perum Elit Blok C-12',
      lokasiDisplay: 'Perum Elit Blok C-12 • 5.1 km',
      imageUrl:
          'https://images.unsplash.com/photo-1555244162-803834f70033?w=300',
      isBalasBudi: false,
      tag: 'Tasyakuran',
    ),
    _Invitation(
      jenis: 'Undangan Pernikahan',
      jenisColor: Color(0xFF134231),
      nama: 'Wedding of Rina & Andre',
      host: 'Keluarga Bpk. Wijaya',
      tanggal: 'Minggu, 07 Nov 2024',
      waktu: '17.00 - 22.00 WIB',
      lokasi: 'Grand Ballroom Hilton, Jakarta',
      lokasiDisplay: 'Grand Ballroom Hilton • 12.0 km',
      imageUrl:
          'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=300',
      isBalasBudi: false,
      tag: 'Pernikahan',
    ),
  ];

  List<_Invitation> get _filtered {
    final query = _searchCtrl.text.toLowerCase();
    var list = _allInvitations;
    if (_selectedFilter != 0) {
      list = list.where((i) => i.tag == _filters[_selectedFilter]).toList();
    }
    if (query.isNotEmpty) {
      list = list
          .where((i) =>
              i.nama.toLowerCase().contains(query) ||
              i.host.toLowerCase().contains(query))
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background.withValues(alpha: 0.82),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Undangan',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _primary,
            letterSpacing: -0.3,
          ),
        ),

      ),
      body: Column(
        children: [
          // ── Search + Filter ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: _onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari undangan atau tuan rumah...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      color: _outline,
                    ),
                    prefixIcon: const Icon(Icons.search_outlined,
                        color: _outline, size: 22),
                    filled: true,
                    fillColor: _surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide(
                          color: _primary.withOpacity(0.2), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                  ),
                ),

                const SizedBox(height: 12),

                // Filter chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final selected = _selectedFilter == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? _primaryContainer
                                : _surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _filters[i],
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : _primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── List ────────────────────────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_outlined,
                            size: 56,
                            color: _outline.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        const Text(
                          'Tidak ada undangan ditemukan',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            color: _onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) {
                      final inv = _filtered[i];
                      return _InvitationCard(
                        invitation: inv,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InvitationDetailScreen(
                              namaAcara: inv.nama,
                              namaHost: inv.host,
                              tanggal: inv.tanggal,
                              waktu: inv.waktu,
                              lokasi: inv.lokasi,
                              jenis: inv.jenis.toUpperCase(),
                              imageUrl: inv.imageUrl,
                              isPrioritas: inv.isBalasBudi,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Data Model ───────────────────────────────────────────────────────────────
class _Invitation {
  final String jenis;
  final Color jenisColor;
  final String nama;
  final String host;
  final String tanggal;
  final String waktu;
  final String lokasi;
  final String lokasiDisplay;
  final String imageUrl;
  final bool isBalasBudi;
  final String tag;

  const _Invitation({
    required this.jenis,
    required this.jenisColor,
    required this.nama,
    required this.host,
    required this.tanggal,
    required this.waktu,
    required this.lokasi,
    required this.lokasiDisplay,
    required this.imageUrl,
    required this.isBalasBudi,
    required this.tag,
  });
}

// ── Invitation Card ──────────────────────────────────────────────────────────
class _InvitationCard extends StatelessWidget {
  final _Invitation invitation;
  final VoidCallback onTap;

  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _outline = Color(0xFF717974);
  static const _tertiaryFixed = Color(0xFFFFE16D);

  const _InvitationCard({required this.invitation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF191C1B).withOpacity(0.04),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 88,
                      height: 120,
                      child: Image.network(
                        invitation.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFE6E9E7),
                          child: const Icon(Icons.image_outlined,
                              color: Color(0xFFC0C8C2), size: 32),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Content
                  Expanded(
                    child: SizedBox(
                      height: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invitation.jenis.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: invitation.jenisColor,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                invitation.nama,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _onSurface,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                invitation.host,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 13, color: _outline),
                                  const SizedBox(width: 5),
                                  Text(
                                    invitation.tanggal,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11,
                                      color: _outline,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 13, color: _outline),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      invitation.lokasiDisplay,
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 11,
                                        color: _outline,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Badge "Balas Budi"
            if (invitation.isBalasBudi)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _tertiaryFixed,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite,
                          size: 12, color: Color(0xFF221B00)),
                      SizedBox(width: 4),
                      Text(
                        'BALAS BUDI',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF221B00),
                          letterSpacing: 1.0,
                        ),
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
