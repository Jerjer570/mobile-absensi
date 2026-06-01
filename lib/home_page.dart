import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
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
  bool _isLoading      = false;
  bool _isSyncing      = false;
  bool _isPunchedIn    = false;

  // ================= TIMER =================
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  // ================= ATTENDANCE =================
  String _checkInTime  = '--:--';
  String _checkOutTime = '--:--';
  String _totalHours   = '--:--';

  // ================= USER =================
  String _userName = 'username';
  String _userRole = 'Karyawan';
  int?   _userId;
  String _fotoProfile = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _syncTodayStatus();

    // Jam realtime
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // =========================================================
  // LOAD USER DATA dari SharedPreferences
  // =========================================================
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'username';
      _userRole = prefs.getString('user_role') ?? 'Karyawan';
      _userId   = prefs.getInt('user_id');
      _fotoProfile = prefs.getString('foto_profile') ?? '';
    });
  }

  // =========================================================
  // SINKRONISASI STATUS ABSENSI HARI INI DARI SERVER
  // =========================================================
  Future<void> _syncTodayStatus() async {
    setState(() => _isSyncing = true);
    try {
      final result = await AttendanceService.getTodayAttendance();

      if (result['success'] == true) {
        final todayData = result['data'];

        if (todayData != null) {
          // Ada record absensi hari ini
          final masuk  = todayData['absen_masuk']  as String?;
          final keluar = todayData['absen_keluar'] as String?;

          setState(() {
            _checkInTime  = masuk  != null ? AttendanceService.formatTime24(masuk)  : '--:--';
            _checkOutTime = keluar != null ? AttendanceService.formatTime24(keluar) : '--:--';

            // Sudah masuk tapi belum keluar → tombol tunjukkan KELUAR
            _isPunchedIn = (masuk != null && keluar == null);

            if (masuk != null && keluar != null) {
              _totalHours = AttendanceService.calcTotalHours(masuk, keluar);
            }
          });
        } else {
          setState(() {
            _isPunchedIn  = false;
            _checkInTime  = '--:--';
            _checkOutTime = '--:--';
            _totalHours   = '--:--';
          });
        }
      }
    } catch (_) {
      _loadFromLocalCache();
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _loadFromLocalCache() {
    SharedPreferences.getInstance().then((prefs) {
      final saved = prefs.getString('attendance_history');
      if (saved == null) return;
      final List history = jsonDecode(saved);
      final today = _todayString();
      final todayItems = history.where((e) => e['date'] == today).toList();
      if (todayItems.isEmpty) return;
      final last = todayItems.last;
      setState(() {
        _checkInTime  = last['check_in']   ?? '--:--';
        _checkOutTime = last['check_out']  ?? '--:--';
        _totalHours   = last['total_hours'] ?? '--:--';
        _isPunchedIn  = (_checkInTime != '--:--' && _checkOutTime == '--:--');
      });
    });
  }

  // =========================================================
  // HANDLE ABSENSI
  // =========================================================
  Future<void> _handleAttendance() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // Ambil lokasi GPS
      final locResult = await LocationService.getCurrentLocation();
      if (!locResult['success']) {
        _showSnackBar(locResult['message'] ?? 'Gagal mendapat lokasi', Colors.red);
        return;
      }

      Position position = locResult['data'];

      // Kirim absensi ke server
      final result = await AttendanceService.submitAttendance(
        isPunchIn : !_isPunchedIn,
        lat       : position.latitude,
        lng       : position.longitude,
      );

      if (result['success'] == true) {
        _showSnackBar(result['message'], Colors.green);
        await _syncTodayStatus();
      } else {
        _showSnackBar(result['message'] ?? 'Terjadi kesalahan', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan sistem', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // =========================================================
  // KONFIRMASI DIALOG
  // =========================================================
  Future<void> _showConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_isPunchedIn ? 'Konfirmasi Absen Pulang' : 'Konfirmasi Absen Masuk'),
        content: const Text('Pastikan Anda berada di lokasi kantor yang benar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _handleAttendance();
            },
            child: const Text('Ya, Absen', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SNACKBAR
  // =========================================================
  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // =========================================================
  // FORMAT HELPERS
  // =========================================================
  String _formatDate(DateTime time) {
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    const days   = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
    return '${days[time.weekday - 1]}, ${time.day} ${months[time.month - 1]} ${time.year}';
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
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
            // ─── HEADER PROFIL ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserSettingPage()),
                  );
                  _loadUserData(); // refresh nama setelah kembali dari edit profil
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: (_fotoProfile.isNotEmpty && _fotoProfile != '')
                          ? NetworkImage(_fotoProfile)
                          : null, 
                      child: (_fotoProfile.isEmpty || _fotoProfile == '')
                          ? const Icon(Icons.person, size: 24, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Inter', fontSize: 16,
                            fontWeight: FontWeight.bold, color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          _userRole,
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (_isSyncing)
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      const Icon(Icons.edit, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── JAM REALTIME ───
            Text(
              AttendanceService.formatTimeTo24(_currentTime),
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 56,
                fontWeight: FontWeight.w300, color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(_currentTime),
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 50),

            // ─── TOMBOL ABSENSI ───
            GestureDetector(
              onTap: (_isLoading || _isSyncing) ? null : _showConfirmationDialog,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220, height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, spreadRadius: 5)],
                    ),
                  ),

                  if (_isPunchedIn)
                    SizedBox(
                      width: 220, height: 220,
                      child: CircularProgressIndicator(
                        value: 0.65,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),

                  Container(
                    width: 160, height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (_isLoading || _isSyncing) ? Colors.grey.shade300 : const Color(0xFFF1F5F9),
                      border: Border.all(color: Colors.white, width: 8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 40,
                          color: (_isLoading || _isSyncing) ? Colors.grey : Colors.red,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isLoading
                              ? 'MEMPROSES...'
                              : (_isSyncing ? 'MEMUAT...' : (_isPunchedIn ? 'KELUAR' : 'MASUK')),
                          style: const TextStyle(
                            fontFamily: 'Inter', fontSize: 14,
                            fontWeight: FontWeight.bold, color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (_isPunchedIn)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.circle, color: Colors.orange, size: 10),
                      SizedBox(width: 8),
                      Text('Sedang bekerja — tekan untuk absen pulang',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.orange)),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // ─── STATISTIK ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(Icons.login,    _checkInTime,  'Masuk'),
                  _buildStatItem(Icons.logout,   _checkOutTime, 'Keluar'),
                  _buildStatItem(Icons.timer,    _totalHours,   'Total Jam'),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String time, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.red, size: 32),
        const SizedBox(height: 12),
        Text(time, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
