import 'dart:async'; // Tambahan buat Timer otomatis
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
  Timer? _liveClockTimer; // Timer buat maksa UI cek jam secara realtime

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<TrackerProvider>(context, listen: false).fetchSchedules(auth.token);
    });

    // PENTING: Tiap 10 detik, suruh UI cek ulang apakah jam target sudah tiba
    _liveClockTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {}); // Paksa rebuild ringan untuk update status denyut card
      }
    });
  }

  @override
  void dispose() {
    _liveClockTimer?.cancel(); // Matikan timer saat keluar halaman biar gak bocor
    super.dispose();
  }

  void _showAddDialog() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final tracker = Provider.of<TrackerProvider>(context, listen: false);
    
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
                    final timeString = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00';
                    Navigator.pop(context); 
                    
                    final success = await tracker.addSchedule(auth.token, selectedModuleId, timeString);
                    if (mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jadwal ditambahkan!')));
                      } else {
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

  void _showEditDialog(BuildContext context, int id, int currentModuleId, String currentTime) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final tracker = Provider.of<TrackerProvider>(context, listen: false);
    
    int selectedModuleId = currentModuleId;
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
                    
                    final success = await tracker.editSchedule(auth.token, id, selectedModuleId, timeString);
                    if (mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jadwal diperbarui!')));
                      } else {
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
              
              // LOGIKA LIVE CHECKER
              bool isTimeArrived = false;
              try {
                List<String> timeParts = schedule.scheduleTime!.split(':');
                int scheduleHour = int.parse(timeParts[0]);
                int scheduleMinute = int.parse(timeParts[1]);
                
                DateTime now = DateTime.now();
                
                if (now.hour > scheduleHour) {
                  isTimeArrived = true;
                } else if (now.hour == scheduleHour && now.minute >= scheduleMinute) {
                  isTimeArrived = true;
                }
              } catch (e) {
                isTimeArrived = false;
              }

              return PulsatingCard(
                isTimeArrived: isTimeArrived,
                isCompleted: schedule.isCompleted,
                child: Card(
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () {
                            _showEditDialog(context, schedule.id, schedule.moduleId, schedule.scheduleTime!);
                          },
                        ),
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

class PulsatingCard extends StatefulWidget {
  final Widget child;
  final bool isTimeArrived;
  final bool isCompleted;

  const PulsatingCard({
    super.key,
    required this.child,
    required this.isTimeArrived,
    required this.isCompleted,
  });

  @override
  State<PulsatingCard> createState() => _PulsatingCardState();
}

class _PulsatingCardState extends State<PulsatingCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), 
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _checkAnimation();
  }

  @override
  void didUpdateWidget(covariant PulsatingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkAnimation();
  }

  void _checkAnimation() {
    if (widget.isTimeArrived && !widget.isCompleted) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              if (widget.isTimeArrived && !widget.isCompleted)
                BoxShadow(
                  color: const Color(0xFF8A0303).withOpacity(0.8), 
                  blurRadius: _glowAnimation.value * 1.5,
                  spreadRadius: _glowAnimation.value / 1.5,
                ),
            ],
          ),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}