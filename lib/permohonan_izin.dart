import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'services/attendance_service.dart';

class PermohonanIzinPage extends StatefulWidget {
  const PermohonanIzinPage({super.key});

  @override
  State<PermohonanIzinPage> createState() => _PermohonanIzinPageState();
}

class _PermohonanIzinPageState extends State<PermohonanIzinPage> {
  String? _jenisIzin;
  final List<DateTime> _selectedDates = [];
  final TextEditingController _alasanController = TextEditingController();
  bool _isLoading = false;

  final List<String> _izinList = [
    'Izin-Sakit',
    'Izin-Cuti',
    'Izin-Lainnya',
  ];

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  // =========================================================
  // SUBMIT IZIN
  // =========================================================
  Future<void> _handleSubmitIzin() async {
    if (!_isFormValid()) return;
    setState(() => _isLoading = true);

    final List<String> formattedDates = _selectedDates
        .map((d) => DateFormat('yyyy-MM-dd').format(d))
        .toList();

    final result = await AttendanceService.submitIzin(
      jenisIzin    : _jenisIzin!,
      tanggalIzin  : formattedDates,
      alasan       : _alasanController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Izin berhasil diajukan!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal mengajukan izin'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // =========================================================
  // MULTI DATE PICKER
  // =========================================================
  Future<void> _showMultiDatePicker() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Pilih Tanggal Izin',
                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18)),
              content: SizedBox(
                width: double.maxFinite,
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime(DateTime.now().year + 1),
                  focusedDay: _selectedDates.isNotEmpty ? _selectedDates.last : DateTime.now(),
                  selectedDayPredicate: (day) =>
                      _selectedDates.any((d) => isSameDay(d, day)),
                  onDaySelected: (selectedDay, focusedDay) {
                    setStateDialog(() {
                      if (_selectedDates.any((d) => isSameDay(d, selectedDay))) {
                        _selectedDates.removeWhere((d) => isSameDay(d, selectedDay));
                      } else {
                        _selectedDates.add(selectedDay);
                      }
                    });
                    setState(() {});
                  },
                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(color: Color(0xFF2854C6), shape: BoxShape.circle),
                    todayDecoration    : BoxDecoration(color: Colors.blueGrey, shape: BoxShape.circle),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _selectedDates.sort((a, b) => a.compareTo(b));
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text('SIMPAN',
                      style: TextStyle(color: Color(0xFF2854C6), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getFormattedDates() {
    if (_selectedDates.isEmpty) return 'Pilih Tanggal Izin';
    _selectedDates.sort((a, b) => a.compareTo(b));
    return _selectedDates.map((d) => DateFormat('dd/MM').format(d)).join(', ');
  }

  bool _isFormValid() {
    return _jenisIzin != null &&
        _selectedDates.isNotEmpty &&
        _alasanController.text.trim().length >= 5;
  }

  // =========================================================
  // UI
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Pengajuan Izin',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pengajuan izin akan diproses oleh admin. Harap isi data dengan benar.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Jenis Izin
            const Text('Jenis Izin *', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Pilih jenis izin'),
                  value: _jenisIzin,
                  items: _izinList
                      .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
                      .toList(),
                  onChanged: _isLoading ? null : (v) => setState(() => _jenisIzin = v),
                ),
              ),
            ),

            if (_jenisIzin != null) ...[
              const SizedBox(height: 8),
              Text('Tambahkan keterangan alasan dengan jelas serta bukti foto sebagai pendukung',
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 11, fontStyle: FontStyle.italic)),
            ],

            const SizedBox(height: 20),

            // Tanggal Izin
            const Text('Tanggal Izin *', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _isLoading ? null : _showMultiDatePicker,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _getFormattedDates(),
                        style: TextStyle(color: _selectedDates.isEmpty ? Colors.grey.shade600 : Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.calendar_month, color: Colors.blueGrey, size: 24),
                  ],
                ),
              ),
            ),

            if (_selectedDates.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '${_selectedDates.length} hari dipilih ',
                style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500),
              ),
            ],

            const SizedBox(height: 20),

            // Alasan
            const Text('Alasan Lengkap *', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _alasanController,
              readOnly: _isLoading,
              onChanged: (_) => setState(() {}),
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tulis alasan izin secara lengkap dan jelas (min. 5 karakter)...',
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                counterText: '${_alasanController.text.length} karakter',
              ),
            ),

            const SizedBox(height: 32),

            // Tombol Submit
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: (_isFormValid() && !_isLoading) ? _handleSubmitIzin : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2854C6),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('KIRIM PENGAJUAN IZIN',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),

            const SizedBox(height: 16),

            // Syarat valid
            if (!_isFormValid())
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lengkapi data berikut:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange)),
                    const SizedBox(height: 4),
                    if (_jenisIzin == null)
                      const Text('• Pilih jenis izin', style: TextStyle(fontSize: 12, color: Colors.orange)),
                    if (_selectedDates.isEmpty)
                      const Text('• Pilih minimal satu tanggal', style: TextStyle(fontSize: 12, color: Colors.orange)),
                    if (_alasanController.text.trim().length < 5)
                      const Text('• Tulis alasan minimal 5 karakter', style: TextStyle(fontSize: 12, color: Colors.orange)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
