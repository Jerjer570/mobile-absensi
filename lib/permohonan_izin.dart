import 'dart:io';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'services/attendance_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;

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
  File? _selectedFile; 
  String? _uploadedFileName;

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

  String _getDokumenHint() {
    switch (_jenisIzin) {
      case "Izin-Sakit": return "Upload bukti pendukung seperti Surat Keterangan Dokter";
      case "Izin-Cuti": return "Upload bukti pendukung sepert medis/kepolisian/kelurahan";
      case "Izin-Lainnya": return "Upload bukti pendukung lainnya sesuai kebutuhan";
      default: return "Hanya mendukung file gambar (JPG, JPEG, PNG) dan PDF dengan ukuran maksimal 5 MB";
    }
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
      fileMedia     : _selectedFile,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      _showSnackBar(result['message'] ?? 'Izin berhasil diajukan!', Colors.green);
      Navigator.pop(context);
    } else {
      _showSnackBar(result['message'] ?? 'Gagal mengajukan izin', Colors.red);
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
                  firstDay: DateTime(DateTime.now().year - 1),
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

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result == null || result.files.single.path == null) return;

      final String filePath = result.files.single.path!;
      final String fileName = result.files.single.name;
      final File originalFile = File(filePath);
      final int fileBytes = await originalFile.length();
      const int max5MB = 5 * 1024 * 1024; 

      if (fileBytes > max5MB) {
        _showSnackBar('Ukuran file terlalu besar. Maksimal batas file adalah 5 MB.', Colors.orange);
        return;
      }
      setState(() => _isLoading = true);
      if (fileName.toLowerCase().endsWith('.jpg') ||
          fileName.toLowerCase().endsWith('.jpeg') ||
          fileName.toLowerCase().endsWith('.png')) {
        
        final bytes = await originalFile.readAsBytes();
        final decodedImage = img.decodeImage(bytes);

        if (decodedImage != null) {
          final jpgBytes = img.encodeJpg(decodedImage, quality: 60);
          
          final String newPath = filePath.replaceAll(RegExp(r'\.\w+$'), '_compressed.jpg');
          final File jpgFile = File(newPath);
          await jpgFile.writeAsBytes(jpgBytes);

          setState(() {
            _selectedFile = jpgFile;
            _uploadedFileName = fileName;
          });
        } else {
          setState(() {
            _selectedFile = originalFile;
            _uploadedFileName = fileName;
          });
        }
      } 
      else if (fileName.toLowerCase().endsWith('.pdf')) {
        setState(() {
          _selectedFile = originalFile;
          _uploadedFileName = fileName;
        });
      }
    } catch (e) {
      _showSnackBar('Gagal memilih atau memproses file', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getFileSizeString() {
    if (_selectedFile == null) return '0 KB';
    final int bytes = _selectedFile!.lengthSync(); // Membaca ukuran file secara langsung
    
    if (bytes < 1024) return '$bytes B';
    final double kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    
    final double mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
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
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Tambahkan dokumen Anda di sini',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _isLoading ? null : _pickDocument,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        border: Border.all(
                          color: _selectedFile != null ? Colors.green.shade300 : Colors.blue.shade200,
                          width: _selectedFile != null ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _selectedFile == null
                          ? const Column(
                              children: [
                                Icon(Icons.cloud_upload_outlined, color: Colors.blue, size: 32),
                                SizedBox(height: 8),
                                Text('Tarik file Anda atau telusuri',
                                    style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500)),
                                SizedBox(height: 4),
                                Text('Ukuran maksimal 5 MB',
                                    style: TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            )
                          : Column(
                              children: [
                                if (_uploadedFileName?.toLowerCase().endsWith('.jpg') == true ||
                                    _uploadedFileName?.toLowerCase().endsWith('.jpeg') == true ||
                                    _uploadedFileName?.toLowerCase().endsWith('.png') == true)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(
                                      _selectedFile!,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                else if (_uploadedFileName?.toLowerCase().endsWith('.pdf') == true)
                                  const Column(
                                    children: [
                                      Icon(Icons.picture_as_pdf, color: Colors.red, size: 48),
                                      SizedBox(height: 4),
                                      Text('Dokumen PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                  
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.file_present, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          _uploadedFileName ?? '',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text('Klik kembali untuk mengganti file',
                                    style: TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_getDokumenHint(),
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 11, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 20),
                  if (_uploadedFileName != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.blue.shade100, borderRadius: BorderRadius.circular(4)),
                            child: const Text('JPG',
                                style: TextStyle(
                                    color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_uploadedFileName ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  overflow: TextOverflow.ellipsis, // Menghindari teks overflow jika nama file terlalu panjang
                                ),
                                Text(_getFileSizeString(),
                                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                    value: 1.0,
                                    backgroundColor: Colors.grey.shade200,
                                    color: Colors.blue),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _isLoading ? null : () { setState(() {
                                _selectedFile = null;
                                _uploadedFileName = null;
                              });
                            },
                            child: const Icon(Icons.cancel_outlined, color: Colors.grey, size: 20),
                          )
                        ],
                      ),
                    ),
                ],
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
