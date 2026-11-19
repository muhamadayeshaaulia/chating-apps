import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../firebase_options.dart';

class InitServices {
  /// Menginisialisasi seluruh service inti aplikasi (.env, Firebase, Supabase)
  static Future<void> init() async {
    // Muat Environment Variables (.env)
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint('Dotenv loading warning: $e');
    }

    // Inisialisasi Firebase
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase initialization warning: $e');
    }

    // Inisialisasi Supabase
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseUrl.contains('your-project-id')) {
      try {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
        );
      } catch (e) {
        debugPrint('Supabase initialization warning: $e');
      }
    }
  }
}
