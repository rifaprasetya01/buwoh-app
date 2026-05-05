import 'package:flutter/material.dart';

// ── Color Tokens (Global Scope) ───────────────────────────────────────────
const _primary = Color(0xFF134231);
const _primaryContainer = Color(0xFF2D5A47);
const _primaryFixed = Color(0xFFBCEDD4);
const _onSurface = Color(0xFF191C1B);
const _onSurfaceVariant = Color(0xFF414944);
const _outlineVariant = Color(0xFFC0C8C2);
const _surfaceContainerLow = Color(0xFFF2F4F2);
const _surfaceContainerLowest = Color(0xFFFFFFFF);
const _surfaceContainer = Color(0xFFECEEEC);
const _tertiaryFixed = Color(0xFFFFE16D);
const _background = Color(0xFFF8FAF8);

class InvitationDetailScreen extends StatefulWidget {
  final String namaAcara;
  final String namaHost;
  final String tanggal;
  final String waktu;
  final String lokasi;
  final String jenis;
  final String? subtitle;
  final String? deskripsi;
  final String imageUrl;
  final String? tanggalBadgeBulan;
  final String? tanggalBadgeTanggal;
  final String? jarakKm;
  final bool isPrioritas;

  const InvitationDetailScreen({
    super.key,
    required this.namaAcara,
    required this.namaHost,
    required this.tanggal,
    required this.waktu,
    required this.lokasi,
    required this.jenis,
    this.subtitle,
    this.deskripsi,
    this.imageUrl =
        'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=600',
    this.tanggalBadgeBulan,
    this.tanggalBadgeTanggal,
    this.jarakKm,
    this.isPrioritas = false,
  });

  @override
  State<InvitationDetailScreen> createState() => _InvitationDetailScreenState();
}

class _InvitationDetailScreenState extends State<InvitationDetailScreen> {
  bool _uang = false;
  bool _beras = false;
  bool _gula = false;

  void _ajukanBuwoh() {
    if (!_uang && !_beras && !_gula) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih minimal satu jenis buwoh'),
          backgroundColor: _primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Pengajuan Berhasil Dikirim',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      extendBodyBehindAppBar: true,

      // ── Top App Bar ────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _background.withValues(alpha: 0.82),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buwoh',
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
            child: CircleAvatar(
              radius: 20,
              backgroundColor: _primaryContainer,
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/150?img=3',
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Action Bar ──────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF134231).withValues(alpha: 0.06),
              blurRadius: 40,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _ajukanBuwoh,
            icon: const Icon(Icons.volunteer_activism_outlined, size: 22),
            label: const Text(
              'Ajukan Buwoh',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              elevation: 4,
              shadowColor: _primary.withValues(alpha: 0.2),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image ───────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(0),
                  ),
                  child: AspectRatio(
                    aspectRatio: 4 / 5,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: _surfaceContainerLow,
                        child: const Icon(
                          Icons.image_outlined,
                          size: 64,
                          color: _outlineVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                // Badge "Acara Prioritas" (opsional)
                if (widget.isPrioritas)
                  Positioned(
                    top: 80,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _tertiaryFixed,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Color(0xFF221B00),
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'ACARA PRIORITAS',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF221B00),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Gradient overlay + judul
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          _primary.withValues(alpha: 0.90),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge jenis acara
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.jenis,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Text(
                          widget.namaAcara,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.subtitle ?? 'Hajatan ${widget.namaHost}',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _primaryFixed.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Info Cards Grid ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Tanggal
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.calendar_today_outlined,
                      label: 'Tanggal Acara',
                      title: widget.tanggal,
                      subtitle: widget.waktu,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Lokasi
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.location_on_outlined,
                      label: 'Lokasi',
                      title: widget.lokasi,
                      subtitle: null,
                      trailing: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'PETUNJUK',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Deskripsi ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DESKRIPSI ACARA',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.deskripsi ??
                          "Assalamu'alaikum Warahmatullahi Wabarakatuh. "
                              "Dengan memohon rahmat dan ridho Allah SWT, kami mengundang "
                              "Bapak/Ibu/Saudara/i untuk hadir dalam acara ${widget.namaAcara}. "
                              "Kehadiran dan doa restu Anda adalah kehormatan besar bagi keluarga kami.",
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _onSurface,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 24),

            // ── Pilih Jenis Buwoh ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Jenis Buwoh',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _BuwohCheckItem(
                    icon: Icons.payments_outlined,
                    label: 'Uang',
                    value: _uang,
                    onChanged: (v) => setState(() => _uang = v),
                  ),
                  const SizedBox(height: 10),
                  _BuwohCheckItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Beras',
                    value: _beras,
                    onChanged: (v) => setState(() => _beras = v),
                  ),
                  const SizedBox(height: 10),
                  _BuwohCheckItem(
                    icon: Icons.kitchen_outlined,
                    label: 'Gula',
                    value: _gula,
                    onChanged: (v) => setState(() => _gula = v),
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

// ── Info Card ───────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), // Slightly reduced padding
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1B).withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, // Slightly smaller icon container
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2D5A47).withValues(alpha: 0.10),
                ),
                child: Icon(icon, color: const Color(0xFF134231), size: 18),
              ),
              if (trailing != null) Flexible(child: trailing!),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11, // Slightly smaller label
              color: Color(0xFF414944),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13, // Slightly smaller title
              fontWeight: FontWeight.w700,
              color: Color(0xFF191C1B),
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                color: Color(0xFF414944),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Buwoh Check Item ────────────────────────────────────────────────────────
class _BuwohCheckItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _BuwohCheckItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value
              ? const Color(0xFF134231).withValues(alpha: 0.05)
              : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value ? const Color(0xFF134231) : const Color(0xFFC0C8C2),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: value ? const Color(0xFF134231) : Colors.transparent,
                border: Border.all(
                  color: value
                      ? const Color(0xFF134231)
                      : const Color(0xFFC0C8C2),
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 14),
            Icon(icon, color: const Color(0xFF134231), size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF191C1B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
