import 'package:flutter/material.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedFilter = 0;
  final _searchCtrl = TextEditingController();

  static const _primary = Color(0xFF134231);
  static const _primaryContainer = Color(0xFF2D5A47);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _outline = Color(0xFF717974);
  static const _outlineVariant = Color(0xFFC0C8C2);
  static const _surfaceContainerLow = Color(0xFFF2F4F2);
  static const _surfaceContainerHigh = Color(0xFFE6E9E7);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _tertiary = Color(0xFF705D00);
  static const _tertiaryFixed = Color(0xFFFFE16D);
  static const _background = Color(0xFFF8FAF8);

  final _filters = ['Semua', 'Uang', 'Beras', 'Gula'];

  final _allHistory = [
    _HistoryItem(
      jenis: 'Syukuran Rumah',
      isBalasBudi: false,
      tanggal: '12 Okt 2023',
      nama: 'Rumah Baru Keluarga Budi',
      host: 'Keluarga Bapak Ahmad',
      kontribusi: [
        _Kontribusi(icon: Icons.payments_outlined, label: 'Rp 500.000'),
        _Kontribusi(icon: Icons.rice_bowl_outlined, label: '5 kg'),
      ],
      status: _Status.diterima,
      tags: ['Uang', 'Beras'],
    ),
    _HistoryItem(
      jenis: 'Hajatan Khitan',
      isBalasBudi: false,
      tanggal: '05 Sep 2023',
      nama: 'Syukuran Khitanan Iwan',
      host: 'Keluarga Ibu Ratna',
      kontribusi: [
        _Kontribusi(icon: Icons.payments_outlined, label: 'Rp 200.000'),
        _Kontribusi(icon: Icons.water_drop_outlined, label: '2 kg Gula'),
      ],
      status: _Status.diterima,
      tags: ['Uang', 'Gula'],
    ),
    _HistoryItem(
      jenis: 'Walimatul Ursy',
      isBalasBudi: false,
      tanggal: 'Baru Saja',
      nama: 'Pernikahan Dian & Ari',
      host: 'Bapak Haji Sulaiman',
      kontribusi: [
        _Kontribusi(icon: Icons.payments_outlined, label: 'Rp 1.000.000'),
      ],
      status: _Status.menunggu,
      tags: ['Uang'],
    ),
  ];

  List<_HistoryItem> get _filtered {
    final query = _searchCtrl.text.toLowerCase();
    var list = _allHistory;
    if (_selectedFilter != 0) {
      final tag = _filters[_selectedFilter];
      list = list.where((i) => i.tags.contains(tag)).toList();
    }
    if (query.isNotEmpty) {
      list = list
          .where(
            (i) =>
                i.nama.toLowerCase().contains(query) ||
                i.host.toLowerCase().contains(query),
          )
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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

        // ── Search bar ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
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

        const SizedBox(height: 12),

        // ── Filter chips ───────────────────────────────────────────────
        SizedBox(
          height: 30,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final selected = _selectedFilter == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedFilter = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? _primaryContainer : _surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _filters[i],
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : _primary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // ── List ───────────────────────────────────────────────────────
        Expanded(
          child: _filtered.isEmpty
              ? Center(
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
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => _HistoryCard(item: _filtered[i]),
                ),
        ),
      ],
    );
  }
}

// ── History Card ────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final _HistoryItem item;

  static const _primary = Color(0xFF134231);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _outlineVariant = Color(0xFFC0C8C2);
  static const _surfaceContainerLow = Color(0xFFF2F4F2);
  static const _surfaceContainerHigh = Color(0xFFE6E9E7);
  static const _tertiary = Color(0xFF705D00);
  static const _tertiaryFixed = Color(0xFFFFE16D);

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
          // Left accent bar (hanya untuk Balas Budi)
          // No left accent bar needed for now

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: badge + tanggal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge
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
                        item.jenis.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _onSurfaceVariant,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    // Tanggal
                    Text(
                      item.tanggal.toUpperCase(),
                      style: TextStyle(
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
                Text(
                  item.nama,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 13,
                      color: _onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.host,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Kontribusi chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: item.kontribusi
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
                              Icon(k.icon, color: _primary, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                k.label,
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

                const SizedBox(height: 14),

                // Footer: status + detail button
                Container(
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
                      if (item.status == _Status.menunggu)
                        _StatusBadge(status: item.status)
                      else
                        const SizedBox.shrink(),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryDetailScreen(
                                nama: item.nama,
                                host: item.host,
                                tanggal: item.tanggal,
                                lokasi:
                                    'Lokasi tidak tersedia', // Mock since not in item
                                jenis: item.jenis,
                                isAccepted: item.status == _Status.diterima,
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
  final _Status status;
  const _StatusBadge({required this.status});

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
    if (widget.status == _Status.menunggu) {
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
    final isDiterima = widget.status == _Status.diterima;
    final color = isDiterima
        ? const Color(0xFF16A34A)
        : const Color(0xFFD97706);
    final label = isDiterima ? 'Sudah Diterima' : 'Menunggu Verifikasi';

    return Row(
      children: [
        isDiterima
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              )
            : FadeTransition(
                opacity: _pulse,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
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

// ── Bottom Navigation ────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selected;
  const _BottomNav({required this.selected});

  static const _primary = Color(0xFF134231);
  static const _primaryContainer = Color(0xFF2D5A47);
  static const _onSurfaceVariant = Color(0xFF414944);

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
        'label': 'Beranda',
      },
      {
        'icon': Icons.history_outlined,
        'activeIcon': Icons.history,
        'label': 'Riwayat',
      },
      {
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
        'label': 'Profil',
      },
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1B).withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isActive = selected == i;
          return GestureDetector(
            onTap: () {
              if (i == 0) Navigator.pop(context);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? _primaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive
                        ? items[i]['activeIcon'] as IconData
                        : items[i]['icon'] as IconData,
                    color: isActive ? Colors.white : _onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[i]['label'] as String,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : _onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Data Models ─────────────────────────────────────────────────────────────
enum _Status { diterima, menunggu }

class _Kontribusi {
  final IconData icon;
  final String label;
  const _Kontribusi({required this.icon, required this.label});
}

class _HistoryItem {
  final String jenis;
  final bool isBalasBudi;
  final String tanggal;
  final String nama;
  final String host;
  final List<_Kontribusi> kontribusi;
  final _Status status;
  final List<String> tags;

  const _HistoryItem({
    required this.jenis,
    required this.isBalasBudi,
    required this.tanggal,
    required this.nama,
    required this.host,
    required this.kontribusi,
    required this.status,
    required this.tags,
  });
}
