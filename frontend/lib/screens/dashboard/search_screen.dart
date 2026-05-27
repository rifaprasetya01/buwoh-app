import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/events_provider.dart';
import '../../providers/invitation_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../config/api_config.dart';
import '../invitations/invitation_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
      // Ensure we have latest data
      Provider.of<InvitationProvider>(context, listen: false).fetchInvitations();
      Provider.of<EventsProvider>(context, listen: false).fetchReturnFavorEvents();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    final query = val.trim();
    if (query.isNotEmpty) {
      Provider.of<InvitationProvider>(context, listen: false).searchInvitations(query);
    } else {
      Provider.of<InvitationProvider>(context, listen: false).clearSearchResults();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final invProvider = Provider.of<InvitationProvider>(context);
    final eventsProvider = Provider.of<EventsProvider>(context);

    final query = _searchCtrl.text.trim().toLowerCase();
    final bool isSearching = query.isNotEmpty;

    // Filtered lists (Like Logic - invitations list is directly queried from backend!)
    final filteredInvitations = isSearching ? invProvider.searchResults : invProvider.invitations;

    final filteredFavors = eventsProvider.returnFavorEvents.where((e) {
      return e.title.toLowerCase().contains(query) ||
          e.locationName.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            Provider.of<InvitationProvider>(context, listen: false).clearSearchResults();
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Cari undangan, tuan rumah, atau lokasi...',
                hintStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  size: 18,
                ),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 16, color: AppColors.onSurfaceVariant),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isSearching) ...[
                // ── Rekomendasi Acara ────────────────────────────────────
                const Text(
                  'Rekomendasi Acara',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Berdasarkan undangan masuk dan riwayat balasan budi Anda',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),

                if (invProvider.isLoading || eventsProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (invProvider.invitations.isEmpty && eventsProvider.returnFavorEvents.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text(
                        'Belum ada rekomendasi acara.',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else ...[
                  // Combine lists or show invitations first as recommendation
                  ...invProvider.invitations.map((inv) {
                    final String finalImageUrl = (inv.imageUrl.isNotEmpty)
                        ? (inv.imageUrl.startsWith('http')
                            ? inv.imageUrl
                            : '${ApiConfig.baseUrl.replaceAll('/api/v1', '')}${inv.imageUrl}')
                        : '';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: BuwohInvitationCard(
                        jenis: inv.type.toUpperCase(),
                        nama: inv.title,
                        host: inv.hostName,
                        tanggal: inv.date,
                        lokasi: inv.locationName,
                        imageUrl: finalImageUrl,
                        waktu: inv.time,
                        jarakKm: inv.distanceKm,
                        hasSubmitted: inv.hasSubmitted,
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
                              imageUrl: finalImageUrl,
                              hasSubmitted: inv.hasSubmitted,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ] else ...[
                // ── Hasil Pencarian ──────────────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.saved_search, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Hasil Pencarian untuk "$query"',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (invProvider.isSearchLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (filteredInvitations.isEmpty && filteredFavors.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_outlined, size: 48, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text(
                            'Acara tidak ditemukan',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Coba gunakan kata kunci atau nama tuan rumah lain.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // 1. Matching Invitations
                  if (filteredInvitations.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12, left: 4),
                      child: Text(
                        'UNDANGAN & AGENDA MENDATANG',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...filteredInvitations.map((inv) {
                      final String finalImageUrl = (inv.imageUrl.isNotEmpty)
                          ? (inv.imageUrl.startsWith('http')
                              ? inv.imageUrl
                              : '${ApiConfig.baseUrl.replaceAll('/api/v1', '')}${inv.imageUrl}')
                          : '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: BuwohInvitationCard(
                          jenis: inv.type.toUpperCase(),
                          nama: inv.title,
                          host: inv.hostName,
                          tanggal: inv.date,
                          lokasi: inv.locationName,
                          imageUrl: finalImageUrl,
                          waktu: inv.time,
                          jarakKm: inv.distanceKm,
                          hasSubmitted: inv.hasSubmitted,
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
                                imageUrl: finalImageUrl,
                                hasSubmitted: inv.hasSubmitted,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  // 2. Matching Return Favor Events
                  if (filteredFavors.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12, left: 4),
                      child: Text(
                        'ACARA BALAS BUDI',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tertiary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...filteredFavors.map((event) {
                      final String finalImageUrl = (event.imageUrl != null)
                          ? (event.imageUrl!.startsWith('http')
                              ? event.imageUrl!
                              : '${ApiConfig.baseUrl.replaceAll('/api/v1', '')}${event.imageUrl}')
                          : "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800";

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: BuwohInvitationCard(
                          jenis: event.type.toUpperCase(),
                          nama: event.title,
                          host: 'Balas Budi',
                          tanggal: event.date,
                          lokasi: event.locationName,
                          imageUrl: finalImageUrl,
                          waktu: (event.startTime != null && event.endTime != null) ? '${event.startTime} - ${event.endTime}' : event.startTime,
                          onTap: () {
                            // Can open details or modal if needed
                          },
                        ),
                      );
                    }),
                  ],
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
