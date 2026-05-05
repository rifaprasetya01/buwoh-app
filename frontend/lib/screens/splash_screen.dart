import 'package:flutter/material.dart';
import '../widgets/widgets.dart';


/// Buwoh - Splash Screen
class BuwohSplashScreen extends StatefulWidget {
  final VoidCallback? onFinish;
  const BuwohSplashScreen({super.key, this.onFinish});

  @override
  State<BuwohSplashScreen> createState() => _BuwohSplashScreenState();
}

class _BuwohSplashScreenState extends State<BuwohSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _titleCtrl;
  late final AnimationController _subtitleCtrl;
  late final AnimationController _bottomCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _subtitleOpacity;
  // late final Animation<Offset> _bottomSlide;
  // late final Animation<double> _bottomOpacity;

  static const _primary = Color(0xFF134231);
  static const _primaryContainer = Color(0xFF2D5A47);
  static const _onSurfaceVariant = Color(0xFF414944);
  // static const _outlineVariant = Color(0xFFC0C8C2);
  static const _tertiary = Color(0xFF705D00);
  static const _background = Color(0xFFF8FAF8);

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoScale = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut);
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _titleSlide = Tween(begin: const Offset(-0.3, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut));
    _titleOpacity = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut));

    _subtitleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _subtitleSlide = Tween(begin: const Offset(0.3, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _subtitleCtrl, curve: Curves.easeOut));
    _subtitleOpacity = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _subtitleCtrl, curve: Curves.easeOut));

    _bottomCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    // _bottomSlide = Tween(begin: const Offset(0.3, 0), end: Offset.zero)
    //     .animate(CurvedAnimation(parent: _bottomCtrl, curve: Curves.easeOut));
    // _bottomOpacity = Tween(begin: 0.0, end: 1.0).animate(
    //     CurvedAnimation(parent: _bottomCtrl, curve: Curves.easeOut));

    _runSequence();
  }

  Future<void> _runSequence() async {
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _titleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _subtitleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _bottomCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    widget.onFinish?.call();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _bottomCtrl.dispose();
    super.dispose();
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
            child: BuwohGlowBlob(color: _primaryContainer.withValues(alpha: 0.065)),
          ),
          Positioned(
            bottom: -96,
            right: -96,
            child: BuwohGlowBlob(color: _tertiary.withValues(alpha: 0.065)),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: _primaryContainer,
                        borderRadius: BorderRadius.circular(100),
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
                  ),
                ),
                const SizedBox(height: 32),
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleOpacity,
                    child: const Text(
                      'Buwoh',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: _primary,
                        letterSpacing: -1.5,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SlideTransition(
                  position: _subtitleSlide,
                  child: FadeTransition(
                    opacity: _subtitleOpacity,
                    child: const Text(
                      'DIGITALISASI TRADISI HAJATAN',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _onSurfaceVariant,
                        letterSpacing: 2.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


