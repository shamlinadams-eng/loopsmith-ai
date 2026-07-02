import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../theme/theme.dart';
import '../widgets/common/glass_card.dart';

/// Stripe subscription paywall screen.
///
/// HOW STRIPE WORKS WITH THIS SCREEN:
/// 1. Your backend creates a Stripe Checkout Session for the signed-in user
///    and returns a session URL (e.g. https://checkout.stripe.com/pay/cs_live_...)
/// 2. This screen opens that URL via url_launcher — the user completes payment
///    in their browser or Stripe's in-app sheet.
/// 3. Stripe fires a webhook to your backend (e.g. /webhooks/stripe).
/// 4. Your backend calls Firestore to set users/{uid}.isPremium = true.
/// 5. AuthService's Firestore listener picks up the change and the UI updates
///    automatically — no action needed on the Flutter side.
///
/// To connect Stripe: replace [_stripeCheckoutUrl] below with a call to your
/// backend that returns a real Checkout Session URL for the current user.
class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({super.key});

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  bool _isLaunching = false;

  // ── Stripe configuration ───────────────────────────────────────────────────
  // Replace this with a real call to your backend that creates a Stripe
  // Checkout Session and returns the session URL for the signed-in user.
  // Example backend endpoint: POST /api/create-checkout-session { uid: user.uid }
  // The backend responds with { url: "https://checkout.stripe.com/pay/cs_live_..." }
  static const String _stripeCheckoutUrl =
      'https://buy.stripe.com/YOUR_PAYMENT_LINK_HERE';

  // Your Stripe monthly price (display only — Stripe controls the real amount).
  static const String _monthlyPrice = '\$9.99';
  static const String _annualPrice = '\$79.99';
  static const String _annualMonthly = '\$6.67';

  bool _isAnnual = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _launchCheckout() async {
    final auth = context.read<AuthService>();
    if (!auth.isSignedIn) {
      context.push('/auth');
      return;
    }

    // TODO: Replace this with a real backend call:
    // final response = await http.post(
    //   Uri.parse('https://YOUR_BACKEND/api/create-checkout-session'),
    //   body: json.encode({'uid': auth.currentUser!.uid, 'annual': _isAnnual}),
    //   headers: {'Content-Type': 'application/json'},
    // );
    // final sessionUrl = json.decode(response.body)['url'];
    // final uri = Uri.parse(sessionUrl);

    final uri = Uri.parse(_stripeCheckoutUrl);
    setState(() => _isLaunching = true);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          _showError('Could not open the payment page. Please try again.');
        }
      }
    } catch (_) {
      if (mounted) {
        _showError('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLaunching = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;
    final auth = context.watch<AuthService>();

    // If user is already premium, show a confirmation view.
    if (auth.currentUser?.isPremium == true) {
      return _AlreadyPremiumView(onClose: () => context.pop());
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Go Premium'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingMd,
          AppTheme.spacingSm,
          AppTheme.spacingMd,
          AppTheme.spacingXxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero ────────────────────────────────────────────────────────
            _HeroSection(glowAnim: _glowAnim),
            const SizedBox(height: AppTheme.spacingLg),

            // ── Plan toggle ─────────────────────────────────────────────────
            _PlanToggle(
              isAnnual: _isAnnual,
              onChanged: (v) => setState(() => _isAnnual = v),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // ── Price card ──────────────────────────────────────────────────
            _PriceCard(
              isAnnual: _isAnnual,
              monthlyPrice: _monthlyPrice,
              annualPrice: _annualPrice,
              annualMonthly: _annualMonthly,
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // ── Feature comparison ──────────────────────────────────────────
            _FeatureComparison(),
            const SizedBox(height: AppTheme.spacingLg),

            // ── Testimonials ────────────────────────────────────────────────
            _Testimonials(),
            const SizedBox(height: AppTheme.spacingLg),

            // ── CTA button ──────────────────────────────────────────────────
            AnimatedBuilder(
              animation: _glowAnim,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: colors.neonSecondary
                            .withOpacity(0.35 * _glowAnim.value),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: ElevatedButton(
                onPressed: _isLaunching ? null : _launchCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.neonSecondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, AppTheme.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: _isLaunching
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _isAnnual
                            ? 'Start Annual Plan — $_annualPrice/yr'
                            : 'Start Monthly Plan — $_monthlyPrice/mo',
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // ── Legal notice ─────────────────────────────────────────────────
            Text(
              'Cancel anytime. Payment processed securely by Stripe. '
              'By subscribing you agree to our Terms of Service and Privacy Policy.',
              style: textTheme.bodySmall?.copyWith(color: colors.subtleText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero section
// ---------------------------------------------------------------------------
class _HeroSection extends StatelessWidget {
  final Animation<double> glowAnim;

  const _HeroSection({required this.glowAnim});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        AnimatedBuilder(
          animation: glowAnim,
          builder: (context, child) {
            return Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [colors.neonSecondary, colors.neonAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.neonSecondary.withOpacity(0.5 * glowAnim.value),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: AppTheme.iconLg,
              ),
            );
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          'Unlock Your Full\nCreative Potential',
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Generate unlimited royalty-free loops with advanced AI,\nhigh-quality exports, and stem files.',
          style: textTheme.bodyMedium?.copyWith(color: colors.subtleText),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Monthly / Annual toggle
// ---------------------------------------------------------------------------
class _PlanToggle extends StatelessWidget {
  final bool isAnnual;
  final ValueChanged<bool> onChanged;

  const _PlanToggle({required this.isAnnual, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingXs),
      child: Row(
        children: [
          _ToggleTab(
            label: 'Monthly',
            selected: !isAnnual,
            onTap: () => onChanged(false),
          ),
          _ToggleTab(
            label: 'Annual',
            selected: isAnnual,
            onTap: () => onChanged(true),
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colors.neonTertiary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                border: Border.all(color: colors.neonTertiary.withOpacity(0.4)),
              ),
              child: Text(
                'Save 33%',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.neonTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? badge;

  const _ToggleTab({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingSm,
            horizontal: AppTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: selected ? colors.neonSecondary.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: selected ? colors.neonSecondary.withOpacity(0.5) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: selected ? colors.neonSecondary : colors.subtleText,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: AppTheme.spacingXs),
                badge!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Price card
// ---------------------------------------------------------------------------
class _PriceCard extends StatelessWidget {
  final bool isAnnual;
  final String monthlyPrice;
  final String annualPrice;
  final String annualMonthly;

  const _PriceCard({
    required this.isAnnual,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.annualMonthly,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.neonSecondary.withOpacity(0.12),
                colors.neonAccent.withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: colors.neonSecondary.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LoopSmith AI Premium', style: textTheme.titleMedium),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      isAnnual
                          ? 'Billed annually as $annualPrice/yr'
                          : 'Billed monthly',
                      style: textTheme.bodySmall?.copyWith(color: colors.subtleText),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isAnnual ? annualMonthly : monthlyPrice,
                    style: textTheme.headlineMedium?.copyWith(
                      color: colors.neonSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '/mo',
                    style: textTheme.bodySmall?.copyWith(color: colors.subtleText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feature comparison table
// ---------------------------------------------------------------------------
class _FeatureComparison extends StatelessWidget {
  static const _features = [
    _FeatureRow('Loop generations / day', '10', 'Unlimited'),
    _FeatureRow('Audio quality', 'Standard', '24-bit WAV'),
    _FeatureRow('Stem export', false, true),
    _FeatureRow('MIDI export', false, true),
    _FeatureRow('Advanced AI models', false, true),
    _FeatureRow('Commercial license', false, true),
    _FeatureRow('Priority queue', false, true),
    _FeatureRow('Exclusive instrument packs', false, true),
    _FeatureRow('FL / Ableton / Logic export', false, true),
    _FeatureRow('Cloud sync & backup', 'Basic', 'Full'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingMd,
            ),
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                SizedBox(
                  width: 72,
                  child: Text(
                    'Free',
                    style: textTheme.labelMedium?.copyWith(color: colors.subtleText),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Premium',
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.neonSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.glassBorder),
          ..._features.asMap().entries.map((entry) {
            final i = entry.key;
            final f = entry.value;
            return Column(
              children: [
                _FeatureRowTile(feature: f),
                if (i < _features.length - 1)
                  Divider(height: 1, color: colors.glassBorder),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _FeatureRow {
  final String label;
  final Object freeValue; // String or bool
  final Object premiumValue; // String or bool

  const _FeatureRow(this.label, this.freeValue, this.premiumValue);
}

class _FeatureRowTile extends StatelessWidget {
  final _FeatureRow feature;

  const _FeatureRowTile({required this.feature});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(feature.label, style: textTheme.bodySmall),
          ),
          SizedBox(width: 72, child: _valueWidget(feature.freeValue, colors, textTheme, false)),
          SizedBox(width: 80, child: _valueWidget(feature.premiumValue, colors, textTheme, true)),
        ],
      ),
    );
  }

  Widget _valueWidget(
    Object value,
    AppColorsExtension colors,
    TextTheme textTheme,
    bool isPremium,
  ) {
    if (value is bool) {
      return Center(
        child: Icon(
          value ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: AppTheme.iconSm,
          color: value
              ? (isPremium ? colors.neonTertiary : colors.subtleText)
              : colors.subtleText.withOpacity(0.4),
        ),
      );
    }
    return Center(
      child: Text(
        value as String,
        style: textTheme.labelSmall?.copyWith(
          color: isPremium ? colors.neonSecondary : colors.subtleText,
          fontWeight: isPremium ? FontWeight.w600 : FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Social proof / testimonials
// ---------------------------------------------------------------------------
class _Testimonials extends StatelessWidget {
  static const _reviews = [
    (
      name: 'Memphis Mike',
      text: 'This app replaced half my sample library. The dark vibes it generates are insane.',
      stars: 5,
    ),
    (
      name: 'BeatsByJordan',
      text: 'Stem export alone is worth the price. Dropped it straight into FL Studio.',
      stars: 5,
    ),
    (
      name: 'LoFiLuna',
      text: 'Finally an AI that understands jazz chords and vintage soul. Incredible.',
      stars: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).extension<AppColorsExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What producers are saying', style: textTheme.titleMedium),
        const SizedBox(height: AppTheme.spacingMd),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _reviews.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacingSm),
            itemBuilder: (context, i) {
              final r = _reviews[i];
              return SizedBox(
                width: 220,
                child: GlassCard(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          r.stars,
                          (_) => Icon(Icons.star_rounded,
                              size: 14, color: colors.warning),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Expanded(
                        child: Text(
                          '"${r.text}"',
                          style: textTheme.bodySmall,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        '— ${r.name}',
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.subtleText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Already premium view
// ---------------------------------------------------------------------------
class _AlreadyPremiumView extends StatelessWidget {
  final VoidCallback onClose;

  const _AlreadyPremiumView({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: onClose),
        title: const Text('Premium'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [colors.neonSecondary, colors.neonAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: AppTheme.iconLg,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text('You\'re already Premium! 🎉', style: textTheme.headlineSmall),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'Enjoy unlimited loop generations, stem exports, and all advanced features.',
                style: textTheme.bodyMedium?.copyWith(color: colors.subtleText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingXl),
              ElevatedButton(
                onPressed: onClose,
                child: const Text('Back to LoopSmith AI'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
