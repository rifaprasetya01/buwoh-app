import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'register_screen.dart';
import '../dashboard/home_screen.dart';
import '../../widgets/widgets.dart';
import '../../providers/auth_provider.dart';
import '../../utils/buwoh_dialogs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  // Color Tokens
  static const _primary = Color(0xFF134231);
  static const _primaryContainer = Color(0xFF2D5A47);
  static const _primaryFixed = Color(0xFFBCEDD4);
  static const _secondaryFixed = Color(0xFFC5EBD9);
  static const _onSurfaceVariant = Color(0xFF414944);
  // static const _outlineVariant = Color(0xFFC0C8C2);
  // static const _outline = Color(0xFF717974);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _background = Color(0xFFF8FAF8);
  // static const _tertiary = Color(0xFF705D00);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context, AuthProvider auth) async {
    final success = await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
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
      'Login gagal. Periksa email dan kata sandi Anda.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
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
                                'Masuk ke Akun',
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

                                const SizedBox(height: 12),

                                // Forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Scaffold(
                                            backgroundColor: _background,
                                            appBar: AppBar(
                                              backgroundColor: _background,
                                              elevation: 0,
                                              scrolledUnderElevation: 0,
                                              leading: IconButton(
                                                icon: const Icon(
                                                  Icons.arrow_back,
                                                  color: _primary,
                                                ),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                              title: const Text(
                                                'Lupa Kata Sandi',
                                                style: TextStyle(
                                                  fontFamily: 'Plus Jakarta Sans',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: _primary,
                                                ),
                                              ),
                                            ),
                                            body: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.lock_reset_outlined,
                                                    size: 64,
                                                    color: _onSurfaceVariant.withValues(alpha: 0.5),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  const Text(
                                                    'Fitur Segera Hadir!',
                                                    style: TextStyle(
                                                      fontFamily: 'Plus Jakarta Sans',
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w700,
                                                      color: _primary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    'Kami sedang menyiapkan sesuatu yang luar biasa.',
                                                    style: TextStyle(
                                                      fontFamily: 'Plus Jakarta Sans',
                                                      fontSize: 13,
                                                      color: _onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Lupa Kata Sandi?',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _primary,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Login button
                                Consumer<AuthProvider>(
                                  builder: (context, auth, _) {
                                    return BuwohPrimaryButton(
                                      label: auth.isLoading ? 'Memuat...' : 'Masuk',
                                      onPressed: auth.isLoading 
                                        ? null 
                                        : () => _handleLogin(context, auth),
                                    );
                                  },
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
                                'Belum punya akun?',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
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
                                  'Daftar',
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
      ),
    );
  }
}

// ── Reusable Widgets ────────────────────────────────────────────────────────


