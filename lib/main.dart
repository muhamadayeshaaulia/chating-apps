import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Muat environment variables dari file .env
  await dotenv.load(fileName: ".env");

  // 2. Inisialisasi Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // 3. Inisialisasi Supabase
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseUrl.contains('your-project-id')) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isSupabaseConfigured =
        dotenv.env['SUPABASE_URL'] != null &&
        !dotenv.env['SUPABASE_URL']!.contains('your-project-id');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App Setup'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Konfigurasi:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.local_fire_department, color: Colors.amber),
                title: const Text('Firebase'),
                subtitle: const Text('Terkonfigurasi via google-services.json'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(
                  isSupabaseConfigured ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: isSupabaseConfigured ? Colors.green : Colors.orange,
                ),
                title: const Text('Supabase'),
                subtitle: Text(
                  isSupabaseConfigured
                      ? 'Terkoneksi dengan Supabase'
                      : 'Silakan isi URL & Anon Key di file .env',
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Langkah Selanjutnya:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('1. Buka file .env dan masukkan Project URL serta Anon Key dari Supabase.'),
            const Text('2. Buat tabel messages & profiles di database Supabase dengan fitur Realtime aktif.'),
            const Text('3. Buat UI Chat Screen untuk kirim dan terima pesan secara realtime.'),
          ],
        ),
      ),
    );
  }
}
