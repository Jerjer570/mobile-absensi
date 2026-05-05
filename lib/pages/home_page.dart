import 'package:flutter/material.dart';
import 'dart:async'; // Untuk fungsi Timer real-time

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Waktu Real-time saat ini
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  // Status Absensi
  bool _isPunchedIn = false;
  DateTime? _checkInTime;
  DateTime? _checkOutTime;

  @override
  void initState() {
    super.initState();
    // Memperbarui jam setiap 1 detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Matikan timer jika keluar dari halaman
    super.dispose();
  }

  // Fungsi merapikan jam jadi format 09:15 AM
  String _formatTime(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String ampm = hour >= 12 ? 'PM' : 'AM';
    
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour; // Jam 12 siang/malam
    
    String hrStr = hour.toString().padLeft(2, '0');
    String minStr = minute.toString().padLeft(2, '0');
    return "$hrStr:$minStr $ampm";
  }

  // Fungsi merapikan tanggal bahasa Indonesia
  String _formatDate(DateTime time) {
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    List<String> days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    
    String month = months[time.month - 1];
    String dayName = days[time.weekday - 1];
    String day = time.day.toString().padLeft(2, '0');
    String year = time.year.toString();
    
    return "$month $day, $year - $dayName";
  }

  // Fungsi Hitung Total Jam (Format HH:MM)
  String _calculateTotalHours() {
    if (_checkInTime == null || _checkOutTime == null) return "--:--";
    Duration diff = _checkOutTime!.difference(_checkInTime!);
    int hours = diff.inHours;
    int minutes = diff.inMinutes.remainder(60);
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
  }

  // Fungsi saat tombol raksasa di tengah diklik
  void _handleAttendance() {
    setState(() {
      if (!_isPunchedIn) {
        // PROSES MASUK
        _isPunchedIn = true;
        _checkInTime = DateTime.now(); // Rekam jam masuk
        _checkOutTime = null; // Reset jam keluar kalau dia masuk lagi
      } else {
        // PROSES KELUAR
        _isPunchedIn = false;
        _checkOutTime = DateTime.now(); // Rekam jam keluar
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Latar abu-abu sangat terang
      
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER (PROFILE) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'), // Avatar dummy
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'HEY JHONE DOE',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      Text(
                        'Office Boy',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.red),
                    onPressed: () {}, // Logika refresh jika dibutuhkan
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- REALTIME JAM & TANGGAL ---
            Text(
              _formatTime(_currentTime),
              style: const TextStyle(fontFamily: 'Inter', fontSize: 56, fontWeight: FontWeight.w300, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(_currentTime),
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 50),

            // --- TOMBOL ABSENSI (MASUK / KELUAR) ---
            GestureDetector(
              onTap: _handleAttendance,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Lingkaran bayangan luar
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, spreadRadius: 5),
                      ],
                    ),
                  ),
                  
                  // Indikator Progress Kuning (Muncul hanya jika sudah MASUK)
                  if (_isPunchedIn)
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: 0.35, // Simulasi progress (nanti bisa dihubungkan ke perhitungan jam)
                        strokeWidth: 6,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),

                  // Lingkaran Dalam
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF1F5F9),
                      border: Border.all(color: Colors.white, width: 8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/handclick.png', width: 40, height: 40, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          _isPunchedIn ? 'KELUAR' : 'MASUK', // Berubah otomatis sesuai desain perbaikanmu
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Label "Minimum half day" (Opsional, muncul kalau sudah masuk)
            if (_isPunchedIn)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.circle, color: Colors.orange, size: 10),
                      SizedBox(width: 8),
                      Text('Minimum half day time reached', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // --- REKAP HISTORY HARIAN ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('assets/images/masuk.png', _checkInTime != null ? _formatTime(_checkInTime!) : '--:--', 'Masuk'),
                  _buildStatItem('assets/images/keluar.png', _checkOutTime != null ? _formatTime(_checkOutTime!) : '--:--', 'Keluar'),
                  _buildStatItem('assets/images/totaljam.png', _calculateTotalHours(), 'Total Jam'),
                ],
              ),
            ),

            const SizedBox(height: 100), // Spasi kosong agar tidak tertutup navigasi baru
            
          ],
        ),
      ),
    );
  }

  // Widget Bantuan untuk merakit 3 kolom bawah
  Widget _buildStatItem(String iconPath, String time, String label) {
    return Column(
      children: [
        Image.asset(iconPath, width: 32, height: 32, errorBuilder: (context, error, stackTrace) => const Icon(Icons.access_time, color: Colors.red)),
        const SizedBox(height: 12),
        Text(time, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}