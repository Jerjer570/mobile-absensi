import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import 'services/attendance_service.dart';
import 'services/location_service.dart';
import 'UserSettingPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ================= STATUS =================

  bool _isLoading = false;
  bool _isPunchedIn = false;

  // ================= TIMER =================

  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  // ================= ATTENDANCE =================

  DateTime? _checkInTime;
  DateTime? _checkOutTime;

  // ================= USER =================

  String _userName = "User";
  String _userRole = "Staff";

  @override
  void initState() {
    super.initState();

    _loadUserData();

    // REALTIME CLOCK
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // =========================================================
  // LOAD USER DATA LOCAL
  // =========================================================

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _userName = prefs.getString('user_name') ?? "HEY JHONE DOE";
      _userRole = prefs.getString('user_role') ?? "Office Boy";
    });
  }

  // =========================================================
  // HANDLE ATTENDANCE
  // =========================================================

  Future<void> _handleAttendance() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // ================= LOCATION =================

      final locResult = await LocationService.getCurrentLocation();

      if (!locResult['success']) {
        _showSnackBar(locResult['message'], Colors.red);
        return;
      }

      Position position = locResult['data'];

      // ================= ATTENDANCE SERVICE =================

      final result = await AttendanceService.submitAttendance(
        isPunchIn: !_isPunchedIn,
        lat: position.latitude,
        lng: position.longitude,
      );

      // ================= SUCCESS =================

      if (result['success']) {
        setState(() {
          _isPunchedIn = !_isPunchedIn;

          if (_isPunchedIn) {
            _checkInTime = DateTime.now();
            _checkOutTime = null;
          } else {
            _checkOutTime = DateTime.now();
          }
        });

        _showSnackBar(
          _isPunchedIn
              ? "Berhasil Absen Masuk"
              : "Berhasil Absen Pulang",
          Colors.green,
        );
      } else {
        _showSnackBar(result['message'], Colors.red);
      }
    } catch (e) {
      _showSnackBar("Terjadi kesalahan sistem", Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // =========================================================
  // CONFIRM DIALOG
  // =========================================================

  Future<void> _showConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _isPunchedIn
              ? "Konfirmasi Absen Pulang"
              : "Konfirmasi Absen Masuk",
        ),
        content: const Text(
          "Pastikan lokasi Anda sudah benar.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleAttendance();
            },
            child: const Text("Ya, Absen"),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SNACKBAR
  // =========================================================

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
      ),
    );
  }

  // =========================================================
  // FORMAT TIME
  // =========================================================

  String _formatTime(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;

    String ampm = hour >= 12 ? 'PM' : 'AM';

    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;

    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $ampm";
  }

  // =========================================================
  // FORMAT DATE
  // =========================================================

  String _formatDate(DateTime time) {
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];

    List<String> days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];

    return "${months[time.month - 1]} ${time.day}, ${time.year} - ${days[time.weekday - 1]}";
  }

  // =========================================================
  // TOTAL HOURS
  // =========================================================

  String _calculateTotalHours() {
    if (_checkInTime == null || _checkOutTime == null) {
      return "--:--";
    }

    Duration diff = _checkOutTime!.difference(_checkInTime!);

    return "${diff.inHours.toString().padLeft(2, '0')}:${diff.inMinutes.remainder(60).toString().padLeft(2, '0')}";
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      body: SafeArea(
        child: Column(
          children: [
            // =====================================================
            // HEADER PROFILE
            // =====================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserSettingPage(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=11',
                      ),
                    ),

                    const SizedBox(width: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),

                        Text(
                          _userRole,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    const Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =====================================================
            // CLOCK
            // =====================================================

            Text(
              _formatTime(_currentTime),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 56,
                fontWeight: FontWeight.w300,
                color: Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _formatDate(_currentTime),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 50),

            // =====================================================
            // ATTENDANCE BUTTON
            // =====================================================

            GestureDetector(
              onTap: _isLoading ? null : _showConfirmationDialog,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // OUTER SHADOW CIRCLE

                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),

                  // PROGRESS INDICATOR

                  if (_isPunchedIn)
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: 0.35,
                        strokeWidth: 6,
                        backgroundColor: Colors.transparent,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(
                          Colors.orange,
                        ),
                      ),
                    ),

                  // INNER BUTTON

                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isLoading
                          ? Colors.grey.shade300
                          : const Color(0xFFF1F5F9),
                      border: Border.all(
                        color: Colors.white,
                        width: 8,
                      ),
                    ),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/handclick.png',
                          width: 40,
                          height: 40,
                          color: Colors.red,
                          errorBuilder:
                              (context, error, stackTrace) {
                            return const Icon(
                              Icons.touch_app,
                              size: 40,
                              color: Colors.red,
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        Text(
                          _isLoading
                              ? "MEMPROSES..."
                              : (_isPunchedIn
                                  ? 'KELUAR'
                                  : 'MASUK'),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // =====================================================
            // STATUS BADGE
            // =====================================================

            if (_isPunchedIn)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.circle,
                        color: Colors.orange,
                        size: 10,
                      ),

                      SizedBox(width: 8),

                      Text(
                        'Minimum half day time reached',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // =====================================================
            // STATS
            // =====================================================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    'assets/images/masuk.png',
                    _checkInTime != null
                        ? _formatTime(_checkInTime!)
                        : '--:--',
                    'Masuk',
                  ),

                  _buildStatItem(
                    'assets/images/keluar.png',
                    _checkOutTime != null
                        ? _formatTime(_checkOutTime!)
                        : '--:--',
                    'Keluar',
                  ),

                  _buildStatItem(
                    'assets/images/totaljam.png',
                    _calculateTotalHours(),
                    'Total Jam',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // STAT ITEM
  // =========================================================

  Widget _buildStatItem(
    String iconPath,
    String time,
    String label,
  ) {
    return Column(
      children: [
        Image.asset(
          iconPath,
          width: 32,
          height: 32,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.access_time,
              color: Colors.red,
            );
          },
        ),

        const SizedBox(height: 12),

        Text(
          time,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}