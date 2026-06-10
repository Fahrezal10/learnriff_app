import 'package:flutter/material.dart';
import '../models/practice_schedule.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class TrackerProvider extends ChangeNotifier {
  List<PracticeSchedule> _schedules = [];
  bool _isLoading = false;

  List<PracticeSchedule> get schedules => _schedules;
  bool get isLoading => _isLoading;

  Future<void> fetchSchedules(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _schedules = await ApiService.getSchedules(userId);

      // SINKRONISASI ALARM OTOMATIS
      for (var schedule in _schedules) {
        if (!schedule.isCompleted && schedule.scheduleTime != null) {
          try {
            List<String> timeParts = schedule.scheduleTime!.split(':');
            await NotificationService.scheduleTrainingNotifications(
              id: schedule.id,
              title: schedule.moduleTitle ?? 'Materi Latihan',
              hour: int.parse(timeParts[0]),
              minute: int.parse(timeParts[1]),
            );
          } catch (e) {
            debugPrint("Gagal sync alarm otomatis: $e");
          }
        }
      }
    } catch (e) {
      debugPrint("Provider Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSchedule(String userId, int moduleId, String scheduleTime) async {
    bool success = await ApiService.addSchedule(userId, moduleId, scheduleTime);
    if (success) await fetchSchedules(userId);
    return success;
  }

  Future<bool> updateStatus(String userId, int id, bool isCompleted) async {
    bool success = await ApiService.updateStatus(id, isCompleted);
    if (success) await fetchSchedules(userId);
    return success;
  }

  Future<bool> editSchedule(String userId, int id, int moduleId, String scheduleTime) async {
    bool success = await ApiService.editSchedule(id, moduleId, scheduleTime);
    if (success) await fetchSchedules(userId);
    return success;
  }

  Future<bool> deleteSchedule(String userId, int id) async {
    bool success = await ApiService.deleteSchedule(id);
    if (success) await fetchSchedules(userId);
    return success;
  }
}