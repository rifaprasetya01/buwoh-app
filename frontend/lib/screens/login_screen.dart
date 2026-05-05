import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'home_screen.dart';

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
  static const _outlineVariant = Color(0xFFC0C8C2);
  static const _outline = Color(0xFF717974);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _background = Color(0xFFF8FAF8);
  static const _tertiary = Color(0xFF705D00);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -96,
            left: -96,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primaryFixed.withValues(alpha: 0.20),
              ),
            ),
          ),
          Positioned(
            bottom: -96,
            right: -96,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _secondaryFixed.withValues(alpha: 0.20),
              ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
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
                                  fontSize: 15,
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
                                  color: const Color(0xFF191C1B).withValues(alpha: 0.04),
                                  blurRadius: 40,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email field
                                const _FieldLabel('Alamat Email'),
                                const SizedBox(height: 8),
                                _InputField(
                                  controller: _emailCtrl,
                                  hintText: 'nama@email.com',
                                  prefixIcon: Icons.mail_outline,
                                  keyboardType: TextInputType.emailAddress,
                                ),

                                const SizedBox(height: 24),

                                // Password field
                                const _FieldLabel('Kata Sandi'),
                                const SizedBox(height: 8),
                                _PasswordField(
                                  controller: _passwordCtrl,
                                  obscure: _obscurePassword,
                                  onToggle: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                                ),

                                const SizedBox(height: 12),

                                // Forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                                _PrimaryButton(
                                  label: 'Masuk Sekarang',
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const HomeScreen(),
                                      ),
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
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF414944),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 15,
        color: Color(0xFF191C1B),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          color: Color(0xFF717974),
          fontSize: 15,
        ),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF414944), size: 22),
        filled: true,
        fillColor: const Color(0xFFF2F4F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(
            color: Color(0xFF2D5A47),
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 15,
        color: Color(0xFF191C1B),
      ),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          color: Color(0xFF717974),
          fontSize: 15,
        ),
        prefixIcon:
            const Icon(Icons.lock_outline, color: Color(0xFF414944), size: 22),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: const Color(0xFF414944),
            size: 22,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFFF2F4F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(
            color: Color(0xFF2D5A47),
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D5A47),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF134231).withValues(alpha: 0.3),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
