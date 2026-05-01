import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'manage_guests_screen.dart';
import 'recap_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String nama;
  final String? fotoPath;

  const DashboardScreen({super.key, required this.nama, this.fotoPath});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _primary = Color(0xFF134231);
  static const _primaryContainer = Color(0xFF2D5A47);
  static const _primaryFixed = Color(0xFFBCEDD4);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _outlineVariant = Color(0xFFC0C8C2);
  static const _surfaceContainerLow = Color(0xFFF2F4F2);
  static const _surfaceContainerHigh = Color(0xFFE6E9E7);
  static const _surfaceContainerHighest = Color(0xFFE1E3E1);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _surfaceDim = Color(0xFFD8DAD9);
  static const _secondaryContainer = Color(0xFFC2E8D6);
  static const _tertiaryFixed = Color(0xFFFFE16D);
  static const _error = Color(0xFFBA1A1A);
  static const _errorContainer = Color(0xFFFFDAD6);
  static const _background = Color(0xFFF8FAF8);

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
          'Acara Saya',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _primary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: _AcaraSayaTab(),
    );
  }
}

// ── Acara Saya Tab ────────────────────────────────────────────────────────────
class _AcaraSayaTab extends StatelessWidget {
  static const _primary = Color(0xFF134231);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _primaryFixed = Color(0xFFBCEDD4);
  static const _surfaceDim = Color(0xFFD8DAD9);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        // ── Sedang Berjalan ──────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Sedang Berjalan',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFBCEDD4),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '2 AKTIF',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF002115),
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Event card 1
        const _AcaraCard(
          nama: 'Aqiqah Anak Budi',
          lokasi: 'Balai Kartini, Jakarta',
          isPrioritas: true,
          tamu: '124/200',
          progres: '62%',
          waktu: '2j 14m',
          imageUrl:
              'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=200',
        ),

        const SizedBox(height: 16),

        // Event card 2
        const _AcaraCard(
          nama: 'Nikahan Sari',
          lokasi: 'Gedung Serbaguna, Bandung',
          isPrioritas: false,
          tamu: '450/500',
          progres: '90%',
          waktu: '5j 30m',
          imageUrl:
              'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=200',
        ),

        const SizedBox(height: 32),

        // ── Selesai ──────────────────────────────────────────────────
        Row(
          children: [
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: _surfaceDim,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Selesai',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _onSurfaceVariant,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        const _SelesaiItem(
          nama: 'Khitanan Arkan',
          info: '12 Oktober 2023 • 150 Tamu',
          total: 'Rp 8.200.000',
        ),

        const SizedBox(height: 10),

        const _SelesaiItem(
          nama: 'Tasyakuran Rumah Baru',
          info: '05 Oktober 2023 • 80 Tamu',
          total: 'Rp 4.150.000',
        ),
      ],
    );
  }
}

// ── Acara Card ────────────────────────────────────────────────────────────────
class _AcaraCard extends StatelessWidget {
  final String nama;
  final String lokasi;
  final bool isPrioritas;
  final String tamu;
  final String progres;
  final String waktu;
  final String imageUrl;

  static const _primaryContainer = Color(0xFF2D5A47);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _outlineVariant = Color(0xFFC0C8C2);
  static const _tertiaryFixed = Color(0xFFFFE16D);

  const _AcaraCard({
    required this.nama,
    required this.lokasi,
    required this.isPrioritas,
    required this.tamu,
    required this.progres,
    required this.waktu,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1B).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE6E9E7),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFFC0C8C2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isPrioritas)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _tertiaryFixed,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 10,
                              color: Color(0xFF221B00),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'PRIORITAS',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF221B00),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      nama,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: _onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            lokasi,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: _onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: _outlineVariant.withOpacity(0.15),
                ),
              ),
            ),
            child: Row(
              children: [
                _StatItem(label: 'TAMU', value: tamu),
                _Divider(),
                _StatItem(label: 'PROGRES', value: progres),
                _Divider(),
                _StatItem(label: 'WAKTU', value: waktu),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Kelola button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageGuestsScreen(),
                ),
              ),
              icon: const Icon(Icons.settings_suggest_outlined, size: 16),
              label: const Text(
                'Kelola',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryContainer,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  static const _primary = Color(0xFF134231);
  static const _onSurfaceVariant = Color(0xFF414944);

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: _onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: const Color(0xFFC0C8C2).withOpacity(0.2),
    );
  }
}

// ── Selesai Item ──────────────────────────────────────────────────────────────
class _SelesaiItem extends StatelessWidget {
  final String nama;
  final String info;
  final String total;

  static const _primary = Color(0xFF134231);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _surfaceContainerLow = Color(0xFFF2F4F2);
  static const _surfaceContainerHigh = Color(0xFFE6E9E7);
  static const _surfaceContainerHighest = Color(0xFFE1E3E1);

  const _SelesaiItem({
    required this.nama,
    required this.info,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _surfaceContainerHigh,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: _onSurfaceVariant,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  info,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    color: _onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'TOTAL BUWOH',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: _onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                total,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecapScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Rekap',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
