import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:dotted_border/dotted_border.dart';
import '../events/create_event_screen.dart';
import './search_screen.dart';
import '../../config/api_config.dart';
import '../invitations/invitation_detail_screen.dart';
import '../history/history_screen.dart';

import '../profile/profile_screen.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/events_provider.dart';
import '../../providers/invitation_provider.dart';
import '../../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Widget> _buildPages(UserModel user, AuthProvider auth) {
    return [
      _HomeContent(
        user: user,
        onProfileTap: () {
          auth.setActiveDashboardIndex(2); // Switch to ProfileScreen tab
        },
      ),
      const HistoryScreen(),
      ProfileScreen(
        nama: user.name,
        alamat: user.address?.city ?? 'Alamat belum diatur',
        fotoPath: user.photoUrl,
        onProfileUpdated: (result) {
          // This should ideally trigger a provider refresh
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    // During logout, auth.user becomes null before the screen is fully unmounted 
    // due to AnimatedSwitcher's fade transition. Handle this to prevent red/black error screen.
    if (auth.user == null) {
      return const Scaffold(backgroundColor: AppColors.background);
    }
    
    final user = auth.user!;
    final index = auth.activeDashboardIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: index, children: _buildPages(user, auth)),
      bottomNavigationBar: BuwohBottomNavBar(
        currentIndex: index,
        onTap: (newIndex) {
          auth.setActiveDashboardIndex(newIndex);
        },
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final UserModel user;
  final VoidCallback onProfileTap;

  const _HomeContent({required this.user, required this.onProfileTap});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventsProvider>(context, listen: false).fetchHostedEvents();
      Provider.of<EventsProvider>(
        context,
        listen: false,
      ).fetchReturnFavorEvents();
      Provider.of<InvitationProvider>(
        context,
        listen: false,
      ).fetchInvitations();
    });
  }

  Future<void> _navigateToCreateEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateEventScreen()),
    );
    // Refresh events after returning
    if (mounted) {
      Provider.of<EventsProvider>(context, listen: false).fetchHostedEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).fetchProfile();
                if (context.mounted) {
                  await Future.wait([
                    Provider.of<EventsProvider>(
                      context,
                      listen: false,
                    ).fetchHostedEvents(),
                    Provider.of<EventsProvider>(
                      context,
                      listen: false,
                    ).fetchReturnFavorEvents(),
                    Provider.of<InvitationProvider>(
                      context,
                      listen: false,
                    ).fetchInvitations(),
                  ]);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top App Bar ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: widget.onProfileTap,
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                children: [
                                  // Avatar
                                  Consumer<AuthProvider>(
                                    builder: (context, auth, _) {
                                      final user = auth.user;
                                      final String? photoUrl = user?.photoUrl;

                                      Widget buildImage() {
                                        if (photoUrl == null ||
                                            photoUrl.isEmpty) {
                                          return const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 22,
                                          );
                                        }
                                        if (photoUrl.startsWith('http')) {
                                          return Image.network(
                                            photoUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                const Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                          );
                                        }
                                        if (photoUrl.startsWith('/uploads')) {
                                          final fullUrl =
                                              '${ApiConfig.baseUrl.replaceAll('/api/v1', '')}$photoUrl';
                                          return Image.network(
                                            fullUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                const Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                          );
                                        }
                                        return Image.file(
                                          File(photoUrl),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                        );
                                      }

                                      return Container(
                                        width: 42,
                                        height: 42,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primaryContainer,
                                        ),
                                        child: ClipOval(child: buildImage()),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Consumer<AuthProvider>(
                                          builder: (context, auth, _) {
                                            return Text(
                                              auth.user?.name ??
                                                  widget.user.name,
                                              style: const TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.onSurface,
                                              ),
                                            );
                                          },
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              size: 12,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 2),
                                            Expanded(
                                              child: Text(
                                                widget.user.address?.city ??
                                                    'Lokasi tidak diketahui',
                                                style: TextStyle(
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
                                                  fontSize: 11,
                                                  color: AppColors
                                                      .onSurfaceVariant
                                                      .withValues(alpha: 0.8),
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
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: AppColors.onSurfaceVariant,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SearchScreen(),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.onSurfaceVariant,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    backgroundColor: AppColors.background,
                                    appBar: AppBar(
                                      backgroundColor: AppColors.background,
                                      elevation: 0,
                                      scrolledUnderElevation: 0,
                                      leading: IconButton(
                                        icon: const Icon(
                                          Icons.arrow_back,
                                          color: AppColors.primary,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      title: const Text(
                                        'Notifikasi',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    body: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.notifications_active_outlined,
                                            size: 64,
                                            color: AppColors.onSurfaceVariant
                                                .withValues(alpha: 0.5),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Fitur Segera Hadir!',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Kami sedang menyiapkan sesuatu yang luar biasa.',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 13,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Greeting Section ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Halo, ',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  final user = auth.user;
                                  String firstName = 'Sobat';
                                  if (user != null && user.name.isNotEmpty) {
                                    firstName = user.name.trim().split(' ')[0];
                                  }

                                  return Text(
                                    firstName,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                      letterSpacing: -0.5,
                                    ),
                                  );
                                },
                              ),
                              Text(
                                "👋",
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),
                          const Text(
                            'Selamat datang kembali! Semoga hari Anda menyenangkan dan hajatan berjalan lancar.',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── My Event Card ────────────────────────────────────
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 20),
                    //   child: BuwohHeroEventCard(
                    //     events: widget.myEvents,
                    //     onTap: () {
                    //       // Jika sudah ada acara, buka Dashboard
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (_) => DashboardScreen(
                    //             nama: widget.nama,
                    //             fotoPath: widget.fotoPath,
                    // ── Acara Saya Section ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Consumer<EventsProvider>(
                        builder: (context, eventsProvider, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Balas Budi",
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  if (eventsProvider.returnFavorEvents.length >
                                      2)
                                    TextButton(
                                      onPressed: () {
                                        // TODO: Navigate to Return Favor specialized list if needed
                                      },
                                      child: const Text("Lihat Semua"),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                clipBehavior: Clip.none,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Create Button
                                    _buildCreateEventButton(),
                                    const SizedBox(width: 16),

                                    if (eventsProvider.isLoading)
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    else ...[
                                      // Return Favor Events
                                      ...eventsProvider.returnFavorEvents.map((
                                        event,
                                      ) {
                                        final String finalImageUrl =
                                            (event.imageUrl != null)
                                            ? (event.imageUrl!.startsWith(
                                                    'http',
                                                  )
                                                  ? event.imageUrl!
                                                  : '${ApiConfig.baseUrl.replaceAll('/api/v1', '')}${event.imageUrl}')
                                            : "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800";

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: BuwohReturnFavorCard(
                                            title: event.title,
                                            date: event.date,
                                            imageUrl: finalImageUrl,
                                            isNew: true, // It's upcoming/active
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      InvitationDetailScreen(
                                                        eventId: event.id,
                                                        namaAcara: event.title,
                                                        namaHost: 'Sobat Buwoh',
                                                        tanggal: event.date,
                                                        waktu:
                                                            event.startTime ??
                                                            '08:00',
                                                        lokasi:
                                                            event.locationName,
                                                        jenis: event.type
                                                            .toUpperCase(),
                                                        imageUrl: finalImageUrl,
                                                        isPrioritas: true,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }),

                                      // If empty, it will just show nothing after the "Buat Acara" button
                                      if (eventsProvider
                                          .returnFavorEvents
                                          .isEmpty) ...[
                                        // No dummy cards here anymore
                                      ],
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Agenda Mendatang Header ──────────────────────────
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Agenda Mendatang',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Vertical list undangan ───────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Consumer<InvitationProvider>(
                        builder: (context, invProvider, _) {
                          if (invProvider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final invitations = invProvider.invitations
                              .take(3)
                              .toList();

                          if (invitations.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  "Belum ada undangan mendatang.",
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 14,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: invitations.map((inv) {
                              final String finalImageUrl =
                                  (inv.imageUrl.isNotEmpty)
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
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateEventButton() {
    return Column(
      children: [
        SizedBox(
          width: 110,
          height: 180,
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              radius: const Radius.circular(55),
              color: AppColors.primary.withValues(alpha: 0.4),
              strokeWidth: 1.5,
              dashPattern: const [8.0, 5.0],
              padding: EdgeInsets.zero,
            ),
            child: Material(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(55),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _navigateToCreateEvent,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const SizedBox(
          width: 110,
          child: Text(
            "Buat Acara",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
