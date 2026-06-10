import 'package:flutter/material.dart';
import '../models/practice_schedule.dart';
import '../services/api_service.dart'; // Import service yang baru kita buat

class TrackerProvider extends ChangeNotifier {
  List<PracticeSchedule> _schedules = [];
  bool _isLoading = false;

  List<PracticeSchedule> get schedules => _schedules;
  bool get isLoading => _isLoading;

  // READ: Minta data ke ApiService
  Future<void> fetchSchedules(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _schedules = await ApiService.getSchedules(userId);
    } catch (e) {
      debugPrint("Provider Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CREATE: Minta ApiService tambah data
  Future<bool> addSchedule(String userId, int moduleId, String scheduleTime) async {
    bool success = await ApiService.addSchedule(userId, moduleId, scheduleTime);
    if (success) {
      await fetchSchedules(userId); // Langsung refresh data jika sukses
    }
    return success;
  }

  // UPDATE: Minta ApiService ubah status
  Future<bool> updateStatus(String userId, int id, bool isCompleted) async {
    bool success = await ApiService.updateStatus(id, isCompleted);
    if (success) {
      await fetchSchedules(userId); // Langsung refresh data
    }
    return success;
  }

  // EDIT: Minta ApiService ubah materi & jam
  Future<bool> editSchedule(String userId, int id, int moduleId, String scheduleTime) async {
    bool success = await ApiService.editSchedule(id, moduleId, scheduleTime);
    if (success) {
      await fetchSchedules(userId); // Langsung refresh data
    }
    return success;
  }

  // DELETE: Minta ApiService hapus data
  Future<bool> deleteSchedule(String userId, int id) async {
    bool success = await ApiService.deleteSchedule(id);
    if (success) {
      await fetchSchedules(userId); // Langsung refresh data
    }
    return success;
  }
}