import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'dashboard_screen.dart';

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

  static const _primary = Color(0xFF134231);
  static const _primaryContainer = Color(0xFF2D5A47);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _outlineVariant = Color(0xFFC0C8C2);
  static const _surfaceContainerLow = Color(0xFFF2F4F2);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _secondaryContainer = Color(0xFFC2E8D6);
  static const _onSecondaryContainer = Color(0xFF476A5B);
  static const _tertiary = Color(0xFF705D00);
  static const _errorContainer = Color(0xFFFFDAD6);
  static const _error = Color(0xFFBA1A1A);
  static const _background = Color(0xFFF8FAF8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background.withValues(alpha: 0.82),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: _secondaryContainer,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
            ),
            const SizedBox(width: 10),
            const Text(
              'Buwoh',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _primary,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: _primary),
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
                                  errorBuilder: (_, __, ___) => Container(
                                    color: _surfaceContainerLow,
                                    child: const Icon(
                                      Icons.person,
                                      size: 56,
                                      color: _outlineVariant,
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
                      color: _primary,
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
                        color: _onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        alamat,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: _onSurfaceVariant.withValues(alpha: 0.8),
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
                      color: _surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _outlineVariant.withValues(alpha: 0.15),
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
                          color: _tertiary,
                          size: 26,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '15',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: _primary,
                          ),
                        ),
                        const Text(
                          'Total Buwoh',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _onSurfaceVariant,
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
                      color: _secondaryContainer,
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
                        Icon(Icons.event_available, color: _primary, size: 26),
                        SizedBox(height: 10),
                        Text(
                          '3',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: _primary,
                          ),
                        ),
                        Text(
                          'Total Acara',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _onSecondaryContainer,
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
                  color: _onSurfaceVariant.withValues(alpha: 0.6),
                  letterSpacing: 2.0,
                ),
              ),
            ),

            // Dashboard (highlighted)
            _ActionButton(
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
            _ActionButton(
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
                  color: _errorContainer.withValues(alpha: 0.3),
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
                      child: const Icon(Icons.logout, color: _error, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Logout',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _error,
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
                  color: _onSurfaceVariant.withValues(alpha: 0.4),
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

// ── Action Button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isHighlighted;
  final bool showArrow;
  final VoidCallback onTap;

  static const _primary = Color(0xFF134231);
  static const _primaryContainer = Color(0xFF2D5A47);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _surfaceContainerLow = Color(0xFFF2F4F2);

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isHighlighted,
    required this.showArrow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isHighlighted ? _primaryContainer : _surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: _primaryContainer.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isHighlighted
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white,
                boxShadow: isHighlighted
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 4,
                        ),
                      ],
              ),
              child: Icon(
                icon,
                color: isHighlighted ? Colors.white : _primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
                  color: isHighlighted ? Colors.white : _onSurface,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right,
                color: isHighlighted ? Colors.white : _onSurfaceVariant,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
