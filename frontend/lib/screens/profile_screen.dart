import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'dashboard_screen.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
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
  // ── Color Tokens ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withValues(alpha: 0.82),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.secondaryContainer,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
            ),
            const SizedBox(width: 10),
            const Text(
              'Buwoh',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      // We don't use bottomNavigationBar here because HomeScreen provides it globally.
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          8,
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
                              color: const Color(0xFF191C1B).withValues(alpha: 0.08),
                              blurRadius: 40,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: fotoPath != null
                              ? (kIsWeb
                                  ? Image.network(
                                      fotoPath!,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(fotoPath!),
                                      fit: BoxFit.cover,
                                    ))
                              : Image.network(
                                  'https://i.pravatar.cc/150?img=56',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    color: AppColors.surfaceContainerLow,
                                    child: const Icon(
                                      Icons.person,
                                      size: 56,
                                      color: AppColors.outlineVariant,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Nama
                  Text(
                    nama,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Lokasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        alamat,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
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
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.15),
                      ),
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
                        const Icon(
                          Icons.card_giftcard,
                          color: AppColors.tertiary,
                          size: 26,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '15',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const Text(
                          'Total Buwoh',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Total Acara
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF191C1B).withValues(alpha: 0.04),
                          blurRadius: 40,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.event_available, color: AppColors.primary, size: 26),
                        SizedBox(height: 10),
                        Text(
                          '3',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Total Acara',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSecondaryContainer,
                          ),
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
                'PENGATURAN AKUN',
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
                    builder: (_) =>
                        DashboardScreen(nama: nama, fotoPath: fotoPath),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // Edit Profil
            BuwohActionItem(
              icon: Icons.person_outline,
              label: 'Edit Profil',
              isHighlighted: false,
              showArrow: true,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(
                      initialName: nama,
                      initialAddress: alamat,
                      initialPhotoPath: fotoPath,
                    ),
                  ),
                );

                if (result != null && result is Map<String, dynamic>) {
                  if (onProfileUpdated != null) {
                    onProfileUpdated!(result);
                  }
                }
              },
            ),

            const SizedBox(height: 24),

            // Logout
            GestureDetector(
              onTap: () {},
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
                      child: const Icon(Icons.logout, color: AppColors.error, size: 20),
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
    );
  }
}
