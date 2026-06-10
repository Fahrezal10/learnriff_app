import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Senjata rahasia FCM
import 'providers/auth_provider.dart';
import 'providers/tracker_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart'; // Biarin file lokal lu tetep ada

// Tangkap notifikasi kalau aplikasi lagi di background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("FCM Background Masuk: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Nyalain Mesin Firebase
  await Firebase.initializeApp(); 
  
  // 2. Setup Firebase Messaging buat Nembak Manual
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  await messaging.requestPermission(alert: true, badge: true, sound: true);
  
  // DAPETIN TOKEN BUAT DI-PASTE DI FIREBASE CONSOLE
  String? token = await messaging.getToken();
  print('====================================');
  print('FCM TOKEN HP LU: $token');
  print('====================================');

  // Dengerin kalau notif diklik dari background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notifikasi FCM di-klik!');
  });

  // 3. Biarin init lokal tetep ada biar kodingan lu gak merah
  try {
    await NotificationService.init();
  } catch (e) {
    print("Alarm lokal diabaikan");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TrackerProvider()),
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
      home: const SplashScreen(),
    );
  }
}