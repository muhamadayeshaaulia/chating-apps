import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/init_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi seluruh core service (.env, Firebase, Supabase)
  await InitServices.init();

  runApp(const MyApp());
}
