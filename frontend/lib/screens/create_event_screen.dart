import 'package:flutter/material.dart';
import '../services/event_service.dart';
import '../services/api_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _namaCtrl = TextEditingController();
  final _lokasiCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  bool _isLoading = false;

  bool _beras = true;
  bool _gula = false;
  bool _uang = true;

  // Color Tokens
  static const _primary = Color(0xFF134231);
  static const _primaryContainer = Color(0xFF2D5A47);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _surfaceContainerLow = Color(0xFFF2F4F2);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _tertiary = Color(0xFF705D00);
  static const _tertiaryFixed = Color(0xFFFFE16D);
  static const _background = Color(0xFFF8FAF8);

  @override
  void dispose() {
    _namaCtrl.dispose();
    _lokasiCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateMulai() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _primaryContainer,
            onPrimary: Colors.white,
            surface: _surfaceContainerLowest,
            onSurface: _onSurface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggalMulai = picked);
  }

  Future<void> _pickDateSelesai() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalMulai ?? DateTime.now(),
      firstDate: _tanggalMulai ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _primaryContainer,
            onPrimary: Colors.white,
            surface: _surfaceContainerLowest,
            onSurface: _onSurface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggalSelesai = picked);
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'mm/dd';
    return '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    // Validation
    if (_namaCtrl.text.isEmpty || _tanggalMulai == null || _tanggalSelesai == null || _lokasiCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sila lengkapi semua data acara'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Build gift recommendations from toggles
      final giftRecs = <Map<String, dynamic>>[];
      // Gift category IDs: 1 = Beras, 2 = Gula, 3 = Uang (adjust based on your seed data)
      if (_beras) giftRecs.add({'giftCategoryId': 1});
      if (_gula) giftRecs.add({'giftCategoryId': 2});
      if (_uang) giftRecs.add({'giftCategoryId': 3});

      await EventService.createEvent(
        eventCategoryId: 1, // Default to first category (Pernikahan)
        title: _namaCtrl.text.trim(),
        description: _deskripsiCtrl.text.isNotEmpty ? _deskripsiCtrl.text.trim() : null,
        locationName: _lokasiCtrl.text.trim(),
        locationAddress: _lokasiCtrl.text.trim(),
        startDatetime: _tanggalMulai!,
        endDatetime: _tanggalSelesai!,
        giftRecommendations: giftRecs.isNotEmpty ? giftRecs : null,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFBCEDD4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: _primary, size: 36),
              ),
              const SizedBox(height: 24),
              const Text(
                'Undangan Terbit!',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Acara Anda telah berhasil dibuat dan siap dibagikan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  color: _onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back home
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFFBA1A1A),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuat acara. Periksa koneksi internet.'),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background.withValues(alpha: 0.85),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buat Acara Baru',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero ──────────────────────────────────────────────────────
            const Text(
              'LANGKAH PERTAMA',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _onSurfaceVariant,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Rencanakan\nHajatan Anda',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _primary,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Berbagi kebahagiaan dimulai dengan undangan yang tulus. Lengkapi detail acara di bawah ini.',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: _onSurfaceVariant,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24),

            // ── Detail Acara Card ─────────────────────────────────────────
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama acara
                  const _FieldLabel('NAMA ACARA'),
                  const SizedBox(height: 8),
                  _RoundedTextField(
                    controller: _namaCtrl,
                    hint: 'Contoh: Pernikahan Budi & Ani',
                  ),

                  const SizedBox(height: 20),

                  // Tanggal Mulai & Selesai
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('TANGGAL MULAI'),
                            const SizedBox(height: 8),
                            _TapField(
                              text: _formatDate(_tanggalMulai),
                              icon: Icons.calendar_today_outlined,
                              hasValue: _tanggalMulai != null,
                              onTap: _pickDateMulai,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('TANGGAL SELESAI'),
                            const SizedBox(height: 8),
                            _TapField(
                              text: _formatDate(_tanggalSelesai),
                              icon: Icons.calendar_today_outlined,
                              hasValue: _tanggalSelesai != null,
                              onTap: _pickDateSelesai,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Deskripsi
                  const _FieldLabel('DESKRIPSI ACARA'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _deskripsiCtrl,
                    maxLines: 4,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      color: _onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Tuliskan pesan atau detail tambahan untuk tamu undangan...',
                      hintStyle: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        color: _onSurfaceVariant.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: _surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: _primaryContainer, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Lokasi Acara Card ─────────────────────────────────────────
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lokasi Acara',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tentukan titik kumpul untuk para tamu',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      color: _onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search lokasi
                  TextField(
                    controller: _lokasiCtrl,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      color: _onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari alamat atau gedung...',
                      hintStyle: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        color: _onSurfaceVariant.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Icon(Icons.location_on_outlined,
                          color: _primary, size: 22),
                      filled: true,
                      fillColor: _surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: const BorderSide(
                            color: _primaryContainer, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Map placeholder (Styled after image)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black, // Dark background from image
                        image: DecorationImage(
                          image: const NetworkImage('https://images.unsplash.com/photo-1534353436294-0dbd4bdac845?w=600'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.6),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Graphic center mock (the heart/poly)
                          Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFBA1A1A).withValues(alpha: 0.2),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.favorite,
                                  color: const Color(0xFFBA1A1A).withValues(alpha: 0.8),
                                  size: 60,
                                ),
                              ),
                            ),
                          ),
                          // Pin marker
                          Center(
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _primary,
                                border: Border.all(
                                    color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: _primary.withValues(alpha: 0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Harapan Jenis Sumbangan Card ──────────────────────────────
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Harapan Jenis Sumbangan',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Bantu tamu mempersiapkan 'Buwoh' yang sesuai",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      color: _onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Beras
                  _SumbanganItem(
                    icon: Icons.rice_bowl_outlined,
                    label: 'Beras',
                    value: _beras,
                    highlighted: false,
                    onChanged: (v) => setState(() => _beras = v),
                  ),
                  const SizedBox(height: 10),

                  // Gula
                  _SumbanganItem(
                    icon: Icons.water_drop_outlined,
                    label: 'Gula',
                    value: _gula,
                    highlighted: false,
                    onChanged: (v) => setState(() => _gula = v),
                  ),
                  const SizedBox(height: 10),

                  // Uang
                  _SumbanganItem(
                    icon: Icons.payments,
                    label: 'Uang',
                    value: _uang,
                    highlighted: true,
                    onChanged: (v) => setState(() => _uang = v),
                  ),

                  const SizedBox(height: 16),

                  // Tip box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _tertiaryFixed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: _tertiaryFixed.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.favorite,
                            color: _tertiary, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Mencantumkan preferensi membantu mengelola logistik hajatan dengan lebih baik.',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _tertiary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Submit Button ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 4,
                  shadowColor: _primaryContainer.withValues(alpha: 0.3),
                ),
                child: _isLoading 
                ? const SizedBox(
                    height: 20, 
                    width: 20, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Terbitkan Undangan',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.send_outlined, size: 20),
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

// ── Helper Widgets ──────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF134231).withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF134231),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _RoundedTextField(
      {required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        color: Color(0xFF191C1B),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          color: const Color(0xFF414944).withValues(alpha: 0.4),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFF2F4F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide:
              const BorderSide(color: Color(0xFF2D5A47), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      ),
    );
  }
}

class _TapField extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool hasValue;
  final VoidCallback onTap;

  const _TapField({
    required this.text,
    required this.icon,
    required this.hasValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: hasValue
                    ? const Color(0xFF134231)
                    : const Color(0xFF717974)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: hasValue
                      ? const Color(0xFF191C1B)
                      : const Color(0xFF414944).withValues(alpha: 0.5),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SumbanganItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final bool highlighted;
  final ValueChanged<bool> onChanged;

  const _SumbanganItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.highlighted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F2),
          borderRadius: BorderRadius.circular(16),
          border: highlighted
              ? Border.all(
                  color: const Color(0xFFFFE16D).withValues(alpha: 0.5),
                  width: 2)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: highlighted
                    ? const Color(0xFFFFE16D).withValues(alpha: 0.3)
                    : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(icon,
                  color: const Color(0xFF134231), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF134231),
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF2D5A47),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFE1E3E1),
            ),
          ],
        ),
      ),
    );
  }
}


