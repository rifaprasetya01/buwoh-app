import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final String? initialName;
  final String? initialAddress;
  final String? initialPhotoPath;

  const EditProfileScreen({
    super.key,
    this.initialName,
    this.initialAddress,
    this.initialPhotoPath,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _namaCtrl;
  late final TextEditingController _alamatCtrl;
  DateTime? _tanggalLahir = DateTime(1995, 8, 12);
  String? _fotoPath;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(
      text: widget.initialName ?? 'Ahmad Sudiro',
    );
    _alamatCtrl = TextEditingController(
      text: widget.initialAddress ?? 'Jl. Melati No. 45, Sleman, Yogyakarta',
    );
    _fotoPath = widget.initialPhotoPath;
  }

  static const _primary = Color(0xFF134231);
  static const _primaryContainer = Color(0xFF2D5A47);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _outlineVariant = Color(0xFFC0C8C2);
  static const _surfaceContainerLow = Color(0xFFF2F4F2);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _primaryFixedDim = Color(0xFFA1D1B9);
  static const _tertiary = Color(0xFF705D00);
  static const _tertiaryFixed = Color(0xFFFFE16D);
  static const _background = Color(0xFFF8FAF8);

  @override
  void dispose() {
    _namaCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }

  // ── Bottom Sheet Ubah Foto ─────────────────────────────────────────────────
  void _showFotoBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FotoBottomSheet(
        onKamera: () async {
          Navigator.pop(context);
          await _pickImage(ImageSource.camera);
        },
        onGaleri: () async {
          Navigator.pop(context);
          await _pickImage(ImageSource.gallery);
        },
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
      );
      if (picked != null) {
        setState(() => _fotoPath = picked.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tidak bisa mengakses ${source == ImageSource.camera ? "kamera" : "galeri"}',
            ),
            backgroundColor: const Color(0xFFBA1A1A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ?? DateTime(1995),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
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
    if (picked != null) setState(() => _tanggalLahir = picked);
  }

  String get _tanggalText {
    if (_tanggalLahir == null) return 'Pilih tanggal lahir';
    return '${_tanggalLahir!.day.toString().padLeft(2, '0')}/'
        '${_tanggalLahir!.month.toString().padLeft(2, '0')}/'
        '${_tanggalLahir!.year}';
  }

  void _simpan() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Profil berhasil disimpan',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor: _primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );

    // Return the updated data to the previous screen
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.pop(context, {
          'nama': _namaCtrl.text,
          'alamat': _alamatCtrl.text,
          'fotoPath': _fotoPath,
        });
      }
    });
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
          'Edit Profil',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Foto Profil ────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showFotoBottomSheet,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _surfaceContainerLowest,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _fotoPath != null
                                ? (kIsWeb
                                      ? Image.network(
                                          _fotoPath!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(_fotoPath!),
                                          fit: BoxFit.cover,
                                        ))
                                : Image.network(
                                    'https://i.pravatar.cc/150?img=56',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: const Color(0xFFE6E9E7),
                                      child: const Icon(
                                        Icons.person,
                                        size: 56,
                                        color: Color(0xFFC0C8C2),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _primaryContainer,
                              border: Border.all(color: _background, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryContainer.withOpacity(0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _showFotoBottomSheet,
                    child: Text(
                      'Ubah Foto Profil',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _primary.withOpacity(0.6),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ── Nama Lengkap ───────────────────────────────────────────
            const _FieldLabel('NAMA LENGKAP'),
            const SizedBox(height: 8),
            _RoundedField(controller: _namaCtrl, hint: 'Masukkan nama lengkap'),

            const SizedBox(height: 24),

            // ── Alamat Domisili ────────────────────────────────────────
            const _FieldLabel('ALAMAT DOMISILI'),
            const SizedBox(height: 8),
            TextField(
              controller: _alamatCtrl,
              maxLines: 3,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                color: _onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Masukkan alamat lengkap Anda',
                hintStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  color: _onSurfaceVariant.withOpacity(0.5),
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
                contentPadding: const EdgeInsets.all(20),
              ),
            ),

            const SizedBox(height: 24),

            // ── Tanggal Lahir ──────────────────────────────────────────
            const _FieldLabel('TANGGAL LAHIR'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: _surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: _onSurfaceVariant,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _tanggalText,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _tanggalLahir != null
                            ? _onSurface
                            : _onSurfaceVariant.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ── Simpan ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _simpan,
                icon: const Icon(Icons.save_outlined, size: 22),
                label: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 6,
                  shadowColor: _primary.withOpacity(0.15),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ── Privacy Card ───────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: const Border(
                  left: BorderSide(color: _tertiary, width: 6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF191C1B).withOpacity(0.04),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _tertiaryFixed,
                      ),
                      child: const Icon(
                        Icons.verified_user_outlined,
                        color: Color(0xFF221B00),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privasi Data Terjamin',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _primary,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Informasi pribadi Anda hanya digunakan untuk kebutuhan administrasi undangan dan tidak akan disebarluaskan.',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: _onSurfaceVariant,
                              height: 1.6,
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
      ),
    );
  }
}

// ── Bottom Sheet Ubah Foto ────────────────────────────────────────────────────
class _FotoBottomSheet extends StatelessWidget {
  final VoidCallback onKamera;
  final VoidCallback onGaleri;

  static const _primaryContainer = Color(0xFF2D5A47);
  static const _outlineVariant = Color(0xFFC0C8C2);

  const _FotoBottomSheet({required this.onKamera, required this.onGaleri});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grabber handle
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: _outlineVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
            child: Column(
              children: [
                // Judul
                const Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _primaryContainer,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 28),

                // Pilihan: Kamera & Galeri
                Row(
                  children: [
                    // Kamera
                    Expanded(
                      child: _FotoOption(
                        icon: Icons.photo_camera,
                        label: 'KAMERA',
                        onTap: onKamera,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Galeri
                    Expanded(
                      child: _FotoOption(
                        icon: Icons.photo_library_outlined,
                        label: 'GALERI',
                        onTap: onGaleri,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Batal
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      side: BorderSide(color: _outlineVariant.withValues(alpha: 0.6)),
                    ),
                    child: const Text(
                      'BATAL',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _primaryContainer,
                        letterSpacing: 2.0,
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

// ── Foto Option Button ────────────────────────────────────────────────────────
class _FotoOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FotoOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_FotoOption> createState() => _FotoOptionState();
}

class _FotoOptionState extends State<_FotoOption> {
  bool _pressed = false;

  static const _primaryContainer = Color(0xFF2D5A47);
  static const _primaryFixedDim = Color(0xFFA1D1B9);
  static const _surfaceContainerLow = Color(0xFFF2F4F2);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: _pressed
                ? const Color(0xFFC2E8D6).withOpacity(0.3)
                : _surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _pressed ? _primaryContainer : _primaryFixedDim,
                ),
                child: Icon(
                  widget.icon,
                  size: 30,
                  color: _pressed ? Colors.white : _primaryContainer,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _primaryContainer,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF134231).withOpacity(0.4),
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}

class _RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _RoundedField({required this.controller, required this.hint});

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
          color: const Color(0xFF414944).withOpacity(0.5),
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
          vertical: 18,
        ),
      ),
    );
  }
}
