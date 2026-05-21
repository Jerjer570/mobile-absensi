import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart = DateTime.now().subtract(const Duration(days: 7));
  DateTime? _rangeEnd = DateTime.now();
  bool _isLoading = true;
  List<Map<String, dynamic>> _attendanceHistory = [];

  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
  }

  Future<void> _loadAttendanceHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString('attendance_history');
      if (savedData != null) {
        final List decoded = jsonDecode(savedData);
        setState(() {
          _attendanceHistory = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          _attendanceHistory = _attendanceHistory.reversed.toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _attendanceHistory = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatCardDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    List<String> days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return "${date.day.toString().padLeft(2, '0')} ${days[date.weekday - 1]}";
  }

  List<Map<String, dynamic>> get _filteredHistory {
    return _attendanceHistory.where((item) {
      DateTime itemDate = DateTime.parse(item['date']);
      if (_rangeStart != null && _rangeEnd != null) {
        return itemDate.isAfter(_rangeStart!.subtract(const Duration(days: 1))) &&
            itemDate.isBefore(_rangeEnd!.add(const Duration(days: 1)));
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Kehadiran',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Icon(Icons.more_vert, color: Colors.red),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
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
                            _rangeStart = start;
                            _rangeEnd = end;
                            _focusedDay = focusedDay;
                          });
                        },
                        // FIX: hapus const di HeaderStyle dan CalendarStyle
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        calendarStyle: CalendarStyle(
                          rangeHighlightColor: const Color(0xFFFFCDD2),
                          rangeStartDecoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          rangeEndDecoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: CircularProgressIndicator(),
                      ),
                    if (!_isLoading && _filteredHistory.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(40),
                        child: const Column(
                          children: [
                            Icon(Icons.history, size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text("Belum ada riwayat absensi",
                                style: TextStyle(fontFamily: 'Inter', color: Colors.grey)),
                          ],
                        ),
                      ),
                    if (!_isLoading)
                      ..._filteredHistory.map((item) {
                        return _buildHistoryItem(
                          _formatCardDate(item['date']),
                          item['check_in'] ?? '--:--',
                          item['check_out'] ?? '--:--',
                          item['total_hours'] ?? '--:--',
                        );
                      }).toList(),
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

  Widget _buildHistoryItem(String date, String masuk, String keluar, String total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFC47373),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              date,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: _buildTimeCol('Masuk', masuk)),
          Expanded(child: _buildTimeCol('Keluar', keluar)),
          Expanded(child: _buildTimeCol('Total Jam', total)),
        ],
      ),
    );
  }

  Widget _buildTimeCol(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(time,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B))),
        Text(label,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}