import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Penting untuk Wheel Time Picker

void main() {
  runApp(const MaterialApp(
    home: NotifikasiPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  
  // 1. FUNGSI UNTUK MEMUNCULKAN POP UP (PENGHUBUNG)
  void _showEditAlarmPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2C2C2C), // Background gelap sesuai gambar isi
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5, // Tinggi 50% layar
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // --- HEADER POP UP ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Batalkan",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                  const Text(
                    "Edit Alarm",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Selesai",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // --- TAB MASUK | PULANG ---
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3D3D3D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5A5A5A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text("Masuk", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text("Pulang", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // --- WHEEL TIME PICKER ---
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    brightness: Brightness.dark,
                  ),
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    onTimerDurationChanged: (Duration newDuration) {},
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text("Setting Jam", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            
            // --- KOTAK SETTING JAM ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wb_sunny, color: Colors.yellow, size: 28),
                  const SizedBox(width: 15),
                  const Text("12.00", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  
                  // 2. MENGHUBUNGKAN TOMBOL PLUS KE POP UP
                  IconButton(
                    onPressed: () => _showEditAlarmPopup(context), // <--- INI PENGHUBUNGNYA
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF20295F), size: 30),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text("Ingatkan Absen", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildAbsenRow("07.00", Colors.yellow),
                  const Divider(height: 30),
                  _buildAbsenRow("Pulang", Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbsenRow(String label, Color color) {
    return Row(
      children: [
        Icon(Icons.wb_sunny, color: color, size: 28),
        const SizedBox(width: 15),
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const Spacer(),
        const Icon(Icons.toggle_off_outlined, size: 38, color: Colors.black),
      ],
    );
  }
}