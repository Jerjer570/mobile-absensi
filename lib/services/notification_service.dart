import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_constants.dart';

class NotificationService {

  // =========================================================
  // API SERVICE
  // =========================================================

  static Future<bool> updateNotificationStatus(
      String type,
      bool isOn,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Cegah token null
      if (token == null) {
        print("Token tidak ditemukan");
        return false;
      }

      final response = await http.post(
        Uri.parse(ApiConstants.updateNotification),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'type': type,
          'status': isOn ? '1' : '0',
        },
      );

      // Debug response
      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Error NotificationService: $e");
      return false;
    }
  }

  // =========================================================
  // POPUP UI SERVICE
  // =========================================================

  static void showEditAlarmPopup(
    BuildContext context, {
    required Function(Duration) onTimeChanged,
  }) {
    // Variabel lokal popup
    bool isMasuk = true;

    Duration currentDuration = const Duration(
      hours: 12,
      minutes: 0,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              height: MediaQuery.of(context).size.height * 0.55,
              child: Column(
                children: [

                  // =========================
                  // HANDLE
                  // =========================

                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // =========================
                  // HEADER
                  // =========================

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [

                      // BATALKAN
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Batalkan",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 17,
                          ),
                        ),
                      ),

                      // TITLE
                      const Text(
                        "Edit Alarm",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // SELESAI
                      TextButton(
                        onPressed: () async {

                          // Kirim data ke callback UI
                          onTimeChanged(currentDuration);

                          // Contoh kirim ke API
                          bool success =
                          await updateNotificationStatus(
                            isMasuk ? 'masuk' : 'pulang',
                            true,
                          );

                          print("Update API Success: $success");

                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Selesai",
                          style: TextStyle(
                            color: Color(0xFF30D158),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // TAB MASUK / PULANG
                  // =========================

                  Container(
                    height: 40,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3A3C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [

                        // MASUK
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setPopupState(() {
                                isMasuk = true;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isMasuk
                                    ? const Color(0xFF636366)
                                    : Colors.transparent,
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Masuk",
                                style: TextStyle(
                                  color: isMasuk
                                      ? Colors.white
                                      : Colors.grey,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // PEMISAH
                        Container(
                          width: 1,
                          height: 20,
                          color: Colors.white.withOpacity(0.1),
                        ),

                        // PULANG
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setPopupState(() {
                                isMasuk = false;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: !isMasuk
                                    ? const Color(0xFF636366)
                                    : Colors.transparent,
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Pulang",
                                style: TextStyle(
                                  color: !isMasuk
                                      ? Colors.white
                                      : Colors.grey,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =========================
                  // TIME PICKER
                  // =========================

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: CupertinoTheme(
                        data: const CupertinoThemeData(
                          brightness: Brightness.dark,
                        ),
                        child: CupertinoTimerPicker(
                          mode: CupertinoTimerPickerMode.hm,
                          initialTimerDuration:
                          currentDuration,
                          onTimerDurationChanged:
                              (Duration newDuration) {
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