import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/practice_schedule.dart';

class ApiService {
  // Ganti dengan IP laptop Anda seperti yang kita bahas sebelumnya
  // Karena ini file terpisah, Anda bisa dengan mudah merahasiakan URL ini nanti
  static const String baseUrl = 'http://10.47.43.117/learnriff_api/tracker_api.php';

  // 1. READ Data
  static Future<List<PracticeSchedule>> getSchedules(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?user_id=$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          List<dynamic> jsonList = data['data'];
          return jsonList.map((json) => PracticeSchedule.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print("ApiService GET Error: $e");
    }
    return []; // Kembalikan list kosong jika gagal
  }

  // 2. CREATE Data (Dengan CCTV Debugging)
  static Future<bool> addSchedule(String userId, int moduleId, String scheduleTime) async {
    try {
      print("---- CEK PENGIRIMAN DATA ----");
      print("UserID: '$userId'");
      print("ModuleID: $moduleId");
      print("Time: $scheduleTime");

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'user_id': userId,
          'module_id': moduleId,
          'schedule_time': scheduleTime,
        }),
      );
      
      print("Status Code dari PHP: ${response.statusCode}");
      print("Alasan dari PHP: ${response.body}");
      print("-----------------------------");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'success';
      }
    } catch (e) {
      print("ApiService POST Error: $e");
    }
    return false;
  }

  // 3. UPDATE Data
  static Future<bool> updateStatus(int id, bool isCompleted) async {
    try {
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'id': id,
          'is_completed': isCompleted,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'success';
      }
    } catch (e) {
      print("ApiService PUT Error: $e");
    }
    return false;
  }

  // 5. EDIT Data (Isi Jadwal)
  static Future<bool> editSchedule(int id, int moduleId, String scheduleTime) async {
    try {
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'id': id,
          'module_id': moduleId,
          'schedule_time': scheduleTime,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'success';
      }
    } catch (e) {
      print("ApiService PUT Edit Error: $e");
    }
    return false;
  }

  // 4. DELETE Data
  static Future<bool> deleteSchedule(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl?id=$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'success';
      }
    } catch (e) {
      print("ApiService DELETE Error: $e");
    }
    return false;
  }
}