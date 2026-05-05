import 'package:flutter/material.dart';

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

  // LOGIC 1: Pilih Tanggal (Maks mundur 30 hari, masa depan di-disable)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 30)), // Maks mundur 30 hari
      lastDate: now, // Disable future dates
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fetchSystemData(picked); // Panggil API Simulasi
      });
    }
  }

  // LOGIC 2: Kartu Data Sistem Dinamis
  void _fetchSystemData(DateTime date) {
    // Simulasi: Jika tanggal genap ada data, ganjil kosong
    if (date.day % 2 == 0) {
      _hasData = true;
      _sysJamMasuk = "08:00 AM";
      _sysJamKeluar = "17:00 PM";
    } else {
      _hasData = false;
      _sysJamMasuk = "--:--";
      _sysJamKeluar = "--:--";
    }
  }

  // Pilih Waktu
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _waktuKoreksi = picked);
    }
  }

  // LOGIC 3: Validasi Waktu Khusus "Lupa Absen Masuk"
  String? _getTimeValidationError() {
    if (_jenisKoreksi == "Lupa Absen Masuk" && _waktuKoreksi != null && _hasData && _sysJamKeluar != "--:--") {
      double sysOut = 17.0; // Anggap 17:00 PM
      double inputTime = _waktuKoreksi!.hour + (_waktuKoreksi!.minute / 60.0);
      
      if (inputTime > sysOut) {
        return "Jam masuk tidak boleh lebih dari jam keluar sistem!";
      }
    }
    return null;
  }

  // LOGIC 4: Wajib Upload File
  bool _isUploadMandatory() {
    return _jenisKoreksi == "Gangguan Sistem / Jaringan" || _jenisKoreksi == "Perangkat Bermasalah";
  }

  // LOGIC 5: Validasi Tombol Submit
  bool _isFormValid() {
    if (_selectedDate == null || _jenisKoreksi == null || _waktuKoreksi == null) return false;
    if (_alasanController.text.length < 10) return false;
    if (_getTimeValidationError() != null) return false;
    if (_isUploadMandatory() && _uploadedFileName == null) return false;
    return true;
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
      
      // AREA FORM (Bisa di-scroll dengan mulus)
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PILIH TANGGAL
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
                    Text(_selectedDate == null ? "Pilih Tanggal" : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
                    const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // KARTU DATA SISTEM
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
                        Text(_selectedDate == null ? "Pilih tanggal dahulu" : "Tanggal Terpilih", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
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

            // JENIS KOREKSI
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

            // WAKTU SEBENARNYA
            const Text('Waktu Sebenarnya (Sesuai Jadwal)', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
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
            if (_getTimeValidationError() != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                child: Text(_getTimeValidationError()!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 20),

            // ALASAN LENGKAP
            const Text('Alasan Lengkap (Min. 10 Karakter)', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _alasanController,
              onChanged: (value) => setState(() {}),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukkan alasan lengkap...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // UNGGAH BUKTI
            Row(
              children: [
                const Text('Unggah Bukti ', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                Text(_isUploadMandatory() ? '(WAJIB)' : '(Opsional)', style: TextStyle(color: _isUploadMandatory() ? Colors.red : Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() => _uploadedFileName = "bukti_koreksi_absen.jpg");
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent), 
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, color: Colors.blue, size: 40),
                    const SizedBox(height: 8),
                    Text(_uploadedFileName ?? 'Tarik file Anda atau telusuri', style: const TextStyle(color: Colors.blue)),
                    const SizedBox(height: 4),
                    const Text('Ukuran file maksimal yang diizinkan adalah 10 MB', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // AREA STICKY BUTTON (Melayang di paling bawah)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isFormValid() ? () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Koreksi Absen Berhasil Dikirim!'), backgroundColor: Colors.green));
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFormValid() ? const Color(0xFF2854C6) : Colors.grey.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('SUBMIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}