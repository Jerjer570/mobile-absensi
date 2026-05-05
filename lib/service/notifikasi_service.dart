import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static void showEditAlarmPopup(
    BuildContext context, {
    required Function(Duration) onTimeChanged, // Callback untuk mengirim data ke UI
  }) {
    // Variabel lokal untuk menyimpan status di dalam popup
    bool isMasuk = true;
    Duration currentDuration = const Duration(hours: 12, minutes: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1E), // Background gelap iOS Style
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        // StatefulBuilder agar UI di dalam popup bisa update (Tab Masuk/Pulang)
        return StatefulBuilder(
          builder: (context, setPopupState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              height: MediaQuery.of(context).size.height * 0.55,
              child: Column(
                children: [
                  // --- INDICATOR PINDAH (Android Handle) ---
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // --- HEADER (Batalkan, Judul, Selesai) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batalkan",
                            style: TextStyle(color: Colors.red, fontSize: 17)),
                      ),
                      const Text("Edit Alarm",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          // Kirim hasil akhir saat tombol Selesai ditekan
                          onTimeChanged(currentDuration);
                          Navigator.pop(context);
                        },
                        child: const Text("Selesai",
                            style: TextStyle(
                                color: Color(0xFF30D158),
                                fontSize: 17,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- SEGMENTED CONTROL (Masuk | Pulang) ---
                  Container(
                    height: 40,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3A3C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        // Tombol Masuk
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setPopupState(() => isMasuk = true),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isMasuk
                                    ? const Color(0xFF636366)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text("Masuk",
                                  style: TextStyle(
                                      color: isMasuk ? Colors.white : Colors.grey,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                        // Garis Pemisah
                        Container(
                            width: 1,
                            height: 20,
                            color: Colors.white.withOpacity(0.1)),
                        // Tombol Pulang
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setPopupState(() => isMasuk = false),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: !isMasuk
                                    ? const Color(0xFF636366)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text("Pulang",
                                  style: TextStyle(
                                      color: !isMasuk ? Colors.white : Colors.grey,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- BOX TIME PICKER ---
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: CupertinoTheme(
                        data: const CupertinoThemeData(
                          brightness: Brightness.dark,
                        ),
                        child: CupertinoTimerPicker(
                          mode: CupertinoTimerPickerMode.hm,
                          initialTimerDuration: currentDuration,
                          onTimerDurationChanged: (Duration newDuration) {
                            // Update variabel durasi lokal
                            currentDuration = newDuration;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }
}