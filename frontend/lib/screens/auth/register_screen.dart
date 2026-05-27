import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../dashboard/home_screen.dart';
import '../../widgets/widgets.dart';
import '../../utils/buwoh_dialogs.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Color Tokens
  static const _primary = Color(0xFF134231);
  static const _primaryContainer = Color(0xFF2D5A47);
  static const _primaryFixed = Color(0xFFBCEDD4);
  static const _secondaryFixed = Color(0xFFC5EBD9);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _background = Color(0xFFF8FAF8);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(BuildContext context, AuthProvider auth) async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      BuwohDialogs.showWarning(context, 'Harap isi semua bidang');
      return;
    }

    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      BuwohDialogs.showWarning(context, 'Kata sandi tidak cocok');
      return;
    }

    final success = await auth.register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      _confirmPasswordCtrl.text,
    );

    if (!mounted) return;

    // Navigation handled by AuthWrapper in main.dart
    // But if we were pushed as a route, we should pop to return to the root
    if (success) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      return;
    }

    BuwohDialogs.showError(
      context,
      'Pendaftaran gagal. Silakan coba lagi.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return Stack(
        children: [
          Positioned(
            top: -96,
            left: -96,
            child: BuwohGlowBlob(color: _primaryFixed.withValues(alpha: 0.065)),
          ),
          Positioned(
            bottom: -96,
            right: -96,
            child: BuwohGlowBlob(
              color: _secondaryFixed.withValues(alpha: 0.065),
            ),
          ),

          // Main content
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 48,
                      ),
                      child: Column(
                        children: [
                          // ── Header ──────────────────────────────────────────────
                          Column(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: _primaryContainer,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _primary.withValues(alpha: 0.20),
                                      blurRadius: 32,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.volunteer_activism,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Buwoh App',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: _primary,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Daftar Sekarang Juga',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 48),

                          // ── Form Card ───────────────────────────────────────────
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: _surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(24),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                    // Name field
                                    const BuwohFieldLabel('Nama Lengkap'),
                                    const SizedBox(height: 8),
                                    BuwohInputField(
                                      controller: _nameCtrl,
                                      hintText: 'Nama Lengkap Anda',
                                      prefixIcon: Icons.person_outline,
                                    ),

                                    const SizedBox(height: 24),

                                    // Email field
                                    const BuwohFieldLabel('Email'),
                                    const SizedBox(height: 8),
                                    BuwohInputField(
                                      controller: _emailCtrl,
                                      hintText: 'nama@email.com',
                                      prefixIcon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                    ),

                                const SizedBox(height: 24),

                                // Password field
                                const BuwohFieldLabel('Kata Sandi'),
                                const SizedBox(height: 8),
                                BuwohPasswordField(
                                  controller: _passwordCtrl,
                                  obscure: _obscurePassword,
                                  onToggle: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Confirm Password field
                                const BuwohFieldLabel('Konfirmasi Kata Sandi'),
                                const SizedBox(height: 8),
                                BuwohPasswordField(
                                  controller: _confirmPasswordCtrl,
                                  obscure: _obscureConfirmPassword,
                                  onToggle: () => setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Register button
                                BuwohPrimaryButton(
                                  label: auth.isLoading ? 'Memproses...' : 'Daftar',
                                  onPressed: auth.isLoading 
                                    ? null 
                                    : () => _handleRegister(context, auth),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // ── Footer ──────────────────────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Sudah punya akun?',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  ),
);
  }
}
