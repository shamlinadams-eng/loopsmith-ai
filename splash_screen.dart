import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _logoController.forward();

    // Navigate after animation
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      final auth = context.read<AuthService>();
      if (auth.isSignedIn) {
        context.go('/generate');
      } else {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Ambient background glow
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (context, _) => Center(
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.neonAccent.withOpacity(0.08 * _glowAnim.value),
                      colors.neonSecondary.withOpacity(0.04 * _glowAnim.value),
                      colors.neonAccent.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Logo + wordmark
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _glowAnim,
                      builder: (context, _) => Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.neonAccent.withOpacity(0.12),
                          border: Border.all(
                            color: colors.neonAccent.withOpacity(0.35),
                            width: AppTheme.borderDefault,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.neonAccent
                                  .withOpacity(AppTheme.opacityGlow * _glowAnim.value),
                              blurRadius: 48,
                              spreadRadius: 8,
                            ),
                            BoxShadow(
                              color: colors.neonSecondary
                                  .withOpacity(0.15 * _glowAnim.value),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.graphic_eq,
                          size: 52,
                          color: colors.neonAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    Text(
                      'LoopSmith AI',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      'AI-Powered Loop Generation',
                      style: textTheme.bodyMedium?.copyWith(color: colors.subtleText),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom tagline
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'Loading your studio...',
                    style: textTheme.labelSmall?.copyWith(color: colors.subtleText),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
