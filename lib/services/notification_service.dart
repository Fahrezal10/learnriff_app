import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); 

    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    final AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'learnriff_channel_id',
      'LearnRiff Practice Reminder',
      description: 'Channel untuk pengingat jadwal latihan gitar LearnRiff',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _notificationsPlugin.initialize(settings:
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notifikasi lokal di-klik oleh user!");
      },
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
        
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  static Future<void> scheduleTrainingNotifications({
    required int id,
    required String title,
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now();
    final scheduleDateTime = DateTime(now.year, now.month, now.day, hour, minute);

    debugPrint("=== MEMULAI PENJADWALAN ALARM LOKAL ===");
    debugPrint("Waktu sekarang di HP: $now");
    debugPrint("Target jam latihan yang diinput: $scheduleDateTime");

    // 1. Alarm H-10 Menit
    final tenMinsBefore = scheduleDateTime.subtract(const Duration(minutes: 10));
    
    if (tenMinsBefore.isAfter(now)) {
      await _notificationsPlugin.zonedSchedule(
        id: id * 10, 
        title: 'Persiapan Latihan! 🎸',
        body: 'Jadwal materi $title kamu dimulai 10 menit lagi. Siapkan gitarmu!',
        scheduledDate: tz.TZDateTime.from(tenMinsBefore, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'learnriff_channel_id',
            'LearnRiff Practice Reminder',
            importance: Importance.max, 
            priority: Priority.high,
            // playWaveform yang rusak udah dibuang murni dari sini
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint("✅ LOG: Alarm H-10 MENIT BERHASIL didaftarkan!");
    }

    // 2. Alarm Tepat Waktu (Hari H)
    if (scheduleDateTime.isAfter(now)) {
      await _notificationsPlugin.zonedSchedule(
        id: id * 10 + 1,
        title: 'Waktunya Nge-Jam! 🤘',
        body: 'Sekarang waktunya latihan materi $title. Yuk buka aplikasi!',
        scheduledDate: tz.TZDateTime.from(scheduleDateTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'learnriff_channel_id',
            'LearnRiff Practice Reminder',
            importance: Importance.max, 
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint("✅ LOG: Alarm HARI H BERHASIL didaftarkan!");
    }
    debugPrint("=======================================");
  }
}