import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../services/learnflow_store.dart';
import 'main_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _register = false;
  bool _hidePassword = true;
  bool _busy = false;

  @override
  void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); _confirmPassword.dispose(); super.dispose(); }

  Future<void> _continue({bool guest = false}) async {
    if (!guest && !(_formKey.currentState?.validate() ?? false)) return;
    if (!guest && _register && _password.text != _confirmPassword.text) {
      _message('Passwords do not match.');
      return;
    }
    setState(() => _busy = true);
    if (guest) {
      await LearnFlowStore.instance.signIn('guest@learnflow.local', name: 'Guest Learner');
    } else {
      // Prototype-only sign-in: this stores the active profile, never the password.
      await LearnFlowStore.instance.signIn(_email.text, name: _register ? _name.text : null);
    }
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell()), (_) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(leading: IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.arrow_back_rounded))),
        body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 8, 24, 28), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 12),
          Text(_register ? 'Create Account' : 'Welcome Back', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(_register ? 'Join us and start learning today.' : 'Sign in to continue your learning journey.', style: const TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 28),
          if (_register) ...[
            TextFormField(controller: _name, textInputAction: TextInputAction.next, decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline_rounded), hintText: 'Full name'), validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your name' : null),
            const SizedBox(height: 13),
          ],
          TextFormField(controller: _email, keyboardType: _register ? TextInputType.emailAddress : TextInputType.text, textInputAction: TextInputAction.next, decoration: InputDecoration(prefixIcon: Icon(_register ? Icons.mail_outline_rounded : Icons.person_outline_rounded), hintText: _register ? 'Email address' : 'Email or username'), validator: (v) { final value = v?.trim() ?? ''; if (value.isEmpty) return 'This field is required'; if (_register && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) return 'Enter a valid email'; return null; }),
          const SizedBox(height: 13),
          TextFormField(controller: _password, obscureText: _hidePassword, decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline_rounded), hintText: 'Password', suffixIcon: IconButton(onPressed: () => setState(() => _hidePassword = !_hidePassword), icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined))), validator: (v) => (v == null || v.length < 6) ? 'Use at least 6 characters' : null),
          if (_register) ...[
            const SizedBox(height: 13),
            TextFormField(controller: _confirmPassword, obscureText: _hidePassword, textInputAction: TextInputAction.done, decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline_rounded), hintText: 'Confirm password'), validator: (v) => (v == null || v.isEmpty) ? 'Confirm your password' : null),
          ],
          if (!_register) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => _message('Password reset requires a connected account service.'), child: const Text('Forgot password?'))),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _busy ? null : () => _continue(), child: Text(_busy ? 'Please wait…' : (_register ? 'Register' : 'Login')))),
          if (!_register) ...[
            const SizedBox(height: 18),
            Row(children: const [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or continue with', style: TextStyle(color: AppTheme.muted, fontSize: 12))), Expanded(child: Divider())]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => _message('Google sign-in will be available after authentication is connected.'), icon: const Icon(Icons.g_mobiledata_rounded, size: 24), label: const Text('Google'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: _busy ? null : () => _continue(guest: true), icon: const Icon(Icons.person_outline_rounded), label: const Text('Guest'))),
            ]),
          ],
          const SizedBox(height: 28),
          Center(child: Wrap(alignment: WrapAlignment.center, children: [Text(_register ? 'Already have an account? ' : "Don't have an account? ", style: const TextStyle(color: AppTheme.muted, fontSize: 13)), GestureDetector(onTap: () => setState(() => _register = !_register), child: Text(_register ? 'Login' : 'Register', style: const TextStyle(color: AppTheme.blue, fontSize: 13, fontWeight: FontWeight.w800))) ])),
          const SizedBox(height: 18),
          const Text('Demo mode: authentication is local to this device. Do not use a real password.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted, fontSize: 11)),
        ]))),),
      );

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
