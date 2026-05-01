import 'package:flutter/material.dart';

// ── Color Tokens (Global Scope) ───────────────────────────────────────────
const _primary = Color(0xFF134231);
const _primaryContainer = Color(0xFF2D5A47);
const _onSurface = Color(0xFF191C1B);
const _onSurfaceVariant = Color(0xFF414944);
const _outlineVariant = Color(0xFFC0C8C2);
const _surfaceContainerLow = Color(0xFFF2F4F2);
const _surfaceContainerHigh = Color(0xFFE6E9E7);
const _surfaceContainerLowest = Color(0xFFFFFFFF);
const _secondaryContainer = Color(0xFFC2E8D6);
const _onSecondaryContainer = Color(0xFF476A5B);
const _secondary = Color(0xFF436557);
const _tertiaryFixed = Color(0xFFFFE16D);
const _onTertiaryFixed = Color(0xFF221B00);
const _tertiary = Color(0xFF705D00);
const _background = Color(0xFFF8FAF8);

class RecapScreen extends StatelessWidget {
  const RecapScreen({super.key});

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
          'Rekap Hajatan',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  Icons.event_available_outlined,
                  color: _primary.withValues(alpha: 0.6),
                  size: 18,
                ),
                const SizedBox(width: 5),
                Text(
                  'Selesai',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _primary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          // ── Hero Summary Card ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF191C1B).withValues(alpha: 0.04),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -24,
                  right: -24,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _primary.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'TOTAL REKAPITULASI AKHIR',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _secondary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          const _SummaryItem(
                            label: 'Beras',
                            value: '450',
                            unit: 'Kg',
                          ),
                          VerticalDivider(
                            color: _outlineVariant.withValues(alpha: 0.2),
                            width: 24,
                          ),
                          const _SummaryItem(
                            label: 'Gula',
                            value: '125',
                            unit: 'Kg',
                          ),
                          VerticalDivider(
                            color: _outlineVariant.withValues(alpha: 0.2),
                            width: 24,
                          ),
                          const _SummaryItem(
                            label: 'Uang',
                            value: '12.5M',
                            unit: 'Rp',
                            unitPrefix: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Daftar Tamu Header ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daftar Tamu Tervalidasi',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Total 128 tamu terdata',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      color: _onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search, color: _primary, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Search placeholder (Visual only)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: _onSurfaceVariant.withValues(alpha: 0.5),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Cari nama tamu...',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    color: _onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Guest items
          const _GuestItem(
            nama: 'Haji Sulaiman',
            avatarColor: _secondaryContainer,
            avatarIcon: Icons.person_outline,
            avatarIconColor: _onSecondaryContainer,
            jenis: 'Beras',
            nilai: '25 Kg',
            jenisColor: _primaryContainer,
            waktu: '14:20 WIB',
            isBalasBudi: false,
          ),
          const SizedBox(height: 10),
          const _GuestItem(
            nama: 'Ibu Ratna Sari',
            avatarColor: _tertiaryFixed,
            avatarIcon: Icons.payments_outlined,
            avatarIconColor: _onTertiaryFixed,
            jenis: 'Uang',
            nilai: 'Rp 500.000',
            jenisColor: _primaryContainer,
            waktu: '13:45 WIB',
            isBalasBudi: false,
          ),
          const SizedBox(height: 10),
          const _GuestItem(
            nama: 'Bapak Ahmad Dahlan',
            avatarColor: _surfaceContainerHigh,
            avatarIcon: Icons.volunteer_activism_outlined,
            avatarIconColor: _primary,
            jenis: 'Gula',
            nilai: '10 Kg',
            jenisColor: _primaryContainer,
            waktu: '13:10 WIB',
            isBalasBudi: false,
          ),
          const SizedBox(height: 10),
          const _GuestItem(
            nama: 'Siti Aminah',
            avatarColor: _secondaryContainer,
            avatarIcon: Icons.person_outline,
            avatarIconColor: _onSecondaryContainer,
            jenis: 'Beras',
            nilai: '5 Kg',
            jenisColor: _primaryContainer,
            waktu: '12:55 WIB',
            isBalasBudi: false,
          ),
          const SizedBox(height: 10),
          const _GuestItem(
            nama: 'Keluarga Basuki',
            avatarColor: _tertiaryFixed,
            avatarIcon: Icons.payments_outlined,
            avatarIconColor: _onTertiaryFixed,
            jenis: 'Uang',
            nilai: 'Rp 1.000.000',
            jenisColor: _primaryContainer,
            waktu: '11:30 WIB',
            isBalasBudi: false,
          ),
          const SizedBox(height: 10),
          const _GuestItem(
            nama: 'Andi Wijaya',
            avatarColor: _surfaceContainerHigh,
            avatarIcon: Icons.person_outline,
            avatarIconColor: _primary,
            jenis: 'Beras',
            nilai: '10 Kg',
            jenisColor: _primaryContainer,
            waktu: '11:15 WIB',
            isBalasBudi: false,
          ),
          const SizedBox(height: 10),
          const _GuestItem(
            nama: 'Rina Kartika',
            avatarColor: _secondaryContainer,
            avatarIcon: Icons.payments_outlined,
            avatarIconColor: _onSecondaryContainer,
            jenis: 'Uang',
            nilai: 'Rp 200.000',
            jenisColor: _primaryContainer,
            waktu: '10:40 WIB',
            isBalasBudi: false,
          ),
          const SizedBox(height: 10),
          const _GuestItem(
            nama: 'Dedi Kurniawan',
            avatarColor: _tertiaryFixed,
            avatarIcon: Icons.inventory_2_outlined,
            avatarIconColor: _onTertiaryFixed,
            jenis: 'Gula',
            nilai: '5 Kg',
            jenisColor: _primaryContainer,
            waktu: '10:20 WIB',
            isBalasBudi: true,
          ),
          const SizedBox(height: 10),
          const _GuestItem(
            nama: 'Ibu Wahyuni',
            avatarColor: _surfaceContainerHigh,
            avatarIcon: Icons.person_outline,
            avatarIconColor: _primary,
            jenis: 'Beras',
            nilai: '15 Kg',
            jenisColor: _primaryContainer,
            waktu: '09:50 WIB',
            isBalasBudi: false,
          ),
          const SizedBox(height: 10),
          const _GuestItem(
            nama: 'Bapak Subarjo',
            avatarColor: _secondaryContainer,
            avatarIcon: Icons.payments_outlined,
            avatarIconColor: _onSecondaryContainer,
            jenis: 'Uang',
            nilai: 'Rp 150.000',
            jenisColor: _primaryContainer,
            waktu: '09:15 WIB',
            isBalasBudi: false,
          ),

          const SizedBox(height: 40),

          // ── Footer ────────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        color: _primary,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Laporan Arsip Digital Selesai',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Data telah dikunci dan disimpan secara permanen di buku tamu digital.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: _onSurfaceVariant.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 1,
                      color: _primary.withValues(alpha: 0.15),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 80,
                      height: 1,
                      color: _primary.withValues(alpha: 0.15),
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

// ── Summary Item ──────────────────────────────────────────────────────────────
class _SummaryItem extends StatelessWidget {
  final String label, value, unit;
  final bool unitPrefix;

  static const _primary = Color(0xFF134231);
  static const _onSurfaceVariant = Color(0xFF414944);

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.unit,
    this.unitPrefix = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (unitPrefix) ...[
                Text(
                  unit,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _primary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 2),
              ],
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18, // Reduced from 22
                    fontWeight: FontWeight.w700,
                    color: _primary,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!unitPrefix) ...[
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _primary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Guest Item ────────────────────────────────────────────────────────────────
class _GuestItem extends StatelessWidget {
  final String nama, jenis, nilai, waktu;
  final Color avatarColor, avatarIconColor, jenisColor;
  final IconData avatarIcon;
  final bool isBalasBudi;

  static const _primary = Color(0xFF134231);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _surfaceContainerLow = Color(0xFFF2F4F2);
  static const _outlineVariant = Color(0xFFC0C8C2);
  static const _tertiary = Color(0xFF705D00);
  static const _tertiaryFixed = Color(0xFFFFE16D);
  static const _onTertiaryFixed = Color(0xFF221B00);

  const _GuestItem({
    required this.nama,
    required this.avatarColor,
    required this.avatarIcon,
    required this.avatarIconColor,
    required this.jenis,
    required this.nilai,
    required this.jenisColor,
    required this.waktu,
    required this.isBalasBudi,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1B).withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarColor,
            ),
            child: Icon(avatarIcon, color: avatarIconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nama,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13, // Slightly smaller
                          fontWeight: FontWeight.w700,
                          color: _onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        jenis,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: jenisColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        nilai,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: _onSurfaceVariant,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'VALIDASI',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: _onSurfaceVariant.withValues(alpha: 0.6),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                waktu,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
