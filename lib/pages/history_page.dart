import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override                                       
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime _focusedDay = DateTime.now();
  // Default range: 7 hari yang lalu sampai hari ini
  DateTime? _rangeStart = DateTime.now().subtract(const Duration(days: 7));
  DateTime? _rangeEnd = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Riwayat Kehadiran', style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  Image.asset('assets/images/Titik_3.png', width: 24, height: 24, color: Colors.red),
                ],
              ),
            ),

            // CALENDAR CARD
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
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
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
                        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                        calendarStyle: const CalendarStyle(
                          rangeHighlightColor: Color(0xFFFFCDD2), // Merah muda transparan
                          rangeStartDecoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          rangeEndDecoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // DUMMY LIST HISTORY
                    _buildHistoryItem("06 TUE", "09:08 AM", "06:05 PM", "08:13"),
                    _buildHistoryItem("07 WED", "09:10 AM", "06:00 PM", "08:50"),
                    _buildHistoryItem("08 THU", "08:55 AM", "06:15 PM", "09:20"),
                    const SizedBox(height: 100), // Spasi untuk Bottom Nav Bar
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
            decoration: BoxDecoration(color: const Color(0xFFC47373), borderRadius: BorderRadius.circular(8)),
            child: Text(date, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        Text(time, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}