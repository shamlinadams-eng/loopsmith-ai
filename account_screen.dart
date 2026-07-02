import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/replicate_service.dart';
import '../theme/theme.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/section_header.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (!auth.isSignedIn) {
      return _SignedOutView(onSignIn: () => context.push('/auth'));
    }

    return _SignedInView(user: auth.currentUser!);
  }
}

// ---------------------------------------------------------------------------
// Signed-out state
// ---------------------------------------------------------------------------
class _SignedOutView extends StatelessWidget {
  final VoidCallback onSignIn;

  const _SignedOutView({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
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
                  color: colors.glassBg,
                  border: Border.all(color: colors.glassBorder),
                ),
                child: Icon(Icons.person_outline, size: 48, color: colors.subtleText),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text('Sign in to LoopSmith AI', style: textTheme.titleLarge),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'Save your loops to the cloud, sync across devices, and unlock premium features.',
                style: textTheme.bodyMedium?.copyWith(color: colors.subtleText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingXl),
              ElevatedButton.icon(
                onPressed: onSignIn,
                icon: const Icon(Icons.login),
                label: const Text('Sign In or Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Signed-in state
// ---------------------------------------------------------------------------
class _SignedInView extends StatelessWidget {
  final UserModel user;

  const _SignedInView({required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;
    final auth = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => _confirmSignOut(context, auth),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
          // Profile header
          GlassCard(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [colors.neonAccent, colors.neonSecondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      user.initials,
                      style: textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF0A0A0F),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName, style: textTheme.titleMedium),
                      if (user.email != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          user.email!,
                          style: textTheme.bodySmall?.copyWith(color: colors.subtleText),
                        ),
                      ],
                      const SizedBox(height: AppTheme.spacingXs),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingSm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: user.isPremium
                                  ? colors.neonSecondary.withOpacity(0.15)
                                  : colors.glassBg,
                              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                              border: Border.all(
                                color: user.isPremium ? colors.neonSecondary : colors.glassBorder,
                              ),
                            ),
                            child: Text(
                              user.isPremium ? '★ Premium' : 'Free Tier',
                              style: textTheme.labelSmall?.copyWith(
                                color: user.isPremium ? colors.neonSecondary : colors.subtleText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingSm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingSm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.glassBg,
                              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                              border: Border.all(color: colors.glassBorder),
                            ),
                            child: Text(
                              'via ${user.providerLabel}',
                              style: textTheme.labelSmall?.copyWith(color: colors.subtleText),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          // Daily usage
          if (!user.isPremium) ...[
            SectionHeader(title: 'Today\'s Usage'),
            const SizedBox(height: AppTheme.spacingSm),
            GlassCard(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Loop Generations', style: textTheme.bodyMedium),
                      Text(
                        '${user.dailyGenerationsUsed} / ${UserModel.freeDailyLimit}',
                        style: textTheme.labelLarge?.copyWith(color: colors.neonAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                    child: LinearProgressIndicator(
                      value: user.dailyGenerationsUsed / UserModel.freeDailyLimit,
                      backgroundColor: colors.glassBg,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        user.remainingGenerations == 0
                            ? Theme.of(context).colorScheme.error
                            : colors.neonAccent,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    user.remainingGenerations == 0
                        ? 'Daily limit reached. Resets at midnight.'
                        : '${user.remainingGenerations} generations remaining today',
                    style: textTheme.bodySmall?.copyWith(color: colors.subtleText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
          ],

          // Premium upgrade
          if (!user.isPremium) ...[
            SectionHeader(title: 'Go Premium'),
            const SizedBox(height: AppTheme.spacingSm),
            _PremiumCard(),
            const SizedBox(height: AppTheme.spacingLg),
          ],

          // Plan details
          if (user.isPremium) ...[
            SectionHeader(title: 'Your Plan'),
            const SizedBox(height: AppTheme.spacingSm),
            GlassCard(
              glowColor: colors.neonSecondary,
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.workspace_premium, color: colors.neonSecondary, size: AppTheme.iconMd),
                      const SizedBox(width: AppTheme.spacingSm),
                      Text('LoopSmith AI Premium', style: textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  ..._premiumFeatures.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: colors.neonTertiary, size: AppTheme.iconSm),
                          const SizedBox(width: AppTheme.spacingSm),
                          Expanded(child: Text(f, style: textTheme.bodySmall)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
          ],

          // Connect AI
          SectionHeader(title: 'Connect AI'),
          const SizedBox(height: AppTheme.spacingSm),
          _ConnectAiCard(),
          const SizedBox(height: AppTheme.spacingLg),

          // Settings
          SectionHeader(title: 'Settings'),
          const SizedBox(height: AppTheme.spacingSm),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.cloud_sync_outlined,
                  label: 'Cloud Sync',
                  trailing: Switch(
                    value: true,
                    onChanged: (_) {},
                    activeColor: colors.neonAccent,
                  ),
                ),
                Divider(height: 1, color: colors.glassBorder),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  label: 'Push Notifications',
                  trailing: Switch(
                    value: true,
                    onChanged: (_) {},
                    activeColor: colors.neonAccent,
                  ),
                ),
                Divider(height: 1, color: colors.glassBorder),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => context.push('/privacy'),
                ),
                Divider(height: 1, color: colors.glassBorder),
                _SettingsTile(
                  icon: Icons.info_outline,
                  label: 'About LoopSmith AI',
                  trailing: Text(
                    'v1.0.0',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: colors.subtleText),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          // Sign out
          OutlinedButton.icon(
            onPressed: () => _confirmSignOut(context, auth),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error.withOpacity(0.4)),
            ),
          ),

          const SizedBox(height: AppTheme.spacingXxl),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthService auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              auth.signOut();
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Premium card
// ---------------------------------------------------------------------------
class _PremiumCard extends StatelessWidget {
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
                colors.neonSecondary.withOpacity(0.15),
                colors.neonAccent.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: colors.neonSecondary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.workspace_premium, color: colors.neonSecondary, size: AppTheme.iconMd),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text('LoopSmith AI Premium', style: textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    '\$9.99/mo',
                    style: textTheme.titleMedium?.copyWith(color: colors.neonSecondary),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),
              ..._premiumFeatures.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: colors.neonTertiary, size: AppTheme.iconSm),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(child: Text(f, style: textTheme.bodySmall)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              ElevatedButton(
                onPressed: () => context.push('/subscribe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.neonSecondary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Upgrade to Premium'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Connect AI card
// ---------------------------------------------------------------------------
class _ConnectAiCard extends StatefulWidget {
  @override
  State<_ConnectAiCard> createState() => _ConnectAiCardState();
}

class _ConnectAiCardState extends State<_ConnectAiCard> {
  final _ctrl = TextEditingController();
  bool _saving = false;
  bool _obscure = true;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await context.read<ReplicateService>().saveApiKey(_ctrl.text);
    _ctrl.clear();
    if (mounted) setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Replicate API key saved! AI generation is now active.'),
          backgroundColor: Theme.of(context).extension<AppColorsExtension>()!.neonTertiary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final replicate = context.watch<ReplicateService>();
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      glowColor: replicate.hasApiKey ? colors.neonTertiary : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: replicate.hasApiKey
                      ? colors.neonTertiary.withOpacity(0.15)
                      : colors.glassBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: replicate.hasApiKey ? colors.neonTertiary : colors.glassBorder,
                  ),
                ),
                child: Icon(
                  replicate.hasApiKey ? Icons.check_circle : Icons.smart_toy_outlined,
                  size: AppTheme.iconSm,
                  color: replicate.hasApiKey ? colors.neonTertiary : colors.subtleText,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Replicate AI (MusicGen)', style: textTheme.titleSmall),
                    Text(
                      replicate.hasApiKey
                          ? 'Connected — AI generation active'
                          : 'Connect to enable real AI music generation',
                      style: textTheme.bodySmall?.copyWith(
                        color: replicate.hasApiKey ? colors.neonTertiary : colors.subtleText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (replicate.hasApiKey) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: colors.glassBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(color: colors.glassBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.key, size: AppTheme.iconSm, color: colors.subtleText),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: Text(
                      replicate.maskedKey ?? '',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.subtleText,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await context.read<ReplicateService>().clearApiKey();
                    },
                    child: Text(
                      'Remove',
                      style: textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Get a free API key at replicate.com (~\$0.004 per generation)',
              style: textTheme.bodySmall?.copyWith(color: colors.subtleText),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    obscureText: _obscure,
                    style: textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText: 'r8_••••••••••••••••••••••••••••••••••••••',
                      hintStyle: textTheme.bodySmall?.copyWith(color: colors.subtleText),
                      filled: true,
                      fillColor: colors.glassBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        borderSide: BorderSide(color: colors.glassBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        borderSide: BorderSide(color: colors.glassBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        borderSide: BorderSide(color: colors.neonAccent),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingSm,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          size: AppTheme.iconSm,
                          color: colors.subtleText,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    onSubmitted: (_) => _save(),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.neonAccent,
                    foregroundColor: const Color(0xFF0A0A0F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingMd,
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A0A0F)),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

const _premiumFeatures = [
  'Unlimited loop generations per day',
  'High-quality 24-bit WAV exports',
  'Full stem export (drums, bass, melody)',
  'Advanced AI models & exclusive genres',
  'Commercial license for all loops',
  'Priority generation queue',
  'Exclusive instrument packs',
];

// ---------------------------------------------------------------------------
// Settings tile
// ---------------------------------------------------------------------------
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingMd,
        ),
        child: Row(
          children: [
            Icon(icon, size: AppTheme.iconMd, color: colors.subtleText),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(child: Text(label, style: textTheme.bodyMedium)),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
