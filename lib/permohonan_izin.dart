import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class PermohonanIzinPage extends StatefulWidget {
  const PermohonanIzinPage({super.key});

  @override
  State<PermohonanIzinPage> createState() => _PermohonanIzinPageState();
}

class _PermohonanIzinPageState extends State<PermohonanIzinPage> {
  String? _jenisIzin;
  List<DateTime> _selectedDates = []; 
  String? _uploadedFileName;
  final TextEditingController _alasanController = TextEditingController();

  final List<String> _izinList = [
    "Izin Sakit",
    "Izin Alasan Penting",
    "Izin Menikah",
    "Izin Melahirkan"
  ];

  String _getDokumenHint() {
    switch (_jenisIzin) {
      case "Izin Sakit": return "Wajib upload Surat Keterangan Dokter";
      case "Izin Alasan Penting": return "Upload bukti medis/kepolisian/kelurahan";
      case "Izin Menikah": return "Upload foto undangan";
      case "Izin Melahirkan": return "Upload surat keterangan HPL bidan/dokter";
      default: return "Hanya mendukung file .jpg, .png, .pdf";
    }
  }

  Future<void> _showMultiDatePicker() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Pilih Tanggal Izin", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18)),
              content: SizedBox(
                width: double.maxFinite,
                child: TableCalendar(
                  firstDay: DateTime.now(), 
                  lastDay: DateTime(DateTime.now().year + 1),
                  focusedDay: _selectedDates.isNotEmpty ? _selectedDates.last : DateTime.now(),
                  selectedDayPredicate: (day) {
                    return _selectedDates.any((selectedDate) => isSameDay(selectedDate, day));
                  },
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
                    todayDecoration: BoxDecoration(color: Colors.blueGrey, shape: BoxShape.circle),
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
                  child: const Text("SIMPAN", style: TextStyle(color: Color(0xFF2854C6), fontWeight: FontWeight.bold)),
                )
              ],
            );
          },
        );
      },
    );
  }

  String _getFormattedDates() {
    if (_selectedDates.isEmpty) return "Pilih Tanggal Izin";
    List<String> dateStrings = _selectedDates.map((d) => "${d.day}/${d.month}").toList();
    return dateStrings.join(", ");
  }

  bool _isFormValid() {
    return _jenisIzin != null && 
           _selectedDates.isNotEmpty && 
           _alasanController.text.length >= 5 && 
           _uploadedFileName != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Pengajuan Izin', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Jenis Izin', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Pilih jenis Izin'),
                  value: _jenisIzin,
                  items: _izinList.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                  onChanged: (newValue) => setState(() => _jenisIzin = newValue),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Tanggal Izin', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showMultiDatePicker,
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
                    // --- INI BAGIAN YANG SUDAH DIPERBAIKI ---
                    const Icon(Icons.calendar_month, color: Colors.blueGrey, size: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Alasan Lengkap', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _alasanController,
              onChanged: (value) => setState(() {}), 
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tulis lengkap alasan izin...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Unggah Media', style: TextStyle(fontWeight: FontWeight.bold)),
                      Icon(Icons.close, size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Tambahkan dokumen Anda di sini', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () => setState(() => _uploadedFileName = "Surat_Izin_$_jenisIzin.jpg"),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        border: Border.all(color: Colors.blue.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.cloud_upload_outlined, color: Colors.blue, size: 32),
                          const SizedBox(height: 8),
                          const Text('Tarik file Anda atau telusuri', style: TextStyle(color: Colors.blue, fontSize: 12)),
                          const SizedBox(height: 4),
                          const Text('Ukuran maksimal 10 MB', style: TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_getDokumenHint(), style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontStyle: FontStyle.italic)),

                  const SizedBox(height: 20),
                  
                  if (_uploadedFileName != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(4)),
                            child: const Text('JPG', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_uploadedFileName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                const Text('500kb', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(value: 1.0, backgroundColor: Colors.grey.shade200, color: Colors.blue),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => setState(() => _uploadedFileName = null),
                            child: const Icon(Icons.cancel_outlined, color: Colors.grey, size: 20),
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isFormValid() ? () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin Berhasil Diajukan!'), backgroundColor: Colors.green));
                  Navigator.pop(context);
                } : null, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2854C6),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('SUBMIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}