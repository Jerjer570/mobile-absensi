import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'services/attendance_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime  _focusedDay  = DateTime.now();
  DateTime? _rangeStart  = DateTime.now().subtract(const Duration(days: 30));
  DateTime? _rangeEnd    = DateTime.now();

  bool _isLoading = true;
  bool _isOffline = false;
  List<Map<String, dynamic>> _attendanceHistory = [];

  @override
  void initState() {
    super.initState();
    _loadFromServer();
  }

  // =========================================================
  // LOAD HISTORY DARI SERVER
  // =========================================================
  Future<void> _loadFromServer() async {
    setState(() { _isLoading = true; _isOffline = false; });
    try {
      final String awal  = _rangeStart != null ? _formatDate(_rangeStart!) : '';
      final String akhir = _rangeEnd   != null ? _formatDate(_rangeEnd!)   : '';

      final result = await AttendanceService.getAttendanceHistory(
        awal  : awal.isNotEmpty  ? awal  : null,
        akhir : akhir.isNotEmpty ? akhir : null,
      );

      if (result['success'] == true) {
        final List raw = result['data'] ?? [];
        setState(() {
          _attendanceHistory = raw
              .map((e) => _mapServerItem(Map<String, dynamic>.from(e)))
              .toList()
              .reversed
              .toList();
          _isOffline = result['offline'] == true;
        });
      } else {
        setState(() { _attendanceHistory = []; });
      }
    } catch (_) {
      setState(() { _isOffline = true; });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // =========================================================
  // MAPPING: data dari server → format yang dipakai UI
  // Server mengirim: absen_masuk, absen_keluar, total_waktu, tanggal, status
  // =========================================================
  Map<String, dynamic> _mapServerItem(Map<String, dynamic> item) {
    final masuk  = item['absen_masuk']  as String?;
    final keluar = item['absen_keluar'] as String?;

    return {
      'date'       : item['tanggal']  ?? '',
      'check_in'   : masuk  != null ? AttendanceService.formatTime24(masuk)  : '--:--',
      'check_out'  : keluar != null ? AttendanceService.formatTime24(keluar) : '--:--',
      'total_hours': item['total_waktu'] ?? '--:--',
      'status'     : item['status']   ?? 'hadir',
    };
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatCardDate(String dateString) {
    try {
      final date  = DateTime.parse(dateString);
      const days  = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
      return '${date.day.toString().padLeft(2, '0')}\n${days[date.weekday - 1]}';
    } catch (_) {
      return dateString;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir'   : return Colors.green;
      case 'izin'    : return Colors.blue;
      case 'sakit'   : return Colors.orange;
      case 'alpha'   : return Colors.red;
      default        : return Colors.grey;
    }
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
            // ─── HEADER ───
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Kehadiran',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 22,
                        fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.red),
                    onPressed: _loadFromServer,
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),

            // ─── BADGE OFFLINE ───
            if (_isOffline)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off, size: 14, color: Colors.orange),
                    SizedBox(width: 6),
                    Text('Mode offline — menampilkan data cache',
                        style: TextStyle(fontSize: 12, color: Colors.orange)),
                  ],
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // ─── KALENDER ───
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        rangeStartDay: _rangeStart,
                        rangeEndDay: _rangeEnd,
                        rangeSelectionMode: RangeSelectionMode.toggledOn,
                        onRangeSelected: (start, end, focusedDay) {
                          setState(() {
                            _rangeStart  = start;
                            _rangeEnd    = end;
                            _focusedDay  = focusedDay;
                          });
                          if (end != null) _loadFromServer(); // fetch ulang saat range selesai dipilih
                        },
                        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                        calendarStyle: const CalendarStyle(
                          rangeHighlightColor      : Color(0xFFFFCDD2),
                          rangeStartDecoration     : BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          rangeEndDecoration       : BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          todayDecoration          : BoxDecoration(color: Color(0xFFEF9A9A), shape: BoxShape.circle),
                          selectedDecoration       : BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── LOADING ───
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: CircularProgressIndicator(color: Colors.red),
                      ),

                    // ─── EMPTY ───
                    if (!_isLoading && _attendanceHistory.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(40),
                        child: const Column(
                          children: [
                            Icon(Icons.history, size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Belum ada riwayat absensi pada rentang tanggal ini',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'Inter', color: Colors.grey)),
                          ],
                        ),
                      ),

                    // ─── LIST HISTORY ───
                    if (!_isLoading)
                      ..._attendanceHistory.map((item) => _buildHistoryItem(item)),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final status = item['status'] as String? ?? 'hadir';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          // Kotak tanggal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFC47373), borderRadius: BorderRadius.circular(8)),
            child: Text(
              _formatCardDate(item['date'] ?? ''),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: _buildTimeCol('Masuk',    item['check_in']   ?? '--:--')),
          Expanded(child: _buildTimeCol('Keluar',   item['check_out']  ?? '--:--')),
          Expanded(child: _buildTimeCol('Total',    item['total_hours'] ?? '--:--')),
          // Badge status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _statusColor(status)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCol(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(time, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
