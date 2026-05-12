import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'services/api_constants.dart';
import 'services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Edit_Profil.dart';
import 'services/attendance_service.dart';
import 'Notification_Page.dart';
import 'dart:convert';
import 'UserSettingPage.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool _isLoading = false;
  bool _isPunchedIn = false;

  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  DateTime? _checkInTime;
  DateTime? _checkOutTime;

  String _userName = "User";
  String _userRole = "Staff";

  @override
  void initState() {
    super.initState();
    _fetchProfileData();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ================= API =================

  Future<void> _fetchProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/me"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['data'];

        setState(() {
          _userName = user['data_karyawan']?['nama_lengkap'] ?? "User";
          _userRole = user['role'] ?? "Staff";
        });
      }
    } catch (e) {
      debugPrint("Error profile: $e");
    }
  }

  Future<void> _handleAttendance() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final locResult = await LocationService.getCurrentLocation();

      if (!locResult['success']) {
        _showSnackBar(locResult['message'], Colors.red);
        return;
      }

      Position position = locResult['data'];

      final result = await AttendanceService.submitAttendance(
        isPunchIn: !_isPunchedIn,
        lat: position.latitude,
        lng: position.longitude,
      );

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
          _isPunchedIn ? "Berhasil Absen Masuk" : "Berhasil Absen Pulang",
          Colors.green,
        );
      } else {
        _showSnackBar(result['message'], Colors.red);
      }

    } catch (e) {
      _showSnackBar("Error sistem", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isPunchedIn ? "Konfirmasi Absen Pulang" : "Konfirmasi Absen Masuk"),
        content: const Text("Pastikan lokasi Anda sudah benar."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
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

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  String _formatTime(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String ampm = hour >= 12 ? 'PM' : 'AM';

    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;

    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $ampm";
  }

  String _formatDate(DateTime time) {
    List<String> months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    List<String> days = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];

    return "${months[time.month - 1]} ${time.day}, ${time.year} - ${days[time.weekday - 1]}";
  }

  String _calculateTotalHours() {
    if (_checkInTime == null || _checkOutTime == null) return "--:--";

    Duration diff = _checkOutTime!.difference(_checkInTime!);
    return "${diff.inHours.toString().padLeft(2, '0')}:${diff.inMinutes.remainder(60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_userName.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(_userRole,
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.edit, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(_formatTime(_currentTime),
                style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w300)),

            const SizedBox(height: 8),

            Text(_formatDate(_currentTime),
                style: const TextStyle(fontSize: 14, color: Colors.grey)),

            const SizedBox(height: 50),

            GestureDetector(
              onTap: _isLoading ? null : _showConfirmationDialog,
              child: Container(
                width: 160,
                height: 160,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isLoading ? Colors.grey.shade300 : const Color(0xFFF1F5F9),
                ),
                child: Text(
                  _isLoading
                      ? 'MEMPROSES...'
                      : (_isPunchedIn ? 'KELUAR' : 'MASUK'),
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('assets/images/masuk.png', _checkInTime != null ? _formatTime(_checkInTime!) : '--:--', 'Masuk'),
                  _buildStatItem('assets/images/keluar.png', _checkOutTime != null ? _formatTime(_checkOutTime!) : '--:--', 'Keluar'),
                  _buildStatItem('assets/images/totaljam.png', _calculateTotalHours(), 'Total Jam'),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String iconPath, String time, String label) {
    return Column(
      children: [
        Image.asset(iconPath, width: 32, height: 32),
        const SizedBox(height: 12),
        Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}