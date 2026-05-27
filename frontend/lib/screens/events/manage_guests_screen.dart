import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/events_provider.dart';
import '../../utils/buwoh_dialogs.dart';

class ManageGuestsScreen extends StatefulWidget {
  final String eventId;
  final String namaAcara;
  final String imageUrl;
  final String eventDate;

  const ManageGuestsScreen({
    super.key,
    required this.eventId,
    required this.namaAcara,
    required this.imageUrl,
    required this.eventDate,
  });

  @override
  State<ManageGuestsScreen> createState() => _ManageGuestsScreenState();
}

class _ManageGuestsScreenState extends State<ManageGuestsScreen> {
  List<Map<String, dynamic>> _guests = [];
  bool _isLoading = true;
  String _searchQuery = "";
  String _selectedFilter = "Semua"; // "Semua", "Orang Asing", "Calon Tamu", "Tamu Hadir"

  @override
  void initState() {
    super.initState();
    _loadGuests();
  }

  Future<void> _loadGuests() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<EventsProvider>(context, listen: false);
    final guestsList = await provider.fetchEventGuests(widget.eventId);
    setState(() {
      _guests = guestsList;
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(String guestId, String name, String status, String successMessage) async {
    try {
      final DateTime date = DateTime.parse(widget.eventDate);
      final DateTime today = DateTime.now();
      final DateTime todayDate = DateTime(today.year, today.month, today.day);
      final DateTime eventDateOnly = DateTime(date.year, date.month, date.day);
      
      final int diffDays = eventDateOnly.difference(todayDate).inDays;
      
      if (diffDays > 3 && status != 'rejected' && status != 'pending') {
        BuwohDialogs.showWarning(context, 'Verifikasi dan konfirmasi kehadiran hanya dapat dilakukan maksimal H-3 sebelum acara.');
        return;
      }
    } catch (_) {}

    final provider = Provider.of<EventsProvider>(context, listen: false);
    final success = await provider.updateGuestStatus(widget.eventId, guestId, status);
    if (success) {
      BuwohDialogs.showSuccess(context, successMessage);
      _loadGuests(); // Reload lists
    } else {
      BuwohDialogs.showError(context, 'Gagal memperbarui status tamu');
    }
  }

  void _showAddManualGuestDialog() {
    final emailController = TextEditingController();
    bool addUang = false;
    bool addBeras = false;
    bool addGula = false;
    final uangAmountController = TextEditingController(text: '100000');
    final berasAmountController = TextEditingController(text: '5');
    final gulaAmountController = TextEditingController(text: '2');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.person_add_outlined, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text(
                    'Tambah Tamu Manual',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Masukkan email pengguna terdaftar di BuwohApp:',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'email@domain.com',
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Pilih Kontribusi:',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Uang
                    CheckboxListTile(
                      activeColor: AppColors.primary,
                      title: const Text('Uang', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13)),
                      value: addUang,
                      onChanged: (val) => setDialogState(() => addUang = val ?? false),
                    ),
                    if (addUang)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                        child: TextField(
                          controller: uangAmountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Jumlah Uang (Rupiah)',
                            prefixText: 'Rp ',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    // Beras
                    CheckboxListTile(
                      activeColor: AppColors.primary,
                      title: const Text('Beras', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13)),
                      value: addBeras,
                      onChanged: (val) => setDialogState(() => addBeras = val ?? false),
                    ),
                    if (addBeras)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                        child: TextField(
                          controller: berasAmountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Jumlah Beras (kg)',
                            suffixText: ' kg',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    // Gula
                    CheckboxListTile(
                      activeColor: AppColors.primary,
                      title: const Text('Gula', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13)),
                      value: addGula,
                      onChanged: (val) => setDialogState(() => addGula = val ?? false),
                    ),
                    if (addGula)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                        child: TextField(
                          controller: gulaAmountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Jumlah Gula (kg)',
                            suffixText: ' kg',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('BATAL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final email = emailController.text.trim();
                    if (email.isEmpty) {
                      BuwohDialogs.showWarning(context, 'Email tidak boleh kosong');
                      return;
                    }
                    if (!addUang && !addBeras && !addGula) {
                      BuwohDialogs.showWarning(context, 'Pilih minimal satu kontribusi');
                      return;
                    }

                    final List<Map<String, dynamic>> contributions = [];
                    if (addUang) {
                      contributions.add({
                        'type': 'uang',
                        'amount': int.tryParse(uangAmountController.text) ?? 100000,
                        'unit': 'rupiah',
                        'notes': 'Kontribusi Uang',
                      });
                    }
                    if (addBeras) {
                      contributions.add({
                        'type': 'beras',
                        'amount': int.tryParse(berasAmountController.text) ?? 5,
                        'unit': 'kg',
                        'notes': 'Kontribusi Beras',
                      });
                    }
                    if (addGula) {
                      contributions.add({
                        'type': 'gula',
                        'amount': int.tryParse(gulaAmountController.text) ?? 2,
                        'unit': 'kg',
                        'notes': 'Kontribusi Gula',
                      });
                    }

                    Navigator.pop(context); // Close dialog

                    final provider = Provider.of<EventsProvider>(context, listen: false);
                    final success = await provider.addManualGuest(widget.eventId, email, contributions);

                    if (!mounted) return;
                    if (success) {
                      BuwohDialogs.showSuccess(context, 'Tamu manual berhasil ditambahkan sebagai Calon Tamu!');
                      _loadGuests();
                    } else {
                      BuwohDialogs.showError(context, 'Gagal menambahkan tamu. Pastikan email terdaftar di database dan belum terdaftar di acara ini.');
                    }
                  },
                  child: const Text('TAMBAH'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterPill(String label, int count) {
    final bool isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? Colors.white.withValues(alpha: 0.2) : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String calculatedStatus = 'BERLANGSUNG';
    Color statusBgColor = Colors.green.withValues(alpha: 0.25);
    Color statusTextColor = Colors.greenAccent;

    try {
      final DateTime date = DateTime.parse(widget.eventDate);
      final DateTime today = DateTime.now();
      final DateTime todayDate = DateTime(today.year, today.month, today.day);
      final DateTime eventDateOnly = DateTime(date.year, date.month, date.day);
      
      if (eventDateOnly.isAfter(todayDate)) {
        calculatedStatus = 'SEGERA HADIR';
        statusBgColor = Colors.orange.withValues(alpha: 0.25);
        statusTextColor = Colors.orange.shade300;
      } else if (eventDateOnly.isBefore(todayDate)) {
        calculatedStatus = 'SELESAI';
        statusBgColor = Colors.red.withValues(alpha: 0.25);
        statusTextColor = Colors.red.shade300;
      }
    } catch (_) {}

    // ── Filtering & Searching Logic ──────────────────────────────────────────
    final String query = _searchQuery.toLowerCase().trim();
    final List<Map<String, dynamic>> searchedGuests = _guests.where((g) {
      final String name = (g['name'] ?? '').toLowerCase();
      
      final List conts = g['contributions'] ?? [];
      final String contributionsText = conts.isNotEmpty
          ? conts.map((c) => (c['value'] ?? '') as String).join(' ').toLowerCase()
          : '';
      
      return name.contains(query) || contributionsText.contains(query);
    }).toList();

    // Separate based on 2-step verification status
    final List<Map<String, dynamic>> pendingGuests =
        searchedGuests.where((g) => g['status'] == 'pending').toList();
    final List<Map<String, dynamic>> validatedGuests =
        searchedGuests.where((g) => g['status'] == 'validated').toList();
    final List<Map<String, dynamic>> attendedGuests =
        searchedGuests.where((g) => g['status'] == 'attended').toList();
    final List<Map<String, dynamic>> rejectedGuests =
        searchedGuests.where((g) => g['status'] == 'rejected').toList();

    // Raw counts for pills
    final int totalCount = _guests.length;
    final int pendingCount = _guests.where((g) => g['status'] == 'pending').length;
    final int validatedCount = _guests.where((g) => g['status'] == 'validated').length;
    final int attendedCount = _guests.where((g) => g['status'] == 'attended').length;
    final int rejectedCount = _guests.where((g) => g['status'] == 'rejected').length;

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
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadGuests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadGuests,
              color: AppColors.primary,
              child: ListView(
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
                            // Cover Image
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
                                  widget.imageUrl,
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
                                      color: statusBgColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      calculatedStatus,
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        color: statusTextColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.namaAcara,
                                    style: const TextStyle(
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
                                    'Mengelola tamu Anda.',
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
                                  Text(
                                    '$attendedCount/${validatedCount + attendedCount}',
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFC5EBD9),
                                    ),
                                  ),
                                  Text(
                                    'HADIR',
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

                  // ── Search Bar ─────────────────────────────────────────────────
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.onSurface.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari nama tamu atau jenis kontribusi...',
                        hintStyle: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = "";
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Filter Pills (Horizontal Scroll) ───────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterPill("Semua", totalCount),
                        const SizedBox(width: 8),
                        _buildFilterPill("Orang Asing", pendingCount),
                        const SizedBox(width: 8),
                        _buildFilterPill("Calon Tamu", validatedCount),
                        const SizedBox(width: 8),
                        _buildFilterPill("Tamu Hadir", attendedCount),
                        const SizedBox(width: 8),
                        _buildFilterPill("Ditolak", rejectedCount),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Lists Rendering based on selected pill tab ────────────────
                  if (searchedGuests.isEmpty && _searchQuery.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 20),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.search_off_outlined, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak ada tamu ditemukan',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kami tidak menemukan hasil untuk "$_searchQuery". Coba kata kunci lain.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Section 1: Orang Asing (Pending)
                  if (_selectedFilter == "Semua" || _selectedFilter == "Orang Asing") ...[
                    if (pendingGuests.isNotEmpty || _searchQuery.isEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
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
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '1. Pengajuan Orang Asing',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Menunggu verifikasi jadi calon tamu',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 10,
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
                              '${pendingGuests.length} Antrean',
                              style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onTertiaryContainer),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...pendingGuests.map((g) {
                        final String name = g['name'] ?? 'Tamu';
                        final String guestId = g['guestId'] ?? '';
                        final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

                        final List conts = g['contributions'] ?? [];
                        final String contributionsText = conts.isNotEmpty
                            ? conts.map((c) => c['value']).join(', ')
                            : 'Tidak ada kontribusi';

                        IconData kontribusiIcon = Icons.card_giftcard_outlined;
                        if (conts.isNotEmpty) {
                          final type = conts[0]['type'] as String;
                          if (type == 'uang') {
                            kontribusiIcon = Icons.payments_outlined;
                          } else if (type == 'beras') {
                            kontribusiIcon = Icons.inventory_2_outlined;
                          } else if (type == 'gula') {
                            kontribusiIcon = Icons.kitchen_outlined;
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: BuwohPendingGuestCard(
                            inisial: initial,
                            nama: name,
                            relasi: 'ORANG ASING',
                            kontribusiIcon: kontribusiIcon,
                            kontribusi: contributionsText,
                            onTolak: () => _updateStatus(
                              guestId,
                              name,
                              'rejected',
                              '$name telah ditolak',
                            ),
                            onTerima: () => _updateStatus(
                              guestId,
                              name,
                              'validated',
                              '$name diterima sebagai Calon Tamu',
                            ),
                          ),
                        );
                      }),
                      if (pendingGuests.isEmpty && _searchQuery.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              'Tidak ada antrean pengajuan baru ✓',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),
                    ]
                  ],

                  // Section 2: Calon Tamu (Disetujui)
                  if (_selectedFilter == "Semua" || _selectedFilter == "Calon Tamu") ...[
                    if (validatedGuests.isNotEmpty || _searchQuery.isEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.secondaryContainer,
                                  ),
                                  child: const Icon(
                                    Icons.supervised_user_circle_outlined,
                                    color: AppColors.onSecondaryContainer,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '2. Calon Tamu (Disetujui)',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Konfirmasi saat sampai di lokasi acara',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 10,
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
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${validatedGuests.length} Calon',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...validatedGuests.map((g) {
                        final String name = g['name'] ?? 'Calon Tamu';
                        final String guestId = g['guestId'] ?? '';
                        final List conts = g['contributions'] ?? [];
                        final String contributionsText = conts.isNotEmpty
                            ? conts.map((c) => c['value']).join(', ')
                            : 'Tidak ada kontribusi';

                        IconData kontribusiIcon = Icons.card_giftcard_outlined;
                        if (conts.isNotEmpty) {
                          final type = conts[0]['type'] as String;
                          if (type == 'uang') {
                            kontribusiIcon = Icons.payments_outlined;
                          } else if (type == 'beras') {
                            kontribusiIcon = Icons.inventory_2_outlined;
                          } else if (type == 'gula') {
                            kontribusiIcon = Icons.kitchen_outlined;
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _CalonTamuCard(
                            nama: name,
                            kontribusi: contributionsText,
                            kontribusiIcon: kontribusiIcon,
                            onHadir: () => _updateStatus(
                              guestId,
                              name,
                              'attended',
                              '$name telah tiba di lokasi acara!',
                            ),
                          ),
                        );
                      }),
                      if (validatedGuests.isEmpty && _searchQuery.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              'Belum ada calon tamu terdaftar',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),
                    ]
                  ],

                  // Section 3: Tamu Hadir
                  if (_selectedFilter == "Semua" || _selectedFilter == "Tamu Hadir") ...[
                    if (attendedGuests.isNotEmpty || _searchQuery.isEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFE8F5E9),
                                ),
                                child: const Icon(
                                  Icons.verified_outlined,
                                  color: Color(0xFF2E7D32),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tamu Hadir di Lokasi',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Tamu resmi yang sudah di lokasi',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 10,
                                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${attendedGuests.length} Hadir',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...attendedGuests.map((g) {
                        final String name = g['name'] ?? 'Tamu Hadir';
                        final List conts = g['contributions'] ?? [];
                        final String contributionsText = conts.isNotEmpty
                            ? conts.map((c) => c['value']).join(', ')
                            : 'Tidak ada kontribusi';

                        IconData kontribusiIcon = Icons.card_giftcard_outlined;
                        if (conts.isNotEmpty) {
                          final type = conts[0]['type'] as String;
                          if (type == 'uang') {
                            kontribusiIcon = Icons.payments_outlined;
                          } else if (type == 'beras') {
                            kontribusiIcon = Icons.inventory_2_outlined;
                          } else if (type == 'gula') {
                            kontribusiIcon = Icons.kitchen_outlined;
                          }
                        }

                        String waktuText = 'Baru saja';
                        if (g['timeArrived'] != null) {
                          try {
                            final parsedTime = DateTime.parse(g['timeArrived']).toLocal();
                            waktuText =
                                '${parsedTime.hour.toString().padLeft(2, '0')}:${parsedTime.minute.toString().padLeft(2, '0')}';
                          } catch (_) {}
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: BuwohValidatedGuestCard(
                            nama: name,
                            waktu: waktuText,
                            kontribusiIcon: kontribusiIcon,
                            kontribusi: contributionsText,
                          ),
                        );
                      }),
                      if (attendedGuests.isEmpty && _searchQuery.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              'Belum ada tamu tiba di lokasi acara',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),
                    ]
                  ],

                  // Section 4: Ditolak
                  if (_selectedFilter == "Semua" || _selectedFilter == "Ditolak") ...[
                    if (rejectedGuests.isNotEmpty || _searchQuery.isEmpty) ...[
                      Row(
                        children: [
                          const Text(
                            'Tamu Ditolak',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${rejectedGuests.length} Ditolak',
                              style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...rejectedGuests.map((g) {
                        final String name = g['name'] ?? 'Tamu Ditolak';
                        final List conts = g['contributions'] ?? [];
                        final String contributionsText = conts.isNotEmpty
                            ? conts.map((c) => c['value']).join(', ')
                            : 'Tidak ada kontribusi';

                        IconData kontribusiIcon = Icons.card_giftcard_outlined;
                        if (conts.isNotEmpty) {
                          final type = conts[0]['type'] as String;
                          if (type == 'uang') {
                            kontribusiIcon = Icons.payments_outlined;
                          } else if (type == 'beras') {
                            kontribusiIcon = Icons.inventory_2_outlined;
                          } else if (type == 'gula') {
                            kontribusiIcon = Icons.kitchen_outlined;
                          }
                        }

                        final String guestId = g['guestId'] ?? g['id'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _RejectedGuestCard(
                            nama: name,
                            kontribusiIcon: kontribusiIcon,
                            kontribusi: contributionsText,
                            onRestore: () => _updateStatus(
                              guestId,
                              name,
                              'pending',
                              '$name dipulihkan sebagai Orang Asing',
                            ),
                          ),
                        );
                      }),
                      if (rejectedGuests.isEmpty && _searchQuery.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              'Belum ada tamu yang ditolak',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),
                    ]
                  ],

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
                            onPressed: _showAddManualGuestDialog,
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
            ),
    );
  }
}

// ── Custom Calon Tamu Card (Step 2 Verification) ───────────────────────────
class _CalonTamuCard extends StatelessWidget {
  final String nama;
  final String kontribusi;
  final IconData kontribusiIcon;
  final VoidCallback onHadir;

  const _CalonTamuCard({
    required this.nama,
    required this.kontribusi,
    required this.kontribusiIcon,
    required this.onHadir,
  });

  @override
  Widget build(BuildContext context) {

    final String initial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Initial Avatar
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHigh,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(kontribusiIcon, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        kontribusi,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action Button
          ElevatedButton.icon(
            onPressed: onHadir,
            icon: const Icon(Icons.check, size: 14),
            label: const Text(
              'Hadir',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Rejected Guest Card ───────────────────────────────────────────────
class _RejectedGuestCard extends StatelessWidget {
  final String nama;
  final IconData kontribusiIcon;
  final String kontribusi;
  final VoidCallback onRestore;

  const _RejectedGuestCard({
    required this.nama,
    required this.kontribusiIcon,
    required this.kontribusi,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.block, color: Colors.red, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Ditolak',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    kontribusiIcon,
                    size: 13,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    kontribusi,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 28,
                child: TextButton.icon(
                  onPressed: onRestore,
                  icon: const Icon(Icons.restore, size: 14),
                  label: const Text(
                    'Pulihkan',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
