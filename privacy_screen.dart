import 'package:flutter/material.dart';
import '../theme/theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
          Text(
            'Privacy Policy',
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            'Last updated: June 28, 2026',
            style: textTheme.bodySmall?.copyWith(color: colors.subtleText),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          ..._sections.map((s) => _PolicySection(title: s.title, body: s.body)),
          const SizedBox(height: AppTheme.spacingXxl),
          Text(
            'Contact Us',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'If you have questions about this Privacy Policy, please contact us at:\n\nprivacy@loopsmithai.com\n\nLoopSmith AI\nUnited States',
            style: textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppTheme.spacingXl),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;

  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            body,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.subtleText,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section {
  final String title;
  final String body;
  const _Section(this.title, this.body);
}

const _sections = [
  _Section(
    '1. Information We Collect',
    'We collect information you provide directly to us, such as when you create an account, generate loops, or contact us for support.\n\n'
        'Account Information: When you create an account, we collect your name, email address, and authentication provider (Google, Apple, or email).\n\n'
        'Usage Data: We collect information about how you use LoopSmith AI, including the loops you generate, prompts you enter, and features you use. Prompts and loop parameters are sent to our AI music generation service to produce your loops.\n\n'
        'Device Information: We collect information about your device, including operating system, app version, and device identifiers for crash reporting and performance monitoring.',
  ),
  _Section(
    '2. How We Use Your Information',
    'We use the information we collect to:\n\n'
        '• Provide, maintain, and improve LoopSmith AI\n'
        '• Process loop generation requests via our AI backend\n'
        '• Manage your account and sync your loop library across devices\n'
        '• Process subscription payments through Stripe\n'
        '• Send you service-related notifications and updates\n'
        '• Monitor and analyze usage patterns to improve our AI models\n'
        '• Respond to your comments and questions\n'
        '• Enforce our Terms of Service',
  ),
  _Section(
    '3. AI-Generated Content & Prompts',
    'The text prompts you enter to generate loops are transmitted to our AI music generation service. We may use anonymized prompt data in aggregate to improve our models. We do not sell your prompts to third parties. Generated loops are royalty-free for personal and commercial use under our standard license (Premium subscribers receive an extended commercial license).',
  ),
  _Section(
    '4. Sharing Your Information',
    'We do not sell, trade, or rent your personal information to third parties. We may share your information with:\n\n'
        '• Service Providers: Third-party vendors who assist in providing our service (Firebase for authentication and storage, Stripe for payment processing, AI generation API providers).\n\n'
        '• Legal Requirements: We may disclose your information if required by law or in response to valid legal process.\n\n'
        '• Business Transfers: If LoopSmith AI is acquired or merges with another company, your information may be transferred as part of that transaction.',
  ),
  _Section(
    '5. Data Retention',
    'We retain your account information and loop library for as long as your account is active or as needed to provide our services. You may delete your account at any time, which will permanently delete your profile and cloud-stored loops. Locally cached loops on your device are not affected by account deletion.',
  ),
  _Section(
    '6. Security',
    'We implement industry-standard security measures to protect your personal information, including encrypted transmission (HTTPS/TLS) and secure storage via Firebase. However, no method of transmission over the internet is 100% secure. We encourage you to use strong, unique passwords for your account.',
  ),
  _Section(
    '7. Children\'s Privacy',
    'LoopSmith AI is not directed at children under the age of 13. We do not knowingly collect personal information from children under 13. If we discover that a child under 13 has provided us with personal information, we will delete it promptly.',
  ),
  _Section(
    '8. Your Rights',
    'Depending on your location, you may have the right to:\n\n'
        '• Access the personal information we hold about you\n'
        '• Request correction of inaccurate data\n'
        '• Request deletion of your account and associated data\n'
        '• Opt out of marketing communications\n'
        '• Data portability (export your loop library)\n\n'
        'To exercise any of these rights, contact us at privacy@loopsmithai.com.',
  ),
  _Section(
    '9. Third-Party Services',
    'LoopSmith AI integrates with the following third-party services, each with their own privacy policies:\n\n'
        '• Google Firebase (Authentication & Storage): firebase.google.com/support/privacy\n'
        '• Google Sign-In: policies.google.com/privacy\n'
        '• Apple Sign-In: apple.com/legal/privacy\n'
        '• Stripe (Payments): stripe.com/privacy',
  ),
  _Section(
    '10. Changes to This Policy',
    'We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new Privacy Policy in the app and updating the "Last updated" date at the top. Your continued use of LoopSmith AI after changes are posted constitutes your acceptance of the updated policy.',
  ),
];
