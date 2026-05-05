import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../service/notifikasi_service.dart'; // Pastikan file ini ada

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  // --- STATE DATA ---
  String mainTime = "12.00";
  
  List<AlarmModel> alarms = [
    AlarmModel(label: "07.00", time: "07.00", isActive: true),
    AlarmModel(label: "Pulang", time: "17.00", isActive: false),
  ];

  // HAPUS baris 'get NotificationService => null;' yang sebelumnya ada di sini

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

  // --- UI COMPONENTS ---

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
            // Memanggil Service yang Benar
            onPressed: () => NotificationService.showEditAlarmPopup(
            context, 
              onTimeChanged: (duration) {
                setState(() {
                  // Format jam ke 00.00 (pakai titik sesuai desain Anda)
                  String hours = duration.inHours.toString().padLeft(2, '0');
                  String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
                  mainTime = "$hours.$minutes";
                });
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
            onChanged: (val) {
              setState(() {
                int index = alarms.indexOf(alarm);
                alarms[index] = alarm.copyWith(isActive: val);
              });
            },
          ),
        ],
      ),
    );
  }
}