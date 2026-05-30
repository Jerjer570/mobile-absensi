import 'package:flutter/material.dart';
import 'services/alarm_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() =>
      _NotificationPageState();
}

class _NotificationPageState
    extends State<NotificationPage> {

  bool isMasukActive = false;
  bool isKeluarActive = false;

  int masukHour = 8;
  int masukMinute = 0;
  int keluarHour = 17;
  int keluarMinute = 0;

  @override
  void initState() {
    super.initState();
    loadAlarmData();
  }

  Future<void> loadAlarmData() async {
    final config = await AlarmService.getSavedConfig();
    setState(() {
      masukHour = config['masuk_hour'];
      masukMinute = config['masuk_minute'];
      isMasukActive = config['masuk_active'];

      keluarHour = config['keluar_hour'];
      keluarMinute = config['keluar_minute'];
      isKeluarActive = config['keluar_active'];
    });
  }

  String _formatWaktu(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pilihWaktu(String type, int currentHour, int currentMinute) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      helpText: type == 'masuk' ? 'PILIH JAM ABSEN MASUK' : 'PILIH JAM ABSEN KELUAR',
    );

    if (picked != null) {
      await AlarmService.setPengingat(
        type: type,
        hour: picked.hour,
        minute: picked.minute,
      );
      loadAlarmData();
      _showSnackbar('Pengingat $type berhasil diatur ke ${_formatWaktu(picked.hour, picked.minute)}');
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Pengingat & Alarm Absen',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAlarmCard(
            title: 'Pengingat Absen Masuk',
            subtitle: 'Mengingatkan sebelum jam masuk kerja dimulai.',
            icon: Icons.login_rounded,
            iconColor: const Color(0xFF3498DB),
            time: _formatWaktu(masukHour, masukMinute),
            isActive: isMasukActive,
            onTimeTap: () => _pilihWaktu('masuk', masukHour, masukMinute),
            onSwitchChanged: (val) async {
              if (val) {
                await AlarmService.setPengingat(type: 'masuk', hour: masukHour, minute: masukMinute);
              } else {
                await AlarmService.batalkanPengingat('masuk');
              }
              loadAlarmData();
            },
          ),
          const SizedBox(height: 16),
          _buildAlarmCard(
            title: 'Pengingat Absen Keluar',
            subtitle: 'Mengingatkan waktu presensi keluar saat jam operasional berakhir.',
            icon: Icons.logout_rounded,
            iconColor: Colors.orange,
            time: _formatWaktu(keluarHour, keluarMinute),
            isActive: isKeluarActive,
            onTimeTap: () => _pilihWaktu('keluar', keluarHour, keluarMinute),
            onSwitchChanged: (val) async {
              if (val) {
                await AlarmService.setPengingat(type: 'keluar', hour: keluarHour, minute: keluarMinute);
              } else {
                await AlarmService.batalkanPengingat('keluar');
              }
              loadAlarmData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String time,
    required bool isActive,
    required VoidCallback onTimeTap,
    required ValueChanged<bool> onSwitchChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: isActive,
                onChanged: onSwitchChanged,
                activeColor: const Color(0xFF3498DB),
              )
            ],
          ),
          const Divider(height: 24, color: Color(0xFFE2E8F0)),
          InkWell(
            onTap: onTimeTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Waktu Alarm',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  Row(
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.bold, 
                          color: isActive ? Colors.black87 : Colors.grey
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}