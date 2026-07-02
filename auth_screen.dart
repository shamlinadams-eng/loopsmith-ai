import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/theme.dart';
import '../widgets/auth/auth_social_button.dart';
import '../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogle(BuildContext context) async {
    final auth = context.read<AuthService>();
    final ok = await auth.signInWithGoogle();
    if (ok && context.mounted) context.go('/generate');
  }

  Future<void> _handleApple(BuildContext context) async {
    final auth = context.read<AuthService>();
    final ok = await auth.signInWithApple();
    if (ok && context.mounted) context.go('/generate');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;
    final auth = context.watch<AuthService>();

    return Scaffold(
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.neonAccent.withOpacity(0.1),
                    colors.neonAccent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.neonSecondary.withOpacity(0.08),
                    colors.neonSecondary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTheme.spacingXl),

                  // Logo + wordmark
                  Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.neonAccent.withOpacity(0.12),
                          border: Border.all(
                            color: colors.neonAccent.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.neonAccent.withOpacity(AppTheme.opacityGlow),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.graphic_eq,
                          size: 36,
                          color: colors.neonAccent,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Text(
                        'LoopSmith AI',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        'Your AI-powered beat laboratory',
                        style: textTheme.bodyMedium?.copyWith(color: colors.subtleText),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingXl),

                  // Error banner
                  if (auth.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.error.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: AppTheme.iconSm,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: AppTheme.spacingSm),
                          Expanded(
                            child: Text(
                              auth.error!,
                              style: textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                  ],

                  // Social sign-in
                  AuthSocialButton(
                    label: 'Continue with Google',
                    icon: Icons.g_mobiledata,
                    onPressed: auth.isLoading ? null : () => _handleGoogle(context),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  AuthSocialButton(
                    label: 'Continue with Apple',
                    icon: Icons.apple,
                    onPressed: auth.isLoading ? null : () => _handleApple(context),
                  ),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: colors.glassBorder)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                        child: Text(
                          'or continue with email',
                          style: textTheme.labelSmall?.copyWith(color: colors.subtleText),
                        ),
                      ),
                      Expanded(child: Divider(color: colors.glassBorder)),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Sign-in / Sign-up tabs
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.glassBg,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(color: colors.glassBorder),
                        ),
                        child: Column(
                          children: [
                            TabBar(
                              controller: _tabController,
                              indicatorColor: colors.neonAccent,
                              labelColor: colors.neonAccent,
                              unselectedLabelColor: colors.subtleText,
                              dividerColor: colors.glassBorder,
                              tabs: const [
                                Tab(text: 'Sign In'),
                                Tab(text: 'Create Account'),
                              ],
                            ),
                            SizedBox(
                              height: 340,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  AuthForm(
                                    mode: AuthFormMode.signIn,
                                    onSuccess: () => context.go('/generate'),
                                  ),
                                  AuthForm(
                                    mode: AuthFormMode.signUp,
                                    onSuccess: () => context.go('/generate'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Skip for now
                  TextButton(
                    onPressed: () => context.go('/generate'),
                    child: Text(
                      'Continue without an account',
                      style: textTheme.labelMedium?.copyWith(color: colors.subtleText),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingMd),

                  // Terms
                  Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy.',
                    style: textTheme.labelSmall?.copyWith(color: colors.subtleText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
