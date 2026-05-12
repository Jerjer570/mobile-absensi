import 'package:flutter/material.dart';
import 'services/attendance_service.dart'; // Import Service
import 'package:intl/intl.dart'; // Untuk format tanggal/waktu

class KoreksiAbsenPage extends StatefulWidget {
  const KoreksiAbsenPage({super.key});

  @override
  State<KoreksiAbsenPage> createState() => _KoreksiAbsenPageState();
}

class _KoreksiAbsenPageState extends State<KoreksiAbsenPage> {
  DateTime? _selectedDate;
  String? _jenisKoreksi;
  TimeOfDay? _waktuKoreksi;
  final TextEditingController _alasanController = TextEditingController();
  String? _uploadedFileName;
  bool _isSubmitting = false;

  // Mock Data Sistem (Simulasi dari Database)
  String _sysJamMasuk = "--:--";
  String _sysJamKeluar = "--:--";
  bool _hasData = false;

  final List<String> _alasanList = [
    "Lupa Absen Masuk",
    "Lupa Absen Keluar",
    "Gangguan Sistem / Jaringan",
    "Dinas Luar / Tugas Lapangan",
    "Perangkat Bermasalah"
  ];

  // LOGIC 1: Pilih Tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fetchSystemData(picked);
      });
    }
  }

  // LOGIC 2: Simulasi ambil data sistem (Nanti bisa diganti panggil API GET)
  void _fetchSystemData(DateTime date) {
    if (date.day % 2 == 0) {
      _hasData = true;
      _sysJamMasuk = "08:00 AM";
      _sysJamKeluar = "17:00 PM";
    } else {
      _hasData = false;
      _sysJamMasuk = "--:--";
      _sysJamKeluar = "--:--";
    }
    setState(() {});
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _waktuKoreksi = picked);
    }
  }

  // LOGIC 5: Submit ke Service -> API
  Future<void> _handleUpdateKoreksi() async {
    setState(() => _isSubmitting = true);

    final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final String formattedTime = "${_waktuKoreksi!.hour}:${_waktuKoreksi!.minute}";

    // MEMANGGIL SERVICE
    final result = await AttendanceService.submitKoreksi(
      tanggal: formattedDate,
      jenisKoreksi: _jenisKoreksi!,
      waktu: formattedTime,
      alasan: _alasanController.text,
      fileNama: _uploadedFileName,
    );

    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Koreksi Absen Berhasil Dikirim!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal mengirim koreksi'), backgroundColor: Colors.red),
      );
    }
  }

  bool _isFormValid() {
    if (_selectedDate == null || _jenisKoreksi == null || _waktuKoreksi == null) return false;
    if (_alasanController.text.length < 10) return false;
    if (_isUploadMandatory() && _uploadedFileName == null) return false;
    return true;
  }

  bool _isUploadMandatory() {
    return _jenisKoreksi == "Gangguan Sistem / Jaringan" || _jenisKoreksi == "Perangkat Bermasalah";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Koreksi Absen', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Tanggal', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedDate == null ? "Pilih Tanggal" : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                    const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Kartu Data Sistem
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade100)),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(color: Colors.blue.shade200, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                    child: const Text('Data saat ini (Sistem)', style: TextStyle(fontFamily: 'Inter', color: Colors.black54)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Jam Masuk : $_sysJamMasuk'),
                            Text(_hasData ? 'Tercatat' : 'Belum Absen', style: TextStyle(color: _hasData ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Jam Keluar : $_sysJamKeluar'),
                            Text(_hasData ? 'Tercatat' : 'Belum Absen', style: TextStyle(color: _hasData ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Jenis Koreksi', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Pilih Alasan'),
                  value: _jenisKoreksi,
                  items: _alasanList.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                  onChanged: (newValue) => setState(() => _jenisKoreksi = newValue),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Waktu Sebenarnya', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.blueAccent, size: 20),
                    const SizedBox(width: 16),
                    Text(_waktuKoreksi == null ? "00:00 AM" : _waktuKoreksi!.format(context)),
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
                hintText: 'Masukkan alasan...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // Unggah Bukti
            GestureDetector(
              onTap: () => setState(() => _uploadedFileName = "bukti_absen.jpg"),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blueAccent)),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, color: Colors.blue, size: 40),
                    const SizedBox(height: 8),
                    Text(_uploadedFileName ?? 'Unggah Bukti Dokumen', style: const TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: (_isFormValid() && !_isSubmitting) ? _handleUpdateKoreksi : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2854C6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSubmitting 
              ? const CircularProgressIndicator(color: Colors.white) 
              : const Text('SUBMIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}