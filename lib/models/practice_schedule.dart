class PracticeSchedule {
  final int id;
  final String userId;
  final int moduleId;
  final String scheduleTime;
  final bool isCompleted;
  final String? moduleTitle; // Boleh null jika tabel modules masih kosong

  PracticeSchedule({
    required this.id,
    required this.userId,
    required this.moduleId,
    required this.scheduleTime,
    required this.isCompleted,
    this.moduleTitle,
  });

  // Mengubah JSON dari PHP menjadi Objek Dart
  factory PracticeSchedule.fromJson(Map<String, dynamic> json) {
    return PracticeSchedule(
      id: int.parse(json['id'].toString()),
      userId: json['user_id'],
      moduleId: int.parse(json['module_id'].toString()),
      scheduleTime: json['schedule_time'],
      // Pastikan membaca boolean dengan benar dari PHP
      isCompleted: json['is_completed'] == true || json['is_completed'] == 1 || json['is_completed'] == '1',
      moduleTitle: json['module_title'],
    );
  }
}