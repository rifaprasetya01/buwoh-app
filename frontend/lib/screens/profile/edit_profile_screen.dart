import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import '../../utils/buwoh_dialogs.dart';

class EditProfileScreen extends StatefulWidget {
  final String? initialName;
  final String? initialAddress;
  final String? initialPhotoPath;
  final bool startInEditMode;

  const EditProfileScreen({
    super.key,
    this.initialName,
    this.initialAddress,
    this.initialPhotoPath,
    this.startInEditMode = false,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _alamatCtrl = TextEditingController();
  final TextEditingController _rtCtrl = TextEditingController();
  final TextEditingController _rwCtrl = TextEditingController();
  final TextEditingController _desaCtrl = TextEditingController();
  final TextEditingController _kecamatanCtrl = TextEditingController();
  final TextEditingController _kotaCtrl = TextEditingController();
  final TextEditingController _provinsiCtrl = TextEditingController();
  final TextEditingController _kodePosCtrl = TextEditingController();
  DateTime? _tanggalLahir;
  String? _fotoPath;
  double? _lat;
  double? _lng;
  bool _isLoadingLocation = false;
  bool _isEditing = false;

  // Backup data for cancellation
  String? _backupNama;
  String? _backupAlamat;
  String? _backupRt;
  String? _backupRw;
  String? _backupDesa;
  String? _backupKecamatan;
  String? _backupKota;
  String? _backupProvinsi;
  String? _backupKodePos;
  DateTime? _backupTanggalLahir;
  String? _backupFotoPath;
  double? _backupLat;
  double? _backupLng;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.startInEditMode;
    _tanggalLahir = DateTime(1995, 8, 12);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user != null) {
        _namaCtrl.text = user.name;
        _alamatCtrl.text = user.address?.street ?? "";
        
        final rtRw = user.address?.rtRw ?? "";
        if (rtRw.contains('/')) {
          final parts = rtRw.split('/');
          _rtCtrl.text = parts[0];
          _rwCtrl.text = parts.length > 1 ? parts[1] : "";
        } else {
          _rtCtrl.text = rtRw;
        }

        _desaCtrl.text = user.address?.village ?? "";
        _kecamatanCtrl.text = user.address?.district ?? "";
        _kotaCtrl.text = user.address?.city ?? "";
        _provinsiCtrl.text = user.address?.province ?? "";
        _kodePosCtrl.text = user.address?.postalCode ?? "";
        _lat = user.address?.latitude;
        _lng = user.address?.longitude;
        
        if (user.birthDate != null) {
          _tanggalLahir = DateTime.parse(user.birthDate!);
        }
        _fotoPath = user.photoUrl;
      }
      _backupData();
    } catch (e) {
      debugPrint('Error initializing EditProfileScreen: $e');
    }
  }

  void _backupData() {
    _backupNama = _namaCtrl.text;
    _backupAlamat = _alamatCtrl.text;
    _backupRt = _rtCtrl.text;
    _backupRw = _rwCtrl.text;
    _backupDesa = _desaCtrl.text;
    _backupKecamatan = _kecamatanCtrl.text;
    _backupKota = _kotaCtrl.text;
    _backupProvinsi = _provinsiCtrl.text;
    _backupKodePos = _kodePosCtrl.text;
    _backupTanggalLahir = _tanggalLahir;
    _backupFotoPath = _fotoPath;
    _backupLat = _lat;
    _backupLng = _lng;
  }

  void _revertData() {
    _namaCtrl.text = _backupNama ?? '';
    _alamatCtrl.text = _backupAlamat ?? '';
    _rtCtrl.text = _backupRt ?? '';
    _rwCtrl.text = _backupRw ?? '';
    _desaCtrl.text = _backupDesa ?? '';
    _kecamatanCtrl.text = _backupKecamatan ?? '';
    _kotaCtrl.text = _backupKota ?? '';
    _provinsiCtrl.text = _backupProvinsi ?? '';
    _kodePosCtrl.text = _backupKodePos ?? '';
    _tanggalLahir = _backupTanggalLahir;
    _fotoPath = _backupFotoPath;
    _lat = _backupLat;
    _lng = _backupLng;
  }

  bool _hasUnsavedChanges() {
    final currentRtRw = "${_rtCtrl.text}/${_rwCtrl.text}";
    final backupRtRw = "${_backupRt ?? ''}/${_backupRw ?? ''}";

    return _namaCtrl.text != (_backupNama ?? '') ||
        _alamatCtrl.text != (_backupAlamat ?? '') ||
        currentRtRw != backupRtRw ||
        _desaCtrl.text != (_backupDesa ?? '') ||
        _kecamatanCtrl.text != (_backupKecamatan ?? '') ||
        _kotaCtrl.text != (_backupKota ?? '') ||
        _provinsiCtrl.text != (_backupProvinsi ?? '') ||
        _kodePosCtrl.text != (_backupKodePos ?? '') ||
        _tanggalLahir != _backupTanggalLahir ||
        _fotoPath != _backupFotoPath ||
        _lat != _backupLat ||
        _lng != _backupLng;
  }

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
    _alamatCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    _desaCtrl.dispose();
    _kecamatanCtrl.dispose();
    _kotaCtrl.dispose();
    _provinsiCtrl.dispose();
    _kodePosCtrl.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _isLoadingLocation = false);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Lokasi Tidak Aktif', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold)),
                content: const Text('Layanan lokasi (GPS) pada perangkat Anda belum diaktifkan. Harap aktifkan terlebih dahulu untuk menggunakan fitur ini.', style: TextStyle(fontFamily: 'Plus Jakarta Sans')),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: _surfaceContainerLowest,
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal', style: TextStyle(color: Colors.grey, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Geolocator.openLocationSettings();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: _primaryContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Pengaturan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold)),
                  ),
                ],
              );
            },
          );
        }
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() => _isLoadingLocation = false);
            BuwohDialogs.showWarning(context, 'Izin lokasi ditolak.');
          }
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _isLoadingLocation = false);
          BuwohDialogs.showWarning(context, 'Izin lokasi ditolak permanen. Ubah di pengaturan aplikasi.');
        }
        return;
      } 

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // --- REVERSE GEOCODING ---
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          
          if (mounted) {
            setState(() {
              if (place.street != null && place.street!.isNotEmpty) _alamatCtrl.text = place.street!;
              if (place.subLocality != null && place.subLocality!.isNotEmpty) _desaCtrl.text = place.subLocality!;
              if (place.locality != null && place.locality!.isNotEmpty) _kecamatanCtrl.text = place.locality!;
              
              String kota = place.subAdministrativeArea ?? place.locality ?? '';
              if (kota.isNotEmpty) _kotaCtrl.text = kota.replaceAll('Kabupaten ', '').replaceAll('Kota ', '');
              
              if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) _provinsiCtrl.text = place.administrativeArea!;
              if (place.postalCode != null && place.postalCode!.isNotEmpty) _kodePosCtrl.text = place.postalCode!;
            });
          }
        }
      } catch (e) {
        debugPrint('Geocoding error: $e');
      }

      if (mounted) {
        setState(() {
          _lat = position.latitude;
          _lng = position.longitude;
          _isLoadingLocation = false;
        });
        BuwohDialogs.showSuccess(context, 'Lokasi berhasil diperbarui!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
        if (e.toString().contains('MissingPluginException')) {
          BuwohDialogs.showWarning(context, 'Harap RESTARTS aplikasi (Stop & Run ulang) karena plugin baru (Geolocator) telah ditambahkan.');
        } else {
          BuwohDialogs.showError(context, 'Gagal mendapatkan lokasi: $e');
        }
      }
    }
  }

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
        BuwohDialogs.showError(
          context,
          'Tidak bisa mengakses ${source == ImageSource.camera ? "kamera" : "galeri"}',
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

  Future<void> _cancelEdit() async {
    if (_hasUnsavedChanges()) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Abaikan Perubahan?',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin membatalkan pengeditan? Semua perubahan yang belum disimpan akan hilang.',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Lanjutkan Edit',
                style: TextStyle(color: Colors.grey, fontFamily: 'Plus Jakarta Sans'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFFBA1A1A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Abaikan',
                style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      if (shouldDiscard != true) return;
    }

    setState(() {
      _revertData();
      _isEditing = false;
    });
  }

  Future<void> _simpan() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    final isNameChanged = _namaCtrl.text != user?.name;
    final rtRw = "${_rtCtrl.text}/${_rwCtrl.text}";
    
    final isAddressChanged = 
        _alamatCtrl.text != (user?.address?.street ?? "") ||
        rtRw != (user?.address?.rtRw ?? "") ||
        _desaCtrl.text != (user?.address?.village ?? "") ||
        _kecamatanCtrl.text != (user?.address?.district ?? "") ||
        _kotaCtrl.text != (user?.address?.city ?? "") ||
        _provinsiCtrl.text != (user?.address?.province ?? "") ||
        _kodePosCtrl.text != (user?.address?.postalCode ?? "") ||
        _lat != user?.address?.latitude ||
        _lng != user?.address?.longitude;

    final isBirthDateChanged = _tanggalLahir?.toIso8601String().split('T')[0] != user?.birthDate?.split('T')[0];
    final isPhotoChanged = _fotoPath != user?.photoUrl && _fotoPath != null && !_fotoPath!.startsWith('http') && !_fotoPath!.startsWith('/uploads');

    if (!isNameChanged && !isAddressChanged && !isBirthDateChanged && !isPhotoChanged) {
      setState(() {
        _isEditing = false;
        _backupData();
      });
      return;
    }

    final success = await authProvider.updateProfile(
      name: isNameChanged ? _namaCtrl.text : null,
      street: _alamatCtrl.text,
      rtRw: rtRw,
      village: _desaCtrl.text,
      district: _kecamatanCtrl.text,
      city: _kotaCtrl.text,
      province: _provinsiCtrl.text,
      postalCode: _kodePosCtrl.text,
      latitude: _lat,
      longitude: _lng,
      birthDate: isBirthDateChanged ? _tanggalLahir?.toIso8601String().split('T')[0] : null,
      photo: isPhotoChanged ? File(_fotoPath!) : null,
    );

    if (mounted) {
      if (success) {
        BuwohDialogs.showSuccess(context, 'Profil berhasil disimpan');
        setState(() {
          _isEditing = false;
          _backupData();
        });
      } else {
        BuwohDialogs.showError(context, 'Gagal memperbarui profil');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isEditing,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _cancelEdit();
      },
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _background.withValues(alpha: 0.82),
          elevation: 0,
          scrolledUnderElevation: 0,
          leadingWidth: _isEditing ? 80 : 56,
          leading: _isEditing
              ? TextButton(
                  onPressed: _cancelEdit,
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: _primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back, color: _primary),
                  onPressed: () => Navigator.pop(context),
                ),
          title: Text(
            _isEditing ? 'Sunting Profil' : 'Detail Profil',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: _primary),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                    _backupData();
                  });
                },
              ),
          ],
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
                      onTap: _isEditing ? _showFotoBottomSheet : null,
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
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _fotoPath != null
                                  ? (_fotoPath!.startsWith('http') || _fotoPath!.startsWith('/uploads')
                                        ? Image.network(
                                            _fotoPath!.startsWith('/uploads')
                                              ? '${ApiConfig.baseUrl.replaceAll('/api/v1', '')}$_fotoPath'
                                              : _fotoPath!,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(_fotoPath!),
                                            fit: BoxFit.cover,
                                          ))
                                  : Image.network(
                                      'https://i.pravatar.cc/150?img=56',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
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
                          if (_isEditing)
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
                                      color: _primaryContainer.withValues(alpha: 0.3),
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
                    if (_isEditing) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _showFotoBottomSheet,
                        child: Text(
                          'Ubah Foto Profil',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _primary.withValues(alpha: 0.6),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Nama Lengkap ───────────────────────────────────────────
              const _FieldLabel('NAMA LENGKAP'),
              const SizedBox(height: 8),
              _RoundedField(
                controller: _namaCtrl,
                hint: 'Masukkan nama lengkap',
                enabled: _isEditing,
              ),

              const SizedBox(height: 24),

              // ── Alamat Domisili ────────────────────────────────────────
              const _FieldLabel('NAMA JALAN / KOMPLEK'),
              const SizedBox(height: 8),
              _RoundedField(
                controller: _alamatCtrl,
                hint: 'Contoh: Jl. Melati No. 123',
                enabled: _isEditing,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('RT'),
                        const SizedBox(height: 8),
                        _RoundedField(
                          controller: _rtCtrl,
                          hint: '001',
                          enabled: _isEditing,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('RW'),
                        const SizedBox(height: 8),
                        _RoundedField(
                          controller: _rwCtrl,
                          hint: '005',
                          enabled: _isEditing,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('DESA / KELURAHAN'),
                        const SizedBox(height: 8),
                        _RoundedField(
                          controller: _desaCtrl,
                          hint: 'Contoh: Condongcatur',
                          enabled: _isEditing,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('KECAMATAN'),
                        const SizedBox(height: 8),
                        _RoundedField(
                          controller: _kecamatanCtrl,
                          hint: 'Contoh: Depok',
                          enabled: _isEditing,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('KOTA / KABUPATEN'),
                        const SizedBox(height: 8),
                        _RoundedField(
                          controller: _kotaCtrl,
                          hint: 'Contoh: Sleman',
                          enabled: _isEditing,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('PROVINSI'),
                        const SizedBox(height: 8),
                        _RoundedField(
                          controller: _provinsiCtrl,
                          hint: 'Contoh: DIY',
                          enabled: _isEditing,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const _FieldLabel('KODE POS'),
              const SizedBox(height: 8),
              _RoundedField(
                controller: _kodePosCtrl,
                hint: 'Contoh: 55283',
                enabled: _isEditing,
              ),

              const SizedBox(height: 24),

              // ── Lokasi Maps ────────────────────────────────────────────
              const _FieldLabel('KOORDINAT LOKASI (LAT, LONG)'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isEditing ? _surfaceContainerLow : _background,
                  borderRadius: BorderRadius.circular(16),
                  border: _isEditing ? null : Border.all(color: Colors.black.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _lat != null && _lng != null 
                          ? '${_lat!.toStringAsFixed(6)}, ${_lng!.toStringAsFixed(6)}'
                          : 'Lokasi belum diset',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: _lat != null ? _onSurface : _onSurfaceVariant.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (_isEditing) ...[
                      if (_isLoadingLocation)
                        const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      else
                        TextButton.icon(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.my_location, size: 18),
                          label: const Text('Ambil Lokasi'),
                          style: TextButton.styleFrom(foregroundColor: _primaryContainer),
                        ),
                    ]
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Tanggal Lahir ──────────────────────────────────────────
              const _FieldLabel('TANGGAL LAHIR'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _isEditing ? _pickDate : null,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: _isEditing ? _surfaceContainerLow : _background,
                    borderRadius: BorderRadius.circular(999),
                    border: _isEditing ? null : Border.all(color: Colors.black.withValues(alpha: 0.05)),
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
                              : _onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_isEditing) ...[
                const SizedBox(height: 40),

                // ── Simpan ─────────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) => ElevatedButton.icon(
                      onPressed: auth.isLoading ? null : _simpan,
                      icon: auth.isLoading 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Icon(Icons.save_outlined, size: 22),
                      label: Text(
                        auth.isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
                        style: const TextStyle(
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
                        shadowColor: _primary.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ),
              ],

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
                      color: const Color(0xFF191C1B).withValues(alpha: 0.04),
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
                            SizedBox(height: 42),
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
      ),
    );
  }
}

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
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: _outlineVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
            child: Column(
              children: [
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

                Row(
                  children: [
                    Expanded(
                      child: _FotoOption(
                        icon: Icons.photo_camera,
                        label: 'KAMERA',
                        onTap: onKamera,
                      ),
                    ),
                    const SizedBox(width: 16),
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
                ? const Color(0xFFC2E8D6).withValues(alpha: 0.3)
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
          color: const Color(0xFF134231).withValues(alpha: 0.4),
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}

class _RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool enabled;

  const _RoundedField({
    required this.controller,
    required this.hint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        color: enabled ? const Color(0xFF191C1B) : const Color(0xFF191C1B).withValues(alpha: 0.6),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          color: const Color(0xFF414944).withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: enabled ? const Color(0xFFF2F4F2) : const Color(0xFFF8FAF8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1),
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
