import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const BuwohApp());
}

class BuwohApp extends StatelessWidget {
  const BuwohApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buwoh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Plus Jakarta Sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF134231),
        ),
        useMaterial3: true,
      ),
      home: const _SplashWrapper(),
    );
  }
}

/// Wrapper yang menangani navigasi dari Splash → Login
class _SplashWrapper extends StatelessWidget {
  const _SplashWrapper();

  @override
  Widget build(BuildContext context) {
    return BuwohSplashScreen(
      onFinish: () {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
    );
  }
}
