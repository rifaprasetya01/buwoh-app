import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

class ManageGuestsScreen extends StatefulWidget {
  const ManageGuestsScreen({super.key});

  @override
  State<ManageGuestsScreen> createState() => _ManageGuestsScreenState();
}

class _ManageGuestsScreenState extends State<ManageGuestsScreen> {

  // Pending guests state
  final List<_Guest> _pending = [
    const _Guest(
      inisial: 'R',
      nama: 'Rina',
      relasi: 'KERABAT',
      kontribusiIcon: Icons.inventory_2_outlined,
      kontribusi: 'Beras (10kg)',
    ),
    const _Guest(
      inisial: 'A',
      nama: 'Andi',
      relasi: 'TETANGGA',
      kontribusiIcon: Icons.water_drop_outlined,
      kontribusi: 'Gula (5kg)',
    ),
  ];

  final List<_GuestAcc> _validated = [
    const _GuestAcc(
      nama: 'Siska',
      waktu: '2 jam lalu',
      kontribusiIcon: Icons.payments_outlined,
      kontribusi: 'Rp 200rb',
      isBalasBudi: false,
    ),
    const _GuestAcc(
      nama: 'Budi Santoso',
      waktu: 'Kemarin',
      kontribusiIcon: Icons.restaurant_outlined,
      kontribusi: 'Katering',
      isBalasBudi: false,
    ),
  ];

  void _terima(int index) {
    final guest = _pending[index];
    setState(() => _pending.removeAt(index));
    _validated.insert(
      0,
      _GuestAcc(
        nama: guest.nama,
        waktu: 'Baru saja',
        kontribusiIcon: guest.kontribusiIcon,
        kontribusi: guest.kontribusi,
        isBalasBudi: false,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${guest.nama} diterima'),
        backgroundColor: AppColors.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

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
          'Kelola Tamu',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          // ── Hero banner ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -24,
                  right: -24,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Image
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=200',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.image_outlined,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title & Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ACARA AKTIF',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Aqiqah Anak Budi',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Mengelola tamu anda.',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 10,
                              color: const Color(
                                0xFF9FCFB7,
                              ).withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Stats
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '128',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFC5EBD9),
                            ),
                          ),
                          Text(
                            'TAMU',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              color: const Color(
                                0xFF9FCFB7,
                              ).withValues(alpha: 0.6),
                            ),
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

          // ── Pengajuan Pending ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    ...List.generate(
                      2,
                      (_) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.tertiaryContainer.withValues(alpha: 0.2),
                        ),
                        child: const Icon(
                          Icons.pending_actions_outlined,
                          color: AppColors.onTertiaryContainer,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pengajuan (Pending)',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14, // Slightly smaller
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Tamu yang baru mendaftar',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 10, // Slightly smaller
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_pending.length} Tertunda',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ..._pending.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BuwohPendingGuestCard(
                inisial: e.value.inisial,
                nama: e.value.nama,
                relasi: e.value.relasi,
                kontribusiIcon: e.value.kontribusiIcon,
                kontribusi: e.value.kontribusi,
                onTerima: () => _terima(e.key),
              ),
            ),
          ),

          if (_pending.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Semua pengajuan sudah diproses ✓',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 28),

          // ── Sudah Divalidasi ──────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryContainer,
                ),
                child: const Icon(
                  Icons.verified_outlined,
                  color: AppColors.onSecondaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sudah Divalidasi',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Daftar tetap tamu',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          ..._validated.map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: BuwohValidatedGuestCard(
                nama: g.nama,
                waktu: g.waktu,
                kontribusiIcon: g.kontribusiIcon,
                kontribusi: g.kontribusi,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tambah tamu manual card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFECF9F1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD0EFE0)),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.group_add_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Butuh Tambah Tamu?',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Anda dapat memasukkan tamu secara manual jika diperlukan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      side: const BorderSide(color: Color(0xFFB8DECE)),
                      backgroundColor: const Color(0xFFD6F0E4),
                    ),
                    child: const Text(
                      'TAMBAH TAMU MANUAL',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        letterSpacing: 1.0,
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


// ── Data Models ───────────────────────────────────────────────────────────────
class _Guest {
  final String inisial, nama, relasi, kontribusi;
  final IconData kontribusiIcon;
  const _Guest({
    required this.inisial,
    required this.nama,
    required this.relasi,
    required this.kontribusiIcon,
    required this.kontribusi,
  });
}

class _GuestAcc {
  final String nama, waktu, kontribusi;
  final IconData kontribusiIcon;
  final bool isBalasBudi;
  const _GuestAcc({
    required this.nama,
    required this.waktu,
    required this.kontribusiIcon,
    required this.kontribusi,
    required this.isBalasBudi,
  });
}
