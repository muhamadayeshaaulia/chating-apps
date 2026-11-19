import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final SupabaseClient? _supabase;

  AuthRepositoryImpl({FirebaseAuth? auth, SupabaseClient? supabase})
      : _auth = auth ?? FirebaseAuth.instance,
        _supabase = supabase ??
            (Supabase.instance.isInitialized ? Supabase.instance.client : null);

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
    Function(PhoneAuthCredential credential)? onAutoVerify,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (onAutoVerify != null) {
            onAutoVerify(credential);
          } else {
            final userCredential = await _auth.signInWithCredential(credential);
            await _syncProfileToSupabase(userCredential.user);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Verification failed: ${e.message}');
          onError(e.message ?? 'Verifikasi nomor telepon gagal.');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('Timeout verifikasi otomatis.');
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  @override
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    await _syncProfileToSupabase(userCredential.user);

    return userCredential;
  }

  Future<void> _syncProfileToSupabase(User? user) async {
    if (user == null || _supabase == null) return;

    try {
      await _supabase.from('profiles').upsert({
        'id': user.uid,
        'username': user.phoneNumber ?? 'User',
      });
    } catch (e) {
      debugPrint('Error syncing profile to Supabase: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
