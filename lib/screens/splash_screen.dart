import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthSession();
  }

  void _checkAuthSession() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuth = await authProvider.checkSession();

    // Beri jeda sedikit agar logo terlihat estetik
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      if (isAuth) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // Jika sesi kosong, harus login dulu
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.electric_bolt, size: 80, color: Color(0xFF8A0303)),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Color(0xFF8A0303)),
          ],
        ),
      ),
    );
  }
}