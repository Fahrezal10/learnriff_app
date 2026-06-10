import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/tracker_provider.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Memanggil operasi READ saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<TrackerProvider>(context, listen: false).fetchSchedules(auth.token);
    });
  }

  // ==========================================
  // OPERASI CREATE: Dialog Form Tambah Jadwal
  // ==========================================
  void _showAddDialog() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final tracker = Provider.of<TrackerProvider>(context, listen: false);
    
    // Default pilihan
    int selectedModuleId = 1;
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Tambah Jadwal Latihan', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedModuleId,
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Pilih Materi',
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF121212),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Senam Jari Pentatonic')),
                      DropdownMenuItem(value: 2, child: Text('Chord Transisi')),
                      DropdownMenuItem(value: 3, child: Text('Sweep Picking Dasar')),
                    ],
                    onChanged: (val) => setStateDialog(() => selectedModuleId = val!),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    tileColor: const Color(0xFF121212),
                    title: const Text('Waktu Latihan', style: TextStyle(color: Colors.white)),
                    trailing: Text(selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8A0303))),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) setStateDialog(() => selectedTime = time);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Format waktu ke string HH:MM:00 untuk MySQL
                    final timeString = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00';
                    
                    Navigator.pop(context); // Tutup dialog
                    
                    // Eksekusi API Create
                    // Eksekusi API Create
                    final success = await tracker.addSchedule(auth.token, selectedModuleId, timeString);
                    if (mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jadwal ditambahkan!')));
                      } else {
                        // INI ERROR HANDLING-NYA
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Gagal menyimpan jadwal. Cek koneksi server.'),
                          backgroundColor: Colors.red,
                        ));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A0303)),
                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // ==========================================
  // OPERASI UPDATE (FORM): Dialog Form Edit Jadwal
  // ==========================================
  void _showEditDialog(BuildContext context, int id, int currentModuleId, String currentTime) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final tracker = Provider.of<TrackerProvider>(context, listen: false);
    
    int selectedModuleId = currentModuleId;
    
    // Parsing string "HH:MM:SS" ke TimeOfDay
    List<String> timeParts = currentTime.split(':');
    TimeOfDay selectedTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Edit Jadwal', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedModuleId,
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Pilih Materi',
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF121212),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Senam Jari Pentatonic')),
                      DropdownMenuItem(value: 2, child: Text('Chord Transisi')),
                      DropdownMenuItem(value: 3, child: Text('Sweep Picking Dasar')),
                    ],
                    onChanged: (val) => setStateDialog(() => selectedModuleId = val!),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    tileColor: const Color(0xFF121212),
                    title: const Text('Waktu Latihan', style: TextStyle(color: Colors.white)),
                    trailing: Text(selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) setStateDialog(() => selectedTime = time);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final timeString = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00';
                    Navigator.pop(context); 
                    
                    // Eksekusi API Edit
                    // Eksekusi API Edit
                    final success = await tracker.editSchedule(auth.token, id, selectedModuleId, timeString);
                    if (mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jadwal diperbarui!')));
                      } else {
                        // INI ERROR HANDLING-NYA
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Gagal memperbarui jadwal. Cek koneksi server.'),
                          backgroundColor: Colors.red,
                        ));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  child: const Text('Update', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PRACTICE TRACKER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF121212),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: () async {
              await auth.logout();
              if (mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          ),
        ],
      ),
      // ==========================================
      // OPERASI READ: Menampilkan Daftar (Consumer)
      // ==========================================
      body: Consumer<TrackerProvider>(
        builder: (context, tracker, child) {
          if (tracker.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF8A0303)));
          }

          if (tracker.schedules.isEmpty) {
            return const Center(
              child: Text('Belum ada jadwal latihan.\nKlik + untuk mulai rock and roll!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tracker.schedules.length,
            itemBuilder: (context, index) {
              final schedule = tracker.schedules[index];
              
              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: schedule.isCompleted ? Colors.green.withOpacity(0.5) : Colors.transparent,
                    width: 2
                  ),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  // ==========================================
                  // OPERASI UPDATE: Checkbox Status
                  // ==========================================
                  leading: Checkbox(
                    value: schedule.isCompleted,
                    activeColor: Colors.green,
                    checkColor: Colors.black,
                    onChanged: (bool? newValue) async {
                      if (newValue != null) {
                        await tracker.updateStatus(auth.token, schedule.id, newValue);
                      }
                    },
                  ),
                  title: Text(
                    schedule.moduleTitle ?? 'Materi Tidak Diketahui',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: schedule.isCompleted ? TextDecoration.lineThrough : null,
                      color: schedule.isCompleted ? Colors.grey : Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    'Waktu: ${schedule.scheduleTime}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  // ==========================================
                  // OPERASI UPDATE & DELETE (Ikon Pensil & Sampah)
                  // ==========================================
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol Edit
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () {
                          _showEditDialog(context, schedule.id, schedule.moduleId, schedule.scheduleTime);
                        },
                      ),
                      // Tombol Hapus
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF1E1E1E),
                              title: const Text('Hapus Jadwal?', style: TextStyle(color: Colors.white)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            )
                          );
                          
                          if (confirm == true) {
                            final success = await tracker.deleteSchedule(auth.token, schedule.id);
                            if (mounted) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jadwal dihapus.')));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('Gagal menghapus. Cek koneksi server.'),
                                  backgroundColor: Colors.red,
                                ));
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF8A0303),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}