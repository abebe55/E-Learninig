import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../services/learnflow_store.dart';
import 'main_shell.dart';

/// Login and registration screen.
///
/// Authentication is local-only (no backend). Credentials are stored with
/// SharedPreferences and validated only for basic format. This is sufficient
/// for a prototype; a production app would verify against a secure backend.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isRegister = false;
  bool _hidePassword = true;
  bool _busy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _submit({bool guest = false}) async {
    if (!guest && !(_formKey.currentState?.validate() ?? false)) return;

    if (!guest &&
        _isRegister &&
        _passwordController.text != _confirmController.text) {
      _showSnackBar('Passwords do not match.');
      return;
    }

    setState(() => _busy = true);

    if (guest) {
      await LearnFlowStore.instance
          .signIn('guest@learnflow.local', name: 'Guest Learner');
    } else {
      await LearnFlowStore.instance.signIn(
        _emailController.text,
        name: _isRegister ? _nameController.text : null,
      );
    }

    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  void _toggleMode() => setState(() => _isRegister = !_isRegister);

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // Heading
                Text(
                  _isRegister ? 'Create Account' : 'Welcome Back',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _isRegister
                      ? 'Join us and start learning today.'
                      : 'Sign in to continue your learning journey.',
                  style: const TextStyle(color: AppTheme.muted),
                ),
                const SizedBox(height: 28),

                // Name field (register only)
                if (_isRegister) ...[
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline_rounded),
                      hintText: 'Full name',
                    ),
                    validator: (v) => (v == null || v.trim().length < 2)
                        ? 'Enter your name'
                        : null,
                  ),
                  const SizedBox(height: 13),
                ],

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: _isRegister
                      ? TextInputType.emailAddress
                      : TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      _isRegister
                          ? Icons.mail_outline_rounded
                          : Icons.person_outline_rounded,
                    ),
                    hintText:
                        _isRegister ? 'Email address' : 'Email or username',
                  ),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'This field is required';
                    if (_isRegister &&
                        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 13),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _hidePassword = !_hidePassword),
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Use at least 6 characters'
                      : null,
                ),

                // Confirm password (register only)
                if (_isRegister) ...[
                  const SizedBox(height: 13),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: _hidePassword,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                      hintText: 'Confirm password',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Confirm your password' : null,
                  ),
                ],

                // Forgot password (login only)
                if (!_isRegister)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showSnackBar(
                        'Password reset requires a connected account service.',
                      ),
                      child: const Text('Forgot password?'),
                    ),
                  ),

                const SizedBox(height: 12),

                // Primary CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(
                      _busy
                          ? 'Please wait…'
                          : (_isRegister ? 'Register' : 'Login'),
                    ),
                  ),
                ),

                // Social login (login screen only)
                if (!_isRegister) ...[
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                            color: AppTheme.muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showSnackBar(
                            'Google sign-in will be available after '
                            'authentication is connected.',
                          ),
                          icon: const Icon(
                            Icons.g_mobiledata_rounded,
                            size: 24,
                          ),
                          label: const Text('Google'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : () => _submit(guest: true),
                          icon: const Icon(Icons.person_outline_rounded),
                          label: const Text('Guest'),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 28),

                // Switch between login / register
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        _isRegister
                            ? 'Already have an account? '
                            : "Don't have an account? ",
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleMode,
                        child: Text(
                          _isRegister ? 'Login' : 'Register',
                          style: const TextStyle(
                            color: AppTheme.blue,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                const Text(
                  'Demo mode: authentication is local to this device. '
                  'Do not use a real password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
}
