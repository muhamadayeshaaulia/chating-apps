import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Stream untuk memantau status login pengguna
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Mendapatkan data pengguna yang sedang login saat ini
  User? get currentUser => _auth.currentUser;

  /// Mengirim kode OTP ke nomor telepon yang diinput
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
          // Terjadi jika Android otomatis membaca SMS (Instant Verification)
          if (onAutoVerify != null) {
            onAutoVerify(credential);
          } else {
            await _auth.signInWithCredential(credential);
            await _syncProfileToSupabase(_auth.currentUser);
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

  /// Memverifikasi kode OTP yang diinput pengguna
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    // Sinkronkan data pengguna Firebase ke tabel profiles di Supabase
    await _syncProfileToSupabase(userCredential.user);

    return userCredential;
  }

  /// Menyimpan / memperbarui profil pengguna di Supabase
  Future<void> _syncProfileToSupabase(User? user) async {
    if (user == null) return;

    try {
      await _supabase.from('profiles').upsert({
        'id': user.uid,
        'username': user.phoneNumber ?? 'User',
      });
    } catch (e) {
      debugPrint('Error syncing profile to Supabase: $e');
    }
  }

  /// Logout dari aplikasi
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
