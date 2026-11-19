import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  final AuthRepository _authRepository = AuthRepositoryImpl();

  HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isSupabaseConfigured =
        dotenv.env['SUPABASE_URL'] != null &&
        !dotenv.env['SUPABASE_URL']!.contains('your-project-id');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () async {
              await _authRepository.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.deepPurple.shade50,
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(
                  user.phoneNumber ?? 'Pengguna',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('UID: ${user.uid}'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Status Konfigurasi:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Firebase Phone Auth'),
                subtitle: Text('Berhasil Login dengan Nomor HP'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(
                  isSupabaseConfigured ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: isSupabaseConfigured ? Colors.green : Colors.orange,
                ),
                title: const Text('Database Supabase'),
                subtitle: Text(
                  isSupabaseConfigured
                      ? 'Terkoneksi'
                      : 'Isi SUPABASE_URL & ANON_KEY di .env',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
