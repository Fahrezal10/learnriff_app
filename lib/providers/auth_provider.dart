import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // BENAR! Menggunakan .instance seperti kata Anda (Wajib untuk v7.2.0)
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isAuthenticated = false;
  String _token = '';

  bool get isAuthenticated => _isAuthenticated;
  String get token => _token;

  // Mengecek sesi saat aplikasi pertama kali dibuka
  Future<bool> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');
    
    if (savedToken != null && savedToken.isNotEmpty) {
      _isAuthenticated = true;
      _token = savedToken;
      notifyListeners();
      return true;
    }
    
    _isAuthenticated = false;
    notifyListeners();
    return false;
  }

  // Logika Login dengan Google Sign-In (Versi 7.2.0)
  Future<bool> loginWithGoogle() async {
    try {
      // DI SINILAH TEMPATNYA! Masukkan Client ID ke dalam fungsi initialize()
      await _googleSignIn.initialize(
        serverClientId: '697899159013-ifaadmbn0sipnkbhlpm08a6v2vl7h0f2.apps.googleusercontent.com',
      );

      // Memanggil pop-up akun Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return false; // User membatalkan login

      // Mendapatkan detail identitas dasar
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Meminta izin (scope) secara eksplisit untuk mendapatkan Access Token
      final clientAuth = await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);

      // Membuat kredensial baru untuk Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: clientAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Masuk ke Firebase dengan kredensial tersebut
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', user.uid);
        
        _isAuthenticated = true;
        _token = user.uid;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error Google Sign-In: $e");
      return false;
    }
  }

  // Logika Logout Bersih
  Future<void> logout() async {
    // Pastikan terinisialisasi juga saat sign out agar tidak error
    await _googleSignIn.initialize(
      serverClientId: '697899159013-ifaadmbn0sipnkbhlpm08a6v2vl7h0f2.apps.googleusercontent.com',
    );
    
    // Keluar dari Google dan Firebase
    await _googleSignIn.signOut();
    await _auth.signOut();

    // Hapus sesi dari Shared Preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    
    _isAuthenticated = false;
    _token = '';
    notifyListeners();
  }
}