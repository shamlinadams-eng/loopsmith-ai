import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/theme.dart';

enum AuthFormMode { signIn, signUp }

class AuthForm extends StatefulWidget {
  final AuthFormMode mode;
  final VoidCallback onSuccess;

  const AuthForm({super.key, required this.mode, required this.onSuccess});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _resetSent = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthService>();
    bool ok;
    if (widget.mode == AuthFormMode.signIn) {
      ok = await auth.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
    } else {
      ok = await auth.createAccountWithEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text,
        _nameCtrl.text.trim(),
      );
    }
    if (ok && mounted) widget.onSuccess();
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email above first.')),
      );
      return;
    }
    final auth = context.read<AuthService>();
    final ok = await auth.sendPasswordReset(email);
    if (ok && mounted) setState(() => _resetSent = true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;
    final auth = context.watch<AuthService>();
    final isSignUp = widget.mode == AuthFormMode.signUp;

    if (_resetSent) {
      return Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_email_read_outlined, size: 48, color: colors.neonTertiary),
            const SizedBox(height: AppTheme.spacingMd),
            Text('Reset link sent!', style: textTheme.titleMedium),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Check your inbox and follow the link to reset your password.',
              style: textTheme.bodySmall?.copyWith(color: colors.subtleText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            TextButton(
              onPressed: () => setState(() => _resetSent = false),
              child: const Text('Back to sign in'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppTheme.spacingMd),

            if (isSignUp) ...[
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Producer Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
              ),
              const SizedBox(height: AppTheme.spacingMd),
            ],

            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: AppTheme.spacingMd),

            TextFormField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
            ),

            if (!isSignUp) ...[
              const SizedBox(height: AppTheme.spacingXs),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: Text(
                    'Forgot password?',
                    style: textTheme.labelSmall?.copyWith(color: colors.neonAccent),
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppTheme.spacingMd),

            ElevatedButton(
              onPressed: auth.isLoading ? null : _submit,
              child: auth.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isSignUp ? 'Create Account' : 'Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
