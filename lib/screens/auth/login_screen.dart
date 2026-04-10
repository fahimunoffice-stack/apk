import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isRegister = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegister ? 'রেজিস্টার' : 'লগইন'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'ইমেইল',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: const InputDecoration(
              labelText: 'পাসওয়ার্ড',
              border: OutlineInputBorder(),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isRegister ? 'অ্যাকাউন্ট তৈরি করুন' : 'লগইন'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loading
                ? null
                : () => setState(() {
                      _isRegister = !_isRegister;
                      _error = null;
                    }),
            child: Text(_isRegister
                ? 'আগেই অ্যাকাউন্ট আছে? লগইন করুন'
                : 'নতুন? রেজিস্টার করুন'),
          ),
          const SizedBox(height: 8),
          Text(
            'নোট: লগইন করার পর আপনার `stores` রেকর্ড না থাকলে Store Setup দেখাবে।',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      final email = _email.text.trim();
      final password = _password.text;
      if (email.isEmpty || password.isEmpty) {
        throw const FormatException('ইমেইল এবং পাসওয়ার্ড দিন।');
      }

      if (_isRegister) {
        await auth.signUp(email: email, password: password);
      } else {
        await auth.signIn(email: email, password: password);
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } on FormatException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'কিছু একটা সমস্যা হয়েছে। আবার চেষ্টা করুন।');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

