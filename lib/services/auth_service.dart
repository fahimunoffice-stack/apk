import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  SupabaseClient get _sb => Supabase.instance.client;

  User? get currentUser => _sb.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _sb.auth.onAuthStateChange;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _sb.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _sb.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() => _sb.auth.signOut();
}

