import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/history_provider.dart';
import '../../models/history_model.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedFilter = 0;
  String _selectedStatusFilter = 'Semua Status';
  final _searchCtrl = TextEditingController();

  static const _primary = Color(0xFF134231);
  static const _primaryContainer = Color(0xFF2D5A47);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _outline = Color(0xFF717974);
  static const _surfaceContainerLow = Color(0xFFF2F4F2);
  static const _surfaceContainerHigh = Color(0xFFE6E9E7);

  final _filters = ['Semua', 'Uang', 'Beras', 'Gula'];
  final _statusFilters = ['Semua Status', 'Menunggu Verifikasi', 'Sudah Diterima', 'Ditolak'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryProvider>(context, listen: false).fetchHistory();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        int tempSelectedType = _selectedFilter;
        String tempSelectedStatus = _selectedStatusFilter;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Riwayat',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Status Filter
                  const Text(
                    'Status Pengajuan',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _statusFilters.map((status) {
                      final isSelected = tempSelectedStatus == status;
                      return ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => tempSelectedStatus = status);
                          }
                        },
                        selectedColor: _primaryContainer,
                        backgroundColor: _surfaceContainerHigh,
                        labelStyle: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : _primary,
                        ),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                          side: BorderSide.none,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),

                  // Bawaan Filter
                  const Text(
                    'Jenis Bawaan',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_filters.length, (index) {
                      final isSelected = tempSelectedType == index;
                      return ChoiceChip(
                        label: Text(_filters[index]),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => tempSelectedType = index);
                          }
                        },
                        selectedColor: _primaryContainer,
                        backgroundColor: _surfaceContainerHigh,
                        labelStyle: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : _primary,
                        ),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                          side: BorderSide.none,
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = tempSelectedType;
                          _selectedStatusFilter = tempSelectedStatus;
                        });
                        Provider.of<HistoryProvider>(context, listen: false).fetchHistory(
                          filter: _filters[_selectedFilter],
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Terapkan',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 42),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Custom App Bar (Internal) ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primaryContainer,
                  ),
                  child: const Icon(
                    Icons.card_giftcard,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Buwoh',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Search bar & Filter Button ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (val) => setState(() {}),
                      onSubmitted: (val) => setState(() {}),
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        color: _onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari acara atau nama tuan rumah...',
                        hintStyle: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: _outline,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_outlined,
                          color: _outline,
                          size: 18,
                        ),
                        filled: true,
                        fillColor: _surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide(
                            color: _primary.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterModal,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── List ───────────────────────────────────────────────────────
          Expanded(
            child: Consumer<HistoryProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final query = _searchCtrl.text.toLowerCase();
                final filtered = provider.historyItems.where((i) {
                  // Text search
                  bool matchesQuery = true;
                  if (query.isNotEmpty) {
                    matchesQuery = i.title.toLowerCase().contains(query) ||
                        i.hostName.toLowerCase().contains(query);
                  }

                  // Status filter
                  bool matchesStatus = true;
                  if (_selectedStatusFilter == 'Menunggu Verifikasi') {
                    matchesStatus = i.status == 'pending';
                  } else if (_selectedStatusFilter == 'Sudah Diterima') {
                    matchesStatus = i.status == 'attended' || i.status == 'validated';
                  } else if (_selectedStatusFilter == 'Ditolak') {
                    matchesStatus = i.status == 'rejected';
                  }

                  return matchesQuery && matchesStatus;
                }).toList();

                if (filtered.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => provider.fetchHistory(filter: _filters[_selectedFilter]),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height - 300,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history_outlined,
                              size: 56,
                              color: _outline.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Tidak ada riwayat ditemukan',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                color: _onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchHistory(filter: _filters[_selectedFilter]),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (_, i) => _HistoryCard(item: filtered[i]),
                  ),
                );
              
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── History Card ────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final HistoryModel item;

  static const _primary = Color(0xFF134231);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _outlineVariant = Color(0xFFC0C8C2);
  static const _surfaceContainerLow = Color(0xFFF2F4F2);
  static const _surfaceContainerHigh = Color(0xFFE6E9E7);
  static const _tertiary = Color(0xFF705D00);

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Left accent bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 6,
              color: _tertiary,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: badge + tanggal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge area
                    Row(
                      children: [
                        // Logic for Balas Budi if available in model
                        if (item.isPriority) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7D6), // Light gold/yellow background
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFFFE16D)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.stars_rounded, size: 12, color: Color(0xFFB59500)),
                                SizedBox(width: 4),
                                Text(
                                  'BALAS BUDI',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFB59500),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.type.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _onSurfaceVariant,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Tanggal
                    Text(
                      item.date.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: _outlineVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Nama acara
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 13,
                        color: _onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.hostName,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: _onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Kontribusi chips
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.contributions
                        .map(
                          (k) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _surfaceContainerLow,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  k.type == 'uang' ? Icons.payments_outlined : 
                                  k.type == 'beras' ? Icons.rice_bowl_outlined :
                                  Icons.card_giftcard_outlined, 
                                  color: _primary, 
                                  size: 16
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  k.value,
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 14),

                // Footer: status + detail button
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.only(top: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: _outlineVariant.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatusBadge(statusStr: item.status),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryDetailScreen(
                                eventId: item.eventId,
                                nama: item.title,
                                host: item.hostName,
                                tanggal: item.date,
                                lokasi: item.locationName,
                                jenis: item.type,
                                status: item.status,
                                contributions: item.contributions,
                              ),
                            ),
                          );
                        },
                        icon: const Text(
                          'Detail',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                          ),
                        ),
                        label: const Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: _primary,
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
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

// ── Status Badge ────────────────────────────────────────────────────────────
class _StatusBadge extends StatefulWidget {
  final String statusStr;
  const _StatusBadge({required this.statusStr});

  @override
  State<_StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<_StatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.statusStr == 'pending') {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    bool isPulsing = false;

    switch (widget.statusStr) {
      case 'attended':
      case 'validated':
        color = const Color(0xFF16A34A);
        label = 'Sudah Diterima';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Ditolak';
        break;
      case 'pending':
      default:
        color = const Color(0xFFD97706);
        label = 'Menunggu Verifikasi';
        isPulsing = true;
        break;
    }

    return Row(
      children: [
        isPulsing
            ? FadeTransition(
                opacity: _pulse,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              )
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
