import 'dart:io';
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/events_provider.dart';
import '../../config/api_config.dart';

class ProfileScreen extends StatefulWidget {
  final String nama;
  final String alamat;
  final String? fotoPath;
  final Function(Map<String, dynamic>)? onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.nama,
    required this.alamat,
    this.fotoPath,
    this.onProfileUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchProfile();
      Provider.of<EventsProvider>(context, listen: false).fetchHostedEvents();
    });
  }

  Widget _buildProfileImage(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) {
      return Container(
        color: AppColors.surfaceContainerLow,
        child: const Icon(Icons.person, size: 56, color: AppColors.outlineVariant),
      );
    }

    // Full URL from network
    if (photoPath.startsWith('http')) {
      return Image.network(
        photoPath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: AppColors.surfaceContainerLow,
          child: const Icon(Icons.person, size: 56, color: AppColors.outlineVariant),
        ),
      );
    }

    // Relative path from backend (e.g. /uploads/profiles/photo-xxx.jpg)
    if (photoPath.startsWith('/uploads')) {
      final fullUrl = '${ApiConfig.baseUrl.replaceAll('/api/v1', '')}$photoPath';
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: AppColors.surfaceContainerLow,
          child: const Icon(Icons.person, size: 56, color: AppColors.outlineVariant),
        ),
      );
    }

    // Local file path (e.g. just picked from gallery)
    return Image.file(
      File(photoPath),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: AppColors.surfaceContainerLow,
        child: const Icon(Icons.person, size: 56, color: AppColors.outlineVariant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final eventsProvider = Provider.of<EventsProvider>(context);
    final user = authProvider.user;
    final stats = user?.stats;

    debugPrint('Debug Profile - stats.totalEventsHosted: ${stats?.totalEventsHosted}');
    debugPrint('Debug Profile - eventsProvider.hostedEvents.length: ${eventsProvider.hostedEvents.length}');

    return Scaffold(
      backgroundColor: AppColors.background,
      // We don't use bottomNavigationBar here because HomeScreen provides it globally.
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Provider.of<AuthProvider>(context, listen: false).fetchProfile();
            if (context.mounted) {
              await Provider.of<EventsProvider>(context, listen: false).fetchHostedEvents();
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              120,
            ), // Increased bottom padding for global nav
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile Header ───────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    // Avatar + verified badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 128,
                          height: 128,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF191C1B,
                                ).withValues(alpha: 0.08),
                                blurRadius: 40,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _buildProfileImage(user?.photoUrl ?? widget.fotoPath),
                          ),
                        ),
                      ],
                    ),

                    // Nama
                    Text(
                      user?.name ?? widget.nama,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),

                    // Lokasi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user?.address?.city ?? widget.alamat,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Stats ────────────────────────────────────────────────────
              Row(
                children: [
                  // Total Buwoh
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(
                            alpha: 0.15,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF191C1B,
                            ).withValues(alpha: 0.04),
                            blurRadius: 40,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.tertiary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.card_giftcard,
                              color: AppColors.tertiary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          authProvider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Buwoh',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      '${stats?.totalBuwoh ?? 0}',
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Total Acara
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF191C1B,
                            ).withValues(alpha: 0.04),
                            blurRadius: 40,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.event_available,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          authProvider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Acara',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.onSecondaryContainer,
                                      ),
                                    ),
                                    Text(
                                      '${stats?.totalEventsHosted ?? 0}',
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Action List ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 16),
                child: Text(
                  'MENU LAINNYA',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    letterSpacing: 2.0,
                  ),
                ),
              ),

              // Dashboard (highlighted)
              BuwohActionItem(
                icon: Icons.dashboard_outlined,
                label: 'Dashboard',
                isHighlighted: true,
                showArrow: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardScreen(
                        nama: user?.name ?? widget.nama,
                        fotoPath: user?.photoUrl ?? widget.fotoPath,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              // Detail & Sunting Profil
              BuwohActionItem(
                icon: Icons.person_outline,
                label: 'Detail Profil',
                isHighlighted: false,
                showArrow: true,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(
                        initialName: user?.name ?? widget.nama,
                        initialAddress: user?.address?.city ?? widget.alamat,
                        initialPhotoPath: user?.photoUrl ?? widget.fotoPath,
                        startInEditMode: false,
                      ),
                    ),
                  );

                  if (result != null && result is Map<String, dynamic>) {
                    if (widget.onProfileUpdated != null) {
                      widget.onProfileUpdated!(result);
                    }
                  }
                },
              ),

              const SizedBox(height: 24),

              // Logout
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Apakah Anda yakin ingin keluar?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            Provider.of<AuthProvider>(context, listen: false).logout();
                            Navigator.pop(context);
                          },
                          child: const Text('Logout', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Logout',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Footer text
              Center(
                child: Text(
                  'Buwoh v2.4.0 • Built with Heritage',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
