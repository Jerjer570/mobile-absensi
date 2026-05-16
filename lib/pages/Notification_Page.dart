import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Wajib import ini
import '../models/alarm_model.dart';
import '../service/notifikasi_service.dart';
import '../service/alarm_scheduler_service.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  // --- STATE DATA ---
  String mainTime = "07.00"; 
  
  List<AlarmModel> alarms = [
    AlarmModel(label: "07.00", time: "07.00", isActive: false), // Index 0: Masuk
    AlarmModel(label: "Pulang", time: "17.00", isActive: false), // Index 1: Pulang
  ];

  @override
  void initState() {
    super.initState();
    _loadAlarmData(); // Muat data dari memori saat aplikasi dibuka
  }

  // --- LOGIKA PENYIMPANAN (PERSISTENCE) ---

  // 1. Fungsi memuat data dari SharedPreferences
  Future<void> _loadAlarmData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil data list alarm (dalam bentuk String JSON)
    final List<String>? savedAlarms = prefs.getStringList('saved_alarms');
    final String? savedMainTime = prefs.getString('saved_main_time');

    if (savedAlarms != null) {
      setState(() {
        alarms = savedAlarms.map((item) => AlarmModel.fromJson(item)).toList();
        if (savedMainTime != null) mainTime = savedMainTime;
      });
    }
  }

  // 2. Fungsi menyimpan data ke SharedPreferences
  Future<void> _saveAlarmData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ubah List Objek ke List String JSON agar bisa disimpan
    List<String> alarmStrings = alarms.map((item) => item.toJson()).toList();
    
    await prefs.setStringList('saved_alarms', alarmStrings);
    await prefs.setString('saved_main_time', mainTime);
    print("Data alarm disimpan ke memori HP");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifikasi', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildSectionTitle("Setting Jam"),
            _buildSettingJamCard(),
            const SizedBox(height: 30),
            _buildSectionTitle("Ingatkan Absen"),
            _buildIngatkanAbsenCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildSettingJamCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA), 
        borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny, color: Colors.orange, size: 24),
          const SizedBox(width: 15),
          Text(mainTime, 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            onPressed: () => NotificationService.showEditAlarmPopup(
              context, 
              onSave: (duration, isMasuk) async {
                setState(() {
                  String hour = duration.inHours.toString().padLeft(2, '0');
                  String min = (duration.inMinutes % 60).toString().padLeft(2, '0');
                  String newTime = "$hour.$min";

                  int index = isMasuk ? 0 : 1;
                  alarms[index] = alarms[index].copyWith(
                    time: newTime,
                    label: isMasuk ? newTime : "Pulang", 
                  );
                  mainTime = newTime;
                });

                // SIMPAN PERUBAHAN KE MEMORI
                await _saveAlarmData();

                // UPDATE JADWAL ALARM DI SISTEM HP JIKA TOGGLE ON
                int targetId = isMasuk ? 0 : 1;
                if (alarms[targetId].isActive) {
                  await AlarmSchedulerService.scheduleNotification(
                    id: targetId,
                    title: "Waktunya Absen ${isMasuk ? 'Masuk' : 'Pulang'}!",
                    body: "Jangan lupa lakukan presensi Tunas Jaya sekarang.",
                    hour: duration.inHours,
                    minute: duration.inMinutes % 60,
                  );
                }
              }
            ),
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF20295F), size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildIngatkanAbsenCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA), 
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        children: alarms.map((alarm) => _buildAlarmRow(alarm)).toList(),
      ),
    );
  }

  Widget _buildAlarmRow(AlarmModel alarm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_outlined, color: Colors.orange, size: 24),
          const SizedBox(width: 15),
          Text(alarm.label, 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(),
          Switch.adaptive(
            value: alarm.isActive,
            activeColor: const Color(0xFF20295F),
            onChanged: (val) async {
              setState(() {
                int index = alarms.indexOf(alarm);
                alarms[index] = alarm.copyWith(isActive: val);
              });

              // SIMPAN STATUS TOGGLE KE MEMORI
              await _saveAlarmData();

              if (val) {
                List<String> parts = alarm.time.split('.'); 
                int hour = int.parse(parts[0]);
                int minute = int.parse(parts[1]);

                await AlarmSchedulerService.scheduleNotification(
                  id: alarm.label == "Pulang" ? 1 : 0, 
                  title: "Waktunya Absen ${alarm.label}!",
                  body: "Buka aplikasi untuk presensi sekarang.",
                  hour: hour,
                  minute: minute,
                );
              } else {
                await AlarmSchedulerService.cancelNotification(alarm.label == "Pulang" ? 1 : 0);
              }
            },
          ),
        ],
      ),
    );
  }
}