import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/invitation_provider.dart';
import '../../services/api_service.dart';

import 'edit_buwoh_screen.dart';
import '../../utils/buwoh_dialogs.dart';
import '../../providers/history_provider.dart';
// ── Color Tokens (Global Scope) ───────────────────────────────────────────
const _primary = Color(0xFF134231);
const _primaryContainer = Color(0xFF2D5A47);
const _primaryFixed = Color(0xFFBCEDD4);
const _onSurface = Color(0xFF191C1B);
const _onSurfaceVariant = Color(0xFF414944);
const _outlineVariant = Color(0xFFC0C8C2);
const _surfaceContainerLow = Color(0xFFF2F4F2);
const _background = Color(0xFFF8FAF8);

class InvitationDetailScreen extends StatefulWidget {
  final String eventId;
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
  final bool hasSubmitted;

  const InvitationDetailScreen({
    super.key,
    required this.eventId,
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
    this.hasSubmitted = false,
  });

  @override
  State<InvitationDetailScreen> createState() => _InvitationDetailScreenState();
}

class _InvitationDetailScreenState extends State<InvitationDetailScreen> {
  bool _uang = false;
  bool _beras = false;
  bool _gula = false;

  final TextEditingController _uangCtrl = TextEditingController();
  final TextEditingController _berasCtrl = TextEditingController();
  final TextEditingController _gulaCtrl = TextEditingController();

  String? _loadedTitle;
  String? _loadedType;
  String? _loadedHostName;
  String? _loadedDate;
  String? _loadedStartTime;
  String? _loadedEndTime;
  String? _loadedLocation;
  String? _loadedImageUrl;
  String? _loadedDescription;
  String? _loadedMapLink;
  List<String> _expectedContributions = [];

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  @override
  void dispose() {
    _uangCtrl.dispose();
    _berasCtrl.dispose();
    _gulaCtrl.dispose();
    super.dispose();
  }

  String _formatImageUrl() {
    final path = _loadedImageUrl ?? widget.imageUrl;
    if (path.startsWith('http')) {
      return path;
    }
    return '${ApiConfig.baseUrl.replaceAll('/api/v1', '')}$path';
  }

  String _formatTimeRange() {
    final start = _loadedStartTime ?? widget.waktu;
    final end = _loadedEndTime;
    if (end != null && end.isNotEmpty) {
      return '$start - $end';
    }
    return start;
  }

  Future<void> _fetchDetails() async {
    try {
      final response = await ApiService.get('/invitations/${widget.eventId}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _loadedTitle = data['title'];
          _loadedType = data['type'];
          _loadedHostName = data['hostName'];
          _loadedDate = data['date'];
          _loadedStartTime = data['startTime'];
          _loadedEndTime = data['endTime'];
          _loadedLocation = data['locationName'];
          _loadedImageUrl = data['imageUrl'];
          _loadedDescription = data['description'];
          _loadedMapLink = data['mapLink'];
          final List<dynamic> ec = data['expectedContributions'] ?? [];
          _expectedContributions = ec.map((e) => e.toString()).toList();
          
          // Pre-check checkboxes if expected by host
          _uang = _expectedContributions.contains('uang');
          _beras = _expectedContributions.contains('beras');
          _gula = _expectedContributions.contains('gula');
        });
      }
    } catch (e) {
      debugPrint('Error fetching invitation details: $e');
    }
  }

  Future<void> _ajukanBuwoh() async {
    if (!_uang && !_beras && !_gula) {
      BuwohDialogs.showWarning(context, 'Pilih minimal satu jenis buwoh');
      return;
    }

    final provider = Provider.of<InvitationProvider>(context, listen: false);
    final List<Map<String, dynamic>> contributions = [];
    
    if (_uang) {
      final amt = int.tryParse(_uangCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (amt <= 0) {
        BuwohDialogs.showWarning(context, 'Masukkan nominal uang yang valid');
        return;
      }
      contributions.add({
        'type': 'uang',
        'amount': amt,
        'unit': 'rupiah',
        'notes': 'Ajukan buwoh uang',
      });
    }
    
    if (_beras) {
      final amt = int.tryParse(_berasCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (amt <= 0) {
        BuwohDialogs.showWarning(context, 'Masukkan jumlah beras yang valid');
        return;
      }
      contributions.add({
        'type': 'beras',
        'amount': amt,
        'unit': 'kg',
        'notes': 'Ajukan buwoh beras',
      });
    }
    
    if (_gula) {
      final amt = int.tryParse(_gulaCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (amt <= 0) {
        BuwohDialogs.showWarning(context, 'Masukkan jumlah gula yang valid');
        return;
      }
      contributions.add({
        'type': 'gula',
        'amount': amt,
        'unit': 'kg',
        'notes': 'Ajukan buwoh gula',
      });
    }

    final success = await provider.submitBuwoh(widget.eventId, contributions);

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
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
                  'Pengajuan Berhasil!',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Data pengajuan buwohan Anda berhasil dikirim. Apa yang ingin Anda lakukan selanjutnya?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: _onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx); // Close dialog
                          // Refresh current screen by replacing it with hasSubmitted: true
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InvitationDetailScreen(
                                eventId: widget.eventId,
                                namaAcara: widget.namaAcara,
                                namaHost: widget.namaHost,
                                tanggal: widget.tanggal,
                                waktu: widget.waktu,
                                lokasi: widget.lokasi,
                                jenis: widget.jenis,
                                imageUrl: widget.imageUrl,
                                hasSubmitted: true,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _outlineVariant),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text(
                          'Menetap',
                          style: TextStyle(color: _primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx); // Close dialog
                          Navigator.pop(context); // Go back to Home Screen
                          
                          // Explicitly refresh history data
                          Provider.of<HistoryProvider>(context, listen: false).fetchHistory();
                          
                          // Switch to History tab
                          Provider.of<AuthProvider>(context, listen: false).setActiveDashboardIndex(1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text('Lanjutkan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      BuwohDialogs.showError(context, 'Gagal mengirim pengajuan. Silakan coba lagi.');
    }
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
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final user = auth.user;
                final String? photoUrl = user?.photoUrl;

                Widget buildImage() {
                  if (photoUrl == null || photoUrl.isEmpty) {
                    return const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    );
                  }
                  if (photoUrl.startsWith('http')) {
                    return Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    );
                  }
                  if (photoUrl.startsWith('/uploads')) {
                    final fullUrl = '${ApiConfig.baseUrl.replaceAll('/api/v1', '')}$photoUrl';
                    return Image.network(
                      fullUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    );
                  }
                  return Image.file(
                    File(photoUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    if (user != null) {
                      // Switch global tab index to Profile (2)
                      auth.setActiveDashboardIndex(2);
                      // Pop until we return to the root screen (HomeScreen)
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _primaryContainer,
                    ),
                    child: ClipOval(
                      child: buildImage(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ── Bottom Action Bar ──────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 56),
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
            onPressed: widget.hasSubmitted
                ? () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditBuwohScreen(
                          eventId: widget.eventId,
                          namaAcara: _loadedTitle ?? widget.namaAcara,
                        ),
                      ),
                    );
                    if (result == true) {
                      // Optionally reload or show success
                    }
                  }
                : _ajukanBuwoh,
            icon: Icon(
              widget.hasSubmitted ? Icons.edit_outlined : Icons.volunteer_activism_outlined,
              size: 22,
            ),
            label: Text(
              widget.hasSubmitted ? 'Edit Buwohan' : 'Ajukan Buwoh',
              style: const TextStyle(
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
                      _formatImageUrl(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
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
                // if (widget.isPrioritas)
                //   Positioned(
                //     top: 80,
                //     left: 20,
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(
                //         horizontal: 14,
                //         vertical: 8,
                //       ),
                //       decoration: BoxDecoration(
                //         color: _tertiaryFixed,
                //         borderRadius: BorderRadius.circular(999),
                //       ),
                //       child: const Row(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           Icon(
                //             Icons.favorite,
                //             color: Color(0xFF221B00),
                //             size: 14,
                //           ),
                //           SizedBox(width: 6),
                //           Text(
                //             'ACARA PRIORITAS',
                //             style: TextStyle(
                //               fontFamily: 'Plus Jakarta Sans',
                //               fontSize: 10,
                //               fontWeight: FontWeight.w700,
                //               color: Color(0xFF221B00),
                //               letterSpacing: 1.0,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
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
                        // Badges
                        Row(
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
                                (_loadedType ?? widget.jenis).toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            if (widget.isPrioritas) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE16D).withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: const Color(0xFFFFE16D),
                                    width: 1,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      color: Color(0xFF221B00),
                                      size: 10,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'BALAS BUDI',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF221B00),
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          _loadedTitle ?? widget.namaAcara,
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
                          widget.subtitle ?? 'Hajatan ${_loadedHostName ?? widget.namaHost}',
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
                      title: _loadedDate ?? widget.tanggal,
                      subtitle: _formatTimeRange(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Lokasi
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.location_on_outlined,
                      label: 'Lokasi',
                      title: _loadedLocation ?? widget.lokasi,
                      subtitle: null,
                      trailing: (_loadedMapLink != null && _loadedMapLink!.isNotEmpty)
                          ? TextButton(
                              onPressed: () async {
                                final uri = Uri.parse(_loadedMapLink!);
                                final messenger = ScaffoldMessenger.of(context);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('Tidak dapat membuka link peta')),
                                  );
                                }
                              },
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
                            )
                          : null,
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
                      _loadedDescription ??
                          widget.deskripsi ??
                          "Assalamu'alaikum Warahmatullahi Wabarakatuh. "
                              "Dengan memohon rahmat dan ridho Allah SWT, kami mengundang "
                              "Bapak/Ibu/Saudara/i untuk hadir dalam acara ${_loadedTitle ?? widget.namaAcara}. "
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
                    controller: _uangCtrl,
                    hintText: 'Contoh: 100000',
                    unit: 'Rupiah',
                  ),
                  const SizedBox(height: 10),
                  _BuwohCheckItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Beras',
                    value: _beras,
                    onChanged: (v) => setState(() => _beras = v),
                    controller: _berasCtrl,
                    hintText: 'Contoh: 5',
                    unit: 'Kg',
                  ),
                  const SizedBox(height: 10),
                  _BuwohCheckItem(
                    icon: Icons.kitchen_outlined,
                    label: 'Gula',
                    value: _gula,
                    onChanged: (v) => setState(() => _gula = v),
                    controller: _gulaCtrl,
                    hintText: 'Contoh: 2',
                    unit: 'Kg',
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
  final TextEditingController? controller;
  final String? hintText;
  final String? unit;

  const _BuwohCheckItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.controller,
    this.hintText,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
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
        ),
        if (value && controller != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        color: Color(0xFFC0C8C2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFC0C8C2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFC0C8C2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF134231), width: 1.5),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    unit!,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF134231),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
