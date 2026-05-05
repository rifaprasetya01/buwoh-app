// import 'dart:io';
// import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'manage_guests_screen.dart';
import 'recap_screen.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

class DashboardScreen extends StatefulWidget {
  final String nama;
  final String? fotoPath;

  const DashboardScreen({super.key, required this.nama, this.fotoPath});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withValues(alpha: 0.82),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Acara Saya',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
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
                    color: AppColors.primary,
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
                    color: AppColors.primary,
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
        BuwohEventCard(
          nama: 'Aqiqah Anak Budi',
          lokasi: 'Balai Kartini, Jakarta',
          isPrioritas: true,
          tamu: '124/200',
          progres: '62%',
          waktu: '2j 14m',
          imageUrl:
              'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=200',
          onManage: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageGuestsScreen(),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Event card 2
        BuwohEventCard(
          nama: 'Nikahan Sari',
          lokasi: 'Gedung Serbaguna, Bandung',
          isPrioritas: false,
          tamu: '450/500',
          progres: '90%',
          waktu: '5j 30m',
          imageUrl:
              'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=200',
          onManage: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageGuestsScreen(),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // ── Selesai ──────────────────────────────────────────────────
        Row(
          children: [
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceDim,
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
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        BuwohCompletedEventItem(
          nama: 'Khitanan Arkan',
          info: '12 Oktober 2023 • 150 Tamu',
          total: 'Rp 8.200.000',
          onRecapTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecapScreen()),
          ),
        ),

        const SizedBox(height: 10),

        BuwohCompletedEventItem(
          nama: 'Tasyakuran Rumah Baru',
          info: '05 Oktober 2023 • 80 Tamu',
          total: 'Rp 4.150.000',
          onRecapTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecapScreen()),
          ),
        ),
      ],
    );
  }
}

