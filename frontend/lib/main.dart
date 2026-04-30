import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const BuwohApp(),
    ),
  );
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

/// Wrapper yang menangani navigasi dari Splash → Login atau Home (auto-login)
class _SplashWrapper extends StatelessWidget {
  const _SplashWrapper();

  @override
  Widget build(BuildContext context) {
    return BuwohSplashScreen(
      onFinish: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        // Try auto-login with saved token
        final isLoggedIn = await authProvider.tryAutoLogin();

        if (!context.mounted) return;

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                isLoggedIn ? const HomeScreen() : const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
    );
  }
}
