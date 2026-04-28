import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Dibutuhkan untuk pemilih waktu (wheel)

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  // Fungsi untuk menampilkan Pop Up Edit Alarm
  void _showEditAlarmModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2C2C2C), // Background gelap sesuai gambar
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder( // Agar state di dalam modal bisa berubah (Masuk/Pulang)
          builder: (context, setModalState) {
            bool isMasuk = true; // State contoh untuk tab

            return Container(
              height: 400,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // --- HEADER: Batalkan, Edit Alarm, Selesai ---
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

                  // --- TAB: Masuk | Pulang ---
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D3D3D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5A5A5A), // Warna tab terpilih
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "Masuk",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              "Pulang",
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- TIME PICKER (WHEEL STYLE) ---
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D3D3D),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: CupertinoTheme(
                        data: const CupertinoThemeData(
                          brightness: Brightness.dark, // Membuat teks wheel jadi putih
                        ),
                        child: CupertinoTimerPicker(
                          mode: CupertinoTimerPickerMode.hm, // Jam dan Menit saja
                          initialTimerDuration: const Duration(hours: 8, minutes: 0),
                          onTimerDurationChanged: (Duration newDuration) {
                            // Logika saat waktu diubah
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showEditAlarmModal(context),
          child: const Text("Klik untuk Edit Alarm"),
        ),
      ),
    );
  }
}