import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'services/api_constants.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() =>
      _NotificationPageState();
}

class _NotificationPageState
    extends State<NotificationPage> {

  // =========================================================
  // STATE
  // =========================================================

  bool isMasukOn = false;
  bool isPulangOn = false;

  bool _isLoading = false;

  String mainTime = "12.00";

  // =========================================================
  // UPDATE NOTIFICATION API
  // =========================================================

  Future<void> _toggleNotification(
    String type,
    bool value,
  ) async {

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {

      // =========================
      // SHARED PREFERENCES
      // =========================

      final prefs =
      await SharedPreferences.getInstance();

      final token =
      prefs.getString('auth_token');

      // =========================
      // VALIDASI TOKEN
      // =========================

      if (token == null) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Token tidak ditemukan",
            ),
          ),
        );

        return;
      }

      // =========================
      // REQUEST API
      // =========================

      final response = await http.post(

        Uri.parse(
          ApiConstants.updateNotification,
        ),

        headers: {

          'Authorization': 'Bearer $token',

          'Accept': 'application/json',

        },

        body: {

          'type': type,

          'status': value ? '1' : '0',

        },
      );

      // =========================
      // DEBUG
      // =========================

      print("STATUS: ${response.statusCode}");

      print("BODY: ${response.body}");

      final data =
      jsonDecode(response.body);

      // =========================
      // SUCCESS
      // =========================

      if (response.statusCode == 200) {

        setState(() {

          if (type == 'masuk') {

            isMasukOn = value;

          } else {

            isPulangOn = value;

          }

        });

        if (mounted) {

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ??
                    "Berhasil update notifikasi",
              ),
            ),
          );

        }

      } else {

        // =========================
        // FAILED
        // =========================

        if (mounted) {

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ??
                    "Gagal update notifikasi",
              ),
            ),
          );

        }

      }

    } catch (e) {

      print("ERROR NOTIFICATION: $e");

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Terjadi kesalahan",
            ),
          ),
        );

      }

    } finally {

      if (mounted) {

        setState(() {
          _isLoading = false;
        });

      }

    }
  }

  // =========================================================
  // POPUP EDIT ALARM
  // =========================================================

  void _showEditAlarmPopup() {

    bool isMasuk = true;

    Duration currentDuration =
    const Duration(
      hours: 12,
      minutes: 0,
    );

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      backgroundColor:
      const Color(0xFF1C1C1E),

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),

      builder: (context) {

        return StatefulBuilder(

          builder: (
              context,
              setPopupState,
              ) {

            return Container(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),

              height:
              MediaQuery.of(context)
                  .size
                  .height *
                  0.55,

              child: Column(

                children: [

                  // =====================
                  // HANDLE
                  // =====================

                  Container(
                    width: 40,
                    height: 5,

                    margin:
                    const EdgeInsets.only(
                      bottom: 15,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white24,

                      borderRadius:
                      BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),

                  // =====================
                  // HEADER
                  // =====================

                  Row(

                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                    children: [

                      TextButton(

                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },

                        child: const Text(
                          "Batalkan",

                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 17,
                          ),
                        ),
                      ),

                      const Text(

                        "Edit Alarm",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      TextButton(

                        onPressed: () {

                          setState(() {

                            String hours =
                            currentDuration
                                .inHours
                                .toString()
                                .padLeft(
                                2,
                                '0');

                            String minutes =
                            (currentDuration
                                .inMinutes %
                                60)
                                .toString()
                                .padLeft(
                                2,
                                '0');

                            mainTime =
                            "$hours.$minutes";

                          });

                          Navigator.pop(
                            context,
                          );
                        },

                        child: const Text(

                          "Selesai",

                          style: TextStyle(
                            color:
                            Color(
                              0xFF30D158,
                            ),
                            fontSize: 17,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // =====================
                  // TAB
                  // =====================

                  Container(

                    height: 40,

                    padding:
                    const EdgeInsets.all(
                      2,
                    ),

                    decoration: BoxDecoration(
                      color:
                      const Color(
                        0xFF3A3A3C,
                      ),

                      borderRadius:
                      BorderRadius.circular(
                        10,
                      ),
                    ),

                    child: Row(

                      children: [

                        // =================
                        // MASUK
                        // =================

                        Expanded(

                          child: GestureDetector(

                            onTap: () {

                              setPopupState(() {
                                isMasuk = true;
                              });

                            },

                            child: Container(

                              alignment:
                              Alignment.center,

                              decoration:
                              BoxDecoration(

                                color: isMasuk
                                    ? const Color(
                                  0xFF636366,
                                )
                                    : Colors
                                    .transparent,

                                borderRadius:
                                BorderRadius
                                    .circular(
                                  8,
                                ),
                              ),

                              child: Text(

                                "Masuk",

                                style: TextStyle(
                                  color: isMasuk
                                      ? Colors
                                      .white
                                      : Colors
                                      .grey,

                                  fontWeight:
                                  FontWeight
                                      .w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // =================
                        // DIVIDER
                        // =================

                        Container(
                          width: 1,
                          height: 20,
                          color: Colors.white
                              .withOpacity(
                            0.1,
                          ),
                        ),

                        // =================
                        // PULANG
                        // =================

                        Expanded(

                          child: GestureDetector(

                            onTap: () {

                              setPopupState(() {
                                isMasuk = false;
                              });

                            },

                            child: Container(

                              alignment:
                              Alignment.center,

                              decoration:
                              BoxDecoration(

                                color: !isMasuk
                                    ? const Color(
                                  0xFF636366,
                                )
                                    : Colors
                                    .transparent,

                                borderRadius:
                                BorderRadius
                                    .circular(
                                  8,
                                ),
                              ),

                              child: Text(

                                "Pulang",

                                style: TextStyle(
                                  color: !isMasuk
                                      ? Colors
                                      .white
                                      : Colors
                                      .grey,

                                  fontWeight:
                                  FontWeight
                                      .w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =====================
                  // TIMER PICKER
                  // =====================

                  Expanded(

                    child: Container(

                      decoration: BoxDecoration(

                        color:
                        const Color(
                          0xFF2C2C2E,
                        ),

                        borderRadius:
                        BorderRadius.circular(
                          20,
                        ),
                      ),

                      child: CupertinoTheme(

                        data:
                        const CupertinoThemeData(
                          brightness:
                          Brightness.dark,
                        ),

                        child:
                        CupertinoTimerPicker(

                          mode:
                          CupertinoTimerPickerMode
                              .hm,

                          initialTimerDuration:
                          currentDuration,

                          onTimerDurationChanged:
                              (
                              Duration
                              newDuration,
                              ) {

                            currentDuration =
                                newDuration;

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

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      // =====================================================
      // APPBAR
      // =====================================================

      appBar: AppBar(

        backgroundColor: Colors.white,

        elevation: 0,

        leading: IconButton(

          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(

          'Notifikasi',

          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: Padding(

        padding:
        const EdgeInsets.symmetric(
          horizontal: 24.0,
        ),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 20),

            // =================================================
            // SETTING JAM
            // =================================================

            _buildSectionTitle(
              "Setting Jam",
            ),

            _buildSettingJamCard(),

            const SizedBox(height: 30),

            // =================================================
            // INGATKAN ABSEN
            // =================================================

            _buildSectionTitle(
              "Ingatkan Absen",
            ),

            _buildNotificationCard(),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // TITLE
  // =========================================================

  Widget _buildSectionTitle(
      String title,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(
        left: 4,
        bottom: 12,
      ),

      child: Text(

        title,

        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // =========================================================
  // CARD JAM
  // =========================================================

  Widget _buildSettingJamCard() {

    return Container(

      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),

      decoration: BoxDecoration(

        color:
        const Color(0xFFF5F6FA),

        borderRadius:
        BorderRadius.circular(15),
      ),

      child: Row(

        children: [

          const Icon(
            Icons.wb_sunny,
            color: Colors.orange,
            size: 24,
          ),

          const SizedBox(width: 15),

          Text(

            mainTime,

            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          IconButton(

            onPressed: _showEditAlarmPopup,

            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF20295F),
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CARD NOTIFICATION
  // =========================================================

  Widget _buildNotificationCard() {

    return Container(

      decoration: BoxDecoration(

        color:
        const Color(0xFFF5F6FA),

        borderRadius:
        BorderRadius.circular(15),
      ),

      child: Column(

        children: [

          // =========================
          // MASUK
          // =========================

          _buildSwitchTile(

            icon:
            Icons.wb_sunny_rounded,

            iconColor:
            Colors.yellow.shade700,

            title: 'Masuk',

            value: isMasukOn,

            onChanged: _isLoading
                ? null
                : (val) {
              _toggleNotification(
                'masuk',
                val,
              );
            },
          ),

          Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: Colors.grey.shade300,
          ),

          // =========================
          // PULANG
          // =========================

          _buildSwitchTile(

            icon:
            Icons.wb_sunny_rounded,

            iconColor:
            Colors.orange.shade700,

            title: 'Pulang',

            value: isPulangOn,

            onChanged: _isLoading
                ? null
                : (val) {
              _toggleNotification(
                'pulang',
                val,
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SWITCH TILE
  // =========================================================

  Widget _buildSwitchTile({

    required IconData icon,

    required Color iconColor,

    required String title,

    required bool value,

    required ValueChanged<bool>? onChanged,

  }) {

    return ListTile(

      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),

      leading: Icon(
        icon,
        color: iconColor,
        size: 28,
      ),

      title: Text(

        title,

        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),

      trailing: Switch(

        value: value,

        onChanged: onChanged,

        thumbColor:
        WidgetStateProperty.resolveWith<Color>(
              (states) {

            return states.contains(
              WidgetState.selected,
            )
                ? Colors.black
                : Colors.white;
          },
        ),

        trackColor:
        WidgetStateProperty.resolveWith<Color>(
              (states) {

            return states.contains(
              WidgetState.selected,
            )
                ? Colors.grey.shade400
                : Colors.grey.shade300;
          },
        ),
      ),
    );
  }
}