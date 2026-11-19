import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
    Function(PhoneAuthCredential credential)? onAutoVerify,
  });

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<void> signOut();
}
