import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

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
  TimeOfDay? _waktuMulai;
  bool _isLoading = false;

  bool _beras = true;
  bool _gula = false;
  bool _uang = true;

  File? _fotoUndangan;

  // Color Tokens
  static const _primary = Color(0xFF134231);
  static const _primaryContainer = Color(0xFF2D5A47);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _surfaceContainerLow = Color(0xFFF2F4F2);
  static const _surfaceContainerHigh = Color(0xFFE6E9E7);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _tertiary = Color(0xFF705D00);
  static const _tertiaryFixed = Color(0xFFFFE16D);
  static const _background = Color(0xFFF8FAF8);
  static const _outlineVariant = Color(0xFFC0C8C2);

  @override
  void dispose() {
    _namaCtrl.dispose();
    _lokasiCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFotoUndangan() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _fotoUndangan = File(image.path);
      });
    }
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

  Future<void> _pickWaktuMulai() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
    if (picked != null) setState(() => _waktuMulai = picked);
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'yyyy-mm-dd';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay? t) {
    if (t == null) return '--:--';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    // Validation
    if (_namaCtrl.text.isEmpty ||
        _tanggalMulai == null ||
        _waktuMulai == null ||
        _lokasiCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sila lengkapi semua data acara'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

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
                    Navigator.pop(context, {
                      'nama': _namaCtrl.text,
                      'tanggal': _formatDate(_tanggalMulai),
                      'jenis': 'ACARA BARU',
                      'fotoPath': _fotoUndangan?.path,
                    }); // Go back home with new event data
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: const Color(0xFFF8FAF8).withValues(alpha: 0.8),
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
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 80,
          24,
          40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero ──────────────────────────────────────────────────────
            const Text(
              'Langkah Pertama',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _onSurfaceVariant,
                letterSpacing: 2.0,
                textBaseline: TextBaseline.alphabetic,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Rencanakan\nHajatan Anda',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 30,
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
                fontSize: 14,
                color: _onSurfaceVariant,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 32),

            // ── Detail Acara Section ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF134231).withValues(alpha: 0.04),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel('NAMA ACARA'),
                  const SizedBox(height: 8),
                  _RoundedTextField(
                    controller: _namaCtrl,
                    hint: 'Contoh: Pernikahan Budi & Ani',
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('TANGGAL'),
                            const SizedBox(height: 8),
                            _TapField(
                              text: _formatDate(_tanggalMulai),
                              hasValue: _tanggalMulai != null,
                              onTap: _pickDateMulai,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('WAKTU'),
                            const SizedBox(height: 8),
                            _TapField(
                              text: _formatTime(_waktuMulai),
                              hasValue: _waktuMulai != null,
                              onTap: _pickWaktuMulai,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

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
                        color: _onSurfaceVariant.withValues(alpha: 0.4),
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
                          color: _primaryContainer,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Foto Sampul Acara Section ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF134231).withValues(alpha: 0.04),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Foto Sampul Acara',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Unggah foto undangan atau momen spesial Anda (Opsional)',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      color: _onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: _pickFotoUndangan,
                    child: Container(
                      height: 192,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _outlineVariant, width: 2),
                        image: _fotoUndangan != null
                            ? DecorationImage(
                                image: FileImage(_fotoUndangan!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _fotoUndangan == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.add_a_photo,
                                    color: _primaryContainer,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Unggah Foto Undangan',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'JPG, PNG MAX 5MB',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _onSurfaceVariant,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Lokasi Acara Section ─────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: _surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF134231).withValues(alpha: 0.04),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lokasi Acara',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tentukan titik kumpul untuk para tamu',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            color: _onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                    child: Column(
                      children: [
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
                              color: _onSurfaceVariant.withValues(alpha: 0.4),
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: const Icon(
                              Icons.location_on,
                              color: _primary,
                            ),
                            filled: true,
                            fillColor: _surfaceContainerLow,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: const BorderSide(
                                color: _primaryContainer,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
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

            // ── Harapan Jenis Sumbangan ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF134231).withValues(alpha: 0.04),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Harapan Jenis Sumbangan',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Bantu tamu mempersiapkan 'Buwoh' yang sesuai",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      color: _onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _SumbanganItem(
                    icon: Icons.bakery_dining,
                    label: 'Beras',
                    value: _beras,
                    highlighted: false,
                    onChanged: (v) => setState(() => _beras = v),
                  ),
                  const SizedBox(height: 12),
                  _SumbanganItem(
                    icon: Icons.opacity,
                    label: 'Gula',
                    value: _gula,
                    highlighted: false,
                    onChanged: (v) => setState(() => _gula = v),
                  ),
                  const SizedBox(height: 12),
                  _SumbanganItem(
                    icon: Icons.payments,
                    label: 'Uang',
                    value: _uang,
                    highlighted: true,
                    onChanged: (v) => setState(() => _uang = v),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _tertiaryFixed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _tertiaryFixed.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.favorite, color: _tertiary, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Mencantumkan preferensi membantu mengelola logistik hajatan dengan lebih baik.',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _tertiary,
                              height: 1.4,
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

            // ── Action Button ────────────────────────────────────────────────
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
                  elevation: 8,
                  shadowColor: _primaryContainer.withValues(alpha: 0.2),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Terbitkan Undangan',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.send, size: 20),
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

  const _RoundedTextField({required this.controller, required this.hint});

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
          borderSide: const BorderSide(color: Color(0xFF2D5A47), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
      ),
    );
  }
}

class _TapField extends StatelessWidget {
  final String text;
  final bool hasValue;
  final VoidCallback onTap;

  const _TapField({
    required this.text,
    required this.hasValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: hasValue
                ? const Color(0xFF191C1B)
                : const Color(0xFF414944).withValues(alpha: 0.5),
          ),
          overflow: TextOverflow.ellipsis,
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F2),
          borderRadius: BorderRadius.circular(16),
          border: highlighted
              ? Border.all(
                  color: const Color(0xFFFFE16D).withValues(alpha: 0.5),
                  width: 2,
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: highlighted
                    ? const Color(0xFFFFE16D).withValues(alpha: 0.3)
                    : Colors.white,
                boxShadow: highlighted
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ],
              ),
              child: Icon(
                icon,
                color: highlighted
                    ? const Color(0xFF544600)
                    : const Color(0xFF134231),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
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
