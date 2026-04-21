import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: NotificationPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Variabel untuk menyimpan status switch
  bool isMasukOn = false;
  bool isPulangOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          // Gunakan Icons.arrow_back untuk gaya Android atau arrow_back_ios_new untuk iOS
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingatkan Absen',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  // Baris Masuk
                  _buildSwitchTile(
                    icon: Icons.wb_sunny_rounded,
                    iconColor: Colors.yellow.shade700,
                    title: 'Masuk',
                    value: isMasukOn,
                    onChanged: (val) {
                      setState(() {
                        isMasukOn = val;
                      });
                    },
                  ),
                  // Garis pemisah tipis (opsional)
                  Divider(height: 1, indent: 20, endIndent: 20, color: Colors.grey.shade300),
                  // Baris Pulang
                  _buildSwitchTile(
                    icon: Icons.wb_sunny_rounded,
                    iconColor: Colors.orange.shade700,
                    title: 'Pulang',
                    value: isPulangOn,
                    onChanged: (val) {
                      setState(() {
                        isPulangOn = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Fungsi Helper untuk membuat baris Switch ---
  // Ini adalah bagian yang hilang di kodingan Anda sebelumnya
  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: iconColor, size: 28),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
     trailing: Switch(
  value: value,
  onChanged: onChanged,
  // Cara baru menggunakan WidgetStateProperty
  thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
    if (states.contains(WidgetState.selected)) {
      return Colors.black; // Warna bulat saat ON
    }
    return Colors.white; // Warna bulat saat OFF
  }),
  trackColor: WidgetStateProperty.resolveWith<Color>((states) {
    if (states.contains(WidgetState.selected)) {
      return Colors.grey.shade400; // Warna jalur saat ON
    }
    return Colors.grey.shade300; // Warna jalur saat OFF
  }),
),
    );
  }
}