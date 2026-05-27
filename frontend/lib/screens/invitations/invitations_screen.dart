import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/invitation_provider.dart';
import '../../models/invitation_model.dart';
import 'invitation_detail_screen.dart';
import '../../config/api_config.dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({super.key});

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  int _selectedFilter = 0;
  final _searchCtrl = TextEditingController();

  static const _primary = Color(0xFF134231);
  static const _primaryContainer = Color(0xFF2D5A47);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _outline = Color(0xFF717974);
  static const _surfaceContainerHigh = Color(0xFFE6E9E7);
  static const _surfaceContainerLow = Color(0xFFF2F4F2);
  static const _background = Color(0xFFF8FAF8);

  final _filters = ['Semua', 'Pernikahan', 'Khitanan', 'Tasyakuran'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvitationProvider>(context, listen: false).fetchInvitations();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onFilterChanged(int index) {
    setState(() => _selectedFilter = index);
    Provider.of<InvitationProvider>(context, listen: false).fetchInvitations(
      search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
      type: _filters[index],
    );
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
          'Undangan',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _primary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Search + Filter ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchCtrl,
                  onSubmitted: (val) {
                    Provider.of<InvitationProvider>(context, listen: false).fetchInvitations(
                      search: val.isEmpty ? null : val,
                      type: _filters[_selectedFilter],
                    );
                  },
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: _onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari undangan atau tuan rumah...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      color: _outline,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_outlined,
                      color: _outline,
                      size: 22,
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
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Filter chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final selected = _selectedFilter == i;
                      return GestureDetector(
                        onTap: () => _onFilterChanged(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? _primaryContainer
                                : _surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _filters[i],
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : _primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── List ────────────────────────────────────────────────────────
          Expanded(
            child: Consumer<InvitationProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.invitations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_outlined,
                          size: 56,
                          color: _outline.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tidak ada undangan ditemukan',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            color: _onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchInvitations(
                    search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
                    type: _filters[_selectedFilter],
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    itemCount: provider.invitations.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (_, i) {
                      final inv = provider.invitations[i];
                      return _InvitationCard(
                        invitation: inv,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InvitationDetailScreen(
                              eventId: inv.eventId,
                              namaAcara: inv.title,
                              namaHost: inv.hostName,
                              tanggal: inv.date,
                              waktu: inv.time,
                              lokasi: inv.locationName,
                              jenis: inv.type.toUpperCase(),
                              imageUrl: inv.imageUrl.startsWith('http')
                                  ? inv.imageUrl
                                  : '${ApiConfig.baseUrl.replaceAll('/api/v1', '')}${inv.imageUrl}',
                              isPrioritas: inv.isBalasBudi,
                            ),
                          ),
                        ),
                      );
                    },
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

// ── Invitation Card ──────────────────────────────────────────────────────────
class _InvitationCard extends StatelessWidget {
  final InvitationModel invitation;
  final VoidCallback onTap;

  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _outline = Color(0xFF717974);
  static const _tertiaryFixed = Color(0xFFFFE16D);

  const _InvitationCard({required this.invitation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 88,
                      height: 120,
                      child: Image.network(
                        invitation.imageUrl.startsWith('http')
                            ? invitation.imageUrl
                            : '${ApiConfig.baseUrl.replaceAll('/api/v1', '')}${invitation.imageUrl}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFE6E9E7),
                          child: const Icon(
                            Icons.image_outlined,
                            color: Color(0xFFC0C8C2),
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Content
                  Expanded(
                    child: SizedBox(
                      height: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invitation.type.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF134231),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                invitation.title,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _onSurface,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                invitation.hostName,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 13,
                                    color: _outline,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    invitation.date,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11,
                                      color: _outline,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_outlined,
                                    size: 13,
                                    color: _outline,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    (invitation.time.isNotEmpty) ? invitation.time : '-',
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11,
                                      color: _outline,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 13,
                                    color: _outline,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      invitation.locationName + (invitation.distanceKm != null ? ' • ${invitation.distanceKm!.toStringAsFixed(1)} km' : ''),
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 11,
                                        color: _outline,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Badge "Balas Budi"
            if (invitation.isBalasBudi)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _tertiaryFixed,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, size: 12, color: Color(0xFF221B00)),
                      SizedBox(width: 4),
                      const Text(
                        'BALAS BUDI',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF221B00),
                          letterSpacing: 1.0,
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
