import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Tambahan Firebase
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart'; // Halaman awal diganti Splash
import 'providers/tracker_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Wajib diinisialisasi untuk menggunakan Google Sign-In & Firebase
  await Firebase.initializeApp(); 
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TrackerProvider()), // Tambahkan baris ini
      ],
      child: const LearnRiffApp(),
    ),
  );
}

class LearnRiffApp extends StatelessWidget {
  const LearnRiffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnRiff',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF8A0303),
      ),
      home: const SplashScreen(), // Proteksi pengecekan sesi dimulai di sini
    );
  }
}