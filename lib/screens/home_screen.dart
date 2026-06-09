import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LEARNRIFF DASHBOARD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // Logika untuk keluar dari sesi
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.queue_music,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              _currentIndex == 0
                  ? 'Area Practice Tracker\n(CRUD Jadwal Latihan Segera Hadir!)'
                  : 'Area Modul Senam Jari',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      // Navigasi bawah untuk perpindahan menu
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF8A0303),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF0A0A0A),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Modul Latihan',
          ),
        ],
      ),
    );
  }
}