import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/events_provider.dart';

// ── Color Tokens (Global Scope) ───────────────────────────────────────────
const _primary = Color(0xFF134231);
const _primaryContainer = Color(0xFF2D5A47);
const _onSurfaceVariant = Color(0xFF414944);
const _surfaceContainerHigh = Color(0xFFE6E9E7);
const _surfaceContainerLowest = Color(0xFFFFFFFF);
const _secondaryContainer = Color(0xFFC2E8D6);
const _onSecondaryContainer = Color(0xFF476A5B);
const _secondary = Color(0xFF436557);
const _background = Color(0xFFF8FAF8);
const _tertiaryFixed = Color(0xFFFFE16D);
const _onTertiaryFixed = Color(0xFF221B00);
const _outlineVariant = Color(0xFFC0C8C2);

class RecapScreen extends StatefulWidget {
  final String eventId;

  const RecapScreen({super.key, required this.eventId});

  @override
  State<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends State<RecapScreen> {
  Map<String, dynamic>? _recapData;
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadRecap();
  }

  Future<void> _loadRecap() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<EventsProvider>(context, listen: false);
    final data = await provider.fetchEventRecap(widget.eventId);
    setState(() {
      _recapData = data;
      _isLoading = false;
    });
  }

  String formatRupiah(int number) {
    if (number == 0) return '0';
    final value = number.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = value.length - 1; i >= 0; i--) {
      buffer.write(value[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _background,
        body: Center(child: CircularProgressIndicator(color: _primary)),
      );
    }

    if (_recapData == null) {
      return Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _primary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Rekap Hajatan',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Gagal memuat rekap acara',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadRecap,
                style: ElevatedButton.styleFrom(backgroundColor: _primary),
                child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final String title = _recapData!['title'] ?? 'Rekap Hajatan';
    final String date = _recapData!['date'] ?? '';
    final int totalGuests = _recapData!['totalGuests'] ?? 0;
    
    // Summary values
    final Map<String, dynamic> summary = _recapData!['summary'] ?? {};
    final int berasSum = summary['beras']?.toInt() ?? 0;
    final int gulaSum = summary['gula']?.toInt() ?? 0;
    final int uangSum = summary['uang']?.toInt() ?? 0;

    // Search filtration
    final String query = _searchQuery.toLowerCase().trim();
    final List allGuests = _recapData!['guests'] ?? [];
    final List filteredGuests = allGuests.where((g) {
      final String name = (g['name'] ?? '').toLowerCase();
      final List conts = g['contributions'] ?? [];
      final String contributionsText = conts.isNotEmpty
          ? conts.map((c) => (c['value'] ?? '') as String).join(' ').toLowerCase()
          : '';
      return name.contains(query) || contributionsText.contains(query);
    }).toList();

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
      body: RefreshIndicator(
        onRefresh: _loadRecap,
        color: _primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            // Event Details Header
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _primary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tanggal Acara: $date',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      color: _onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

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
                            _SummaryItem(
                              label: 'Beras',
                              value: '$berasSum',
                              unit: 'Kg',
                            ),
                            VerticalDivider(
                              color: _outlineVariant.withValues(alpha: 0.2),
                              width: 24,
                            ),
                            _SummaryItem(
                              label: 'Gula',
                              value: '$gulaSum',
                              unit: 'Kg',
                            ),
                            VerticalDivider(
                              color: _outlineVariant.withValues(alpha: 0.2),
                              width: 24,
                            ),
                            _SummaryItem(
                              label: 'Uang',
                              value: formatRupiah(uangSum),
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
                      'Total $totalGuests tamu terdata',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        color: _onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search input field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _outlineVariant.withValues(alpha: 0.3)),
              ),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari nama tamu atau sumbangan...',
                  hintStyle: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    color: _onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: _onSurfaceVariant.withValues(alpha: 0.5),
                    size: 18,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _searchQuery = "";
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Guest list
            if (filteredGuests.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _searchQuery.isEmpty ? 'Belum ada tamu tervalidasi' : 'Tidak ada tamu bernama "$_searchQuery"',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      color: _onSurfaceVariant,
                    ),
                  ),
                ),
              ),

            ...filteredGuests.map((g) {
              final String guestName = g['name'] ?? 'Tamu';
              final List conts = g['contributions'] ?? [];
              final String contributionsText = conts.isNotEmpty
                  ? conts.map((c) => c['value']).join(', ')
                  : 'Tidak ada kontribusi';

              // Determine icon & colors based on contribution type
              Color avatarColor = _secondaryContainer;
              Color avatarIconColor = _onSecondaryContainer;
              IconData avatarIcon = Icons.person_outline;
              String jenisLabel = 'Lainnya';

              if (conts.isNotEmpty) {
                final String firstType = conts[0]['type'] ?? '';
                if (firstType == 'uang') {
                  avatarColor = _tertiaryFixed;
                  avatarIconColor = _onTertiaryFixed;
                  avatarIcon = Icons.payments_outlined;
                  jenisLabel = 'Uang';
                } else if (firstType == 'beras') {
                  avatarColor = _secondaryContainer;
                  avatarIconColor = _onSecondaryContainer;
                  avatarIcon = Icons.inventory_2_outlined;
                  jenisLabel = 'Beras';
                } else if (firstType == 'gula') {
                  avatarColor = _surfaceContainerHigh;
                  avatarIconColor = _primary;
                  avatarIcon = Icons.kitchen_outlined;
                  jenisLabel = 'Gula';
                }
              }

              String arrivalTime = '12:00 WIB';
              if (g['timeArrived'] != null) {
                try {
                  final parsed = DateTime.parse(g['timeArrived']).toLocal();
                  arrivalTime = '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')} WIB';
                } catch (_) {}
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _GuestItem(
                  nama: guestName,
                  avatarColor: avatarColor,
                  avatarIcon: avatarIcon,
                  avatarIconColor: avatarIconColor,
                  jenis: jenisLabel,
                  nilai: contributionsText,
                  jenisColor: _primaryContainer,
                  waktu: arrivalTime,
                  isBalasBudi: false,
                ),
              );
            }),

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
                    fontSize: 16,
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
                          fontSize: 13,
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
