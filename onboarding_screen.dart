import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.auto_awesome,
      title: 'Generate Loops\nWith AI',
      subtitle:
          'Describe any sound in plain language. Trap, Jazz, Lo-Fi, Phonk — LoopSmith AI turns words into professional, royalty-free loops instantly.',
      accentIndex: 0,
    ),
    _OnboardingPage(
      icon: Icons.tune,
      title: 'Full Creative\nControl',
      subtitle:
          'Fine-tune every detail — BPM, key, scale, complexity, swing, and more. Smart controls like Mutate, Simplify, and Make Darker let you shape the vibe in one tap.',
      accentIndex: 1,
    ),
    _OnboardingPage(
      icon: Icons.library_music,
      title: 'Your Loop\nLibrary, Built-In',
      subtitle:
          'Every loop saved, organized, and playable instantly. Export as WAV, MP3, MIDI, or full stems for FL Studio, Ableton, and Logic.',
      accentIndex: 2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/auth');
    }
  }

  void _skip() => context.go('/auth');

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    final accents = [colors.neonAccent, colors.neonSecondary, colors.neonTertiary];
    final currentAccent = accents[_currentPage];

    return Scaffold(
      body: Stack(
        children: [
          // Animated background glow
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, _) => Positioned(
              top: -120,
              left: -80,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      currentAccent.withOpacity(0.12 * _glowAnimation.value),
                      currentAccent.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    child: TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Skip',
                        style: textTheme.labelLarge?.copyWith(
                          color: colors.subtleText,
                        ),
                      ),
                    ),
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      final accent = accents[page.accentIndex];
                      return _PageContent(
                        page: page,
                        accent: accent,
                        glowAnimation: _glowAnimation,
                      );
                    },
                  ),
                ),

                // Indicators + button
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spacingXl,
                    AppTheme.spacingMd,
                    AppTheme.spacingXl,
                    AppTheme.spacingXl,
                  ),
                  child: Column(
                    children: [
                      // Dot indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (i) {
                          final isActive = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingXs,
                            ),
                            width: isActive ? 24.0 : 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                              color: isActive ? currentAccent : colors.glassBorder,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),

                      // CTA button
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, _) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            boxShadow: [
                              BoxShadow(
                                color: currentAccent
                                    .withOpacity(AppTheme.opacityGlow * _glowAnimation.value),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentAccent,
                              foregroundColor: const Color(0xFF0A0A0F),
                              minimumSize: const Size(double.infinity, AppTheme.buttonHeight),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              ),
                            ),
                            child: Text(
                              _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0A0A0F),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;
  final Color accent;
  final Animation<double> glowAnimation;

  const _PageContent({
    required this.page,
    required this.accent,
    required this.glowAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).extension<AppColorsExtension>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon orb
          AnimatedBuilder(
            animation: glowAnimation,
            builder: (context, _) => Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.12),
                border: Border.all(color: accent.withOpacity(0.3), width: AppTheme.borderDefault),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.3 * glowAnimation.value),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Icon(page.icon, size: 52, color: accent),
            ),
          ),
          const SizedBox(height: AppTheme.spacingXl),
          Text(
            page.title,
            style: textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            page.subtitle,
            style: textTheme.bodyLarge?.copyWith(color: colors.subtleText, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final int accentIndex;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentIndex,
  });
}
