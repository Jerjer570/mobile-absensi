import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'services/api_constants.dart';
import 'services/attendance_service.dart';

class KoreksiAbsenPage extends StatefulWidget {
  const KoreksiAbsenPage({super.key});

  @override
  State<KoreksiAbsenPage> createState() => _KoreksiAbsenPageState();
}

class _KoreksiAbsenPageState extends State<KoreksiAbsenPage> {
  // ═══════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════
  DateTime?  _selectedDate;
  String?    _jenisKoreksi;
  TimeOfDay? _waktuMasuk;
  TimeOfDay? _waktuKeluar;
  final TextEditingController _alasanController = TextEditingController();

  bool _isSubmitting   = false;
  bool _isFetchingData = false;

  // Data dari server
  bool    _hasAbsensiData = false; // true = ada record absensi tanggal ini
  String  _sysJamMasuk    = '--:--';
  String  _sysJamKeluar   = '--:--';

  String  _mode = 'koreksi';

  final List<String> _jenisKoreksiList = [
    'Lupa Absen Masuk',
    'Lupa Absen Keluar',
    'Koreksi Jam Masuk',
    'Koreksi Jam Keluar',
    'Gangguan Sistem / Jaringan',
    'Dinas Luar / Tugas Lapangan',
    'Perangkat Bermasalah',
    'Lainnya'
  ];

  final List<String> _jenisAbsenBaru = [
    'Lupa Absen (Tidak Ada Record)',
  ];

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════
  // PILIH TANGGAL
  // ═══════════════════════════════════════
  Future<void> _selectDate() async {
    final now    = DateTime.now();
    final picked = await showDatePicker(
      context   : context,
      initialDate: now,
      firstDate  : now.subtract(const Duration(days: 60)),
      lastDate   : now,
    );
    if (picked == null) return;

    setState(() {
      _selectedDate   = picked;
      _jenisKoreksi   = null;
      _waktuMasuk     = null;
      _waktuKeluar    = null;
      _hasAbsensiData = false;
      _sysJamMasuk    = '--:--';
      _sysJamKeluar   = '--:--';
      _mode           = 'koreksi';
    });

    await _fetchAbsensiData(picked);
  }

  // ═══════════════════════════════════════
  // FETCH DATA ABSENSI DARI SERVER
  // ═══════════════════════════════════════
  Future<void> _fetchAbsensiData(DateTime date) async {
    setState(() => _isFetchingData = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) return;

      final formatted = DateFormat('yyyy-MM-dd').format(date);
      final url = Uri.parse('${ApiConstants.history}?awal=$formatted&akhir=$formatted');

      final response = await http.get(url, headers: {
        'Accept'       : 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'] ?? [];

        if (list.isNotEmpty) {
          final item = Map<String, dynamic>.from(list.first as Map);
          setState(() {
            _hasAbsensiData = true;
            _sysJamMasuk    = _fmt24(item['absen_masuk']  as String?);
            _sysJamKeluar   = _fmt24(item['absen_keluar'] as String?);
            _mode           = 'koreksi';
          });
        } else {
          setState(() {
            _hasAbsensiData = false;
            _sysJamMasuk    = '--:--';
            _sysJamKeluar   = '--:--';
            _mode           = 'tambah_baru';
          });
        }
      }
    } catch (_) {
      setState(() => _hasAbsensiData = false);
    } finally {
      if (mounted) setState(() => _isFetchingData = false);
    }
  }

  String _fmt24(String? t) {
    if (t == null) return '--:--';
    try {
      final p = t.split(':');
      int h   = int.parse(p[0]);
      final m = int.parse(p[1]);
      final s = h >= 12 ? 'PM' : 'AM';
      h = h % 12; h = h == 0 ? 12 : h;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $s';
    } catch (_) { return t; }
  }

  String _timeToServer(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  // ═══════════════════════════════════════
  // PILIH JAM
  // ═══════════════════════════════════════
  Future<void> _pickWaktuMasuk() async {
    final t = await showTimePicker(context: context, initialTime: _waktuMasuk ?? TimeOfDay.now());
    if (t != null) setState(() => _waktuMasuk = t);
  }

  Future<void> _pickWaktuKeluar() async {
    final t = await showTimePicker(context: context, initialTime: _waktuKeluar ?? TimeOfDay.now());
    if (t != null) setState(() => _waktuKeluar = t);
  }

  // ═══════════════════════════════════════
  // VALIDASI FORM
  // ═══════════════════════════════════════
  bool _isFormValid() {
    if (_selectedDate == null)    return false;
    if (_jenisKoreksi == null)    return false;
    if (_alasanController.text.trim().length < 10) return false;

    if (_mode == 'tambah_baru') {
      return _waktuMasuk != null;
    } else {
      return _waktuMasuk != null || _waktuKeluar != null;
    }
  }

  // ═══════════════════════════════════════
  // SUBMIT
  // ═══════════════════════════════════════
  Future<void> _handleSubmit() async {
    if (!_isFormValid()) return;
    setState(() => _isSubmitting = true);

    final tanggal = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    Map<String, dynamic> result;

    if (_mode == 'tambah_baru') {
      result = await _submitAbsensiBaru(tanggal);
    } else {
      result = await AttendanceService.submitKoreksi(
        tanggal      : tanggal,
        jenisKoreksi : _jenisKoreksi!,
        waktu        : _waktuMasuk != null ? _timeToServer(_waktuMasuk!) : _timeToServer(_waktuKeluar!),
        alasan       : _alasanController.text.trim(),
        waktuKeluar  : _waktuKeluar != null ? _timeToServer(_waktuKeluar!) : null,
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content        : Text(result['message'] ?? (result['success'] == true ? 'Berhasil!' : 'Gagal')),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        behavior       : SnackBarBehavior.floating,
      ),
    );

    if (result['success'] == true) Navigator.pop(context);
  }

  Future<Map<String, dynamic>> _submitAbsensiBaru(String tanggal) async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      final token  = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');
      if (token == null || userId == null) {
        return {'success': false, 'message': 'Session tidak ditemukan'};
      }

      final response = await http.post(
        Uri.parse(ApiConstants.koreksiAbsen),
        headers: {
          'Accept'       : 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'tanggal'       : tanggal,
          'jenis_koreksi' : _jenisKoreksi ?? 'Tambah Absensi Baru',
          'absen_masuk'   : _waktuMasuk  != null ? _timeToServer(_waktuMasuk!)  : '',
          'absen_keluar'  : _waktuKeluar != null ? _timeToServer(_waktuKeluar!) : '',
          'alasan'        : _alasanController.text.trim(),
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': data['message'] ?? 'Pengajuan absensi baru berhasil dikirim'};
      }

      if (response.statusCode == 422 && data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        final first  = errors.values.first;
        return {'success': false, 'message': first is List ? first.first : first.toString()};
      }

      return {'success': false, 'message': data['message'] ?? 'Gagal mengirim pengajuan'};
    } catch (_) {
      return {'success': false, 'message': 'Gagal koneksi ke server'};
    }
  }

  // ═══════════════════════════════════════
  // UI
  // ═══════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final bool isTambahBaru = _mode == 'tambah_baru';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation      : 0,
        iconTheme      : const IconThemeData(color: Colors.black),
        title          : const Text('Koreksi Absen',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── INFO BANNER ──
            Container(
              margin    : const EdgeInsets.only(bottom: 20),
              padding   : const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text(
                  'Pilih tanggal untuk melihat data absensi. Jika tidak ada data, Anda bisa mengajukan penambahan absensi baru.',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                )),
              ]),
            ),

            // ── PILIH TANGGAL ──
            _buildLabel('Pilih Tanggal *'),
            GestureDetector(
              onTap: _selectDate,
              child: _buildField(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Pilih Tanggal'
                          : DateFormat('EEEE, dd MMMM yyyy', 'id').format(_selectedDate!),
                      style: TextStyle(
                        color: _selectedDate == null ? Colors.grey.shade500 : Colors.black,
                      ),
                    ),
                    _isFetchingData
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── KARTU DATA SISTEM ──
            Container(
              decoration: BoxDecoration(
                color       : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border      : Border.all(color: isTambahBaru ? Colors.orange.shade200 : Colors.blue.shade100),
              ),
              child: Column(children: [
                // Header kartu
                Container(
                  width  : double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isTambahBaru ? Colors.orange.shade100 : Colors.blue.shade100,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(children: [
                    Icon(
                      isTambahBaru ? Icons.add_circle_outline : Icons.storage_outlined,
                      size : 16,
                      color: isTambahBaru ? Colors.orange.shade800 : Colors.blue.shade800,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isTambahBaru
                          ? 'Tidak Ada Data — Tambah Absensi Baru'
                          : 'Data Absensi Saat Ini (Sistem)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isTambahBaru ? Colors.orange.shade800 : Colors.blue.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ]),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _selectedDate == null
                      ? const Text('Pilih tanggal untuk melihat data',
                          style: TextStyle(color: Colors.grey, fontSize: 13))
                      : isTambahBaru
                          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: const [
                                Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                                SizedBox(width: 6),
                                Expanded(child: Text(
                                  'Absensi tidak ditemukan pada tanggal ini.',
                                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500, fontSize: 13),
                                )),
                              ]),
                              const SizedBox(height: 8),
                              const Text(
                                'Isi form di bawah untuk mengajukan penambahan absensi. Pengajuan akan diproses oleh admin.',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ])
                          : Row(children: [
                              Expanded(child: _buildDataChip('Jam Masuk', _sysJamMasuk, _sysJamMasuk != '--:--')),
                              const SizedBox(width: 12),
                              Expanded(child: _buildDataChip('Jam Keluar', _sysJamKeluar, _sysJamKeluar != '--:--')),
                            ]),
                ),
              ]),
            ),

            const SizedBox(height: 20),
            _buildLabel(isTambahBaru ? 'Alasan Penambahan *' : 'Jenis Koreksi *'),
            Container(
              padding   : const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text(isTambahBaru ? 'Pilih alasan penambahan' : 'Pilih jenis koreksi'),
                  value: _jenisKoreksi,
                  items: (isTambahBaru ? _jenisAbsenBaru : _jenisKoreksiList)
                      .map((v) => DropdownMenuItem<String>(value: v, child: Text(v, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setState(() => _jenisKoreksi = v),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildLabel(isTambahBaru
                ? 'Waktu Absensi${isTambahBaru ? ' *' : ''}'
                : 'Waktu Koreksi (isi salah satu atau keduanya)'),

            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Jam Masuk', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickWaktuMasuk,
                    child: Container(
                      padding   : const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        color       : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border      : _waktuMasuk != null
                            ? Border.all(color: Colors.green.shade300, width: 1.5)
                            : null,
                      ),
                      child: Row(children: [
                        Icon(Icons.login, size: 18,
                            color: _waktuMasuk != null ? Colors.green : Colors.blue.shade300),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _waktuMasuk != null ? _waktuMasuk!.format(context) : 'Pilih jam',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize  : 14,
                              color     : _waktuMasuk != null ? Colors.green.shade700 : Colors.grey,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  if (_waktuMasuk != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _waktuMasuk = null),
                        child: const Text('Hapus', style: TextStyle(fontSize: 11, color: Colors.red)),
                      ),
                    ),
                ]),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Jam Keluar', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickWaktuKeluar,
                    child: Container(
                      padding   : const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        color       : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border      : _waktuKeluar != null
                            ? Border.all(color: Colors.orange.shade300, width: 1.5)
                            : null,
                      ),
                      child: Row(children: [
                        Icon(Icons.logout, size: 18,
                            color: _waktuKeluar != null ? Colors.orange : Colors.blue.shade300),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _waktuKeluar != null ? _waktuKeluar!.format(context) : 'Pilih jam',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize  : 14,
                              color     : _waktuKeluar != null ? Colors.orange.shade700 : Colors.grey,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  if (_waktuKeluar != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _waktuKeluar = null),
                        child: const Text('Hapus', style: TextStyle(fontSize: 11, color: Colors.red)),
                      ),
                    ),
                ]),
              ),
            ]),

            const SizedBox(height: 20),

            // ── ALASAN ──
            _buildLabel('Alasan Lengkap * (min. 10 karakter)'),
            TextField(
              controller: _alasanController,
              onChanged : (_) => setState(() {}),
              maxLines  : 4,
              decoration: InputDecoration(
                hintText   : 'Jelaskan alasan koreksi atau penambahan absensi...',
                filled     : true,
                fillColor  : Colors.white,
                counterText: '${_alasanController.text.length} / min 10',
                border     : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width : double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_isFormValid() && !_isSubmitting) ? _handleSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor        : isTambahBaru ? Colors.orange : const Color(0xFF2854C6),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        isTambahBaru ? 'AJUKAN ABSENSI BARU' : 'KIRIM KOREKSI',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            ),

            if (!_isFormValid() && _selectedDate != null)
              Container(
                margin : const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color       : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Lengkapi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange)),
                  const SizedBox(height: 4),
                  if (_jenisKoreksi == null)
                    const Text('• Pilih jenis koreksi/alasan', style: TextStyle(fontSize: 12, color: Colors.orange)),
                  if (_waktuMasuk == null && _waktuKeluar == null)
                    const Text('• Isi minimal satu waktu (masuk atau keluar)',
                        style: TextStyle(fontSize: 12, color: Colors.orange)),
                  if (_alasanController.text.trim().length < 10)
                    const Text('• Tulis alasan minimal 10 karakter',
                        style: TextStyle(fontSize: 12, color: Colors.orange)),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // WIDGET HELPERS
  // ═══════════════════════════════════════
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildField({required Widget child}) {
    return Container(
      padding   : const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child     : child,
    );
  }

  Widget _buildDataChip(String label, String value, bool recorded) {
    return Container(
      padding   : const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color       : recorded ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border      : Border.all(color: recorded ? Colors.green.shade200 : Colors.red.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color       : recorded ? Colors.green.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            recorded ? 'Tercatat' : 'Belum',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                color: recorded ? Colors.green.shade700 : Colors.red.shade700),
          ),
        ),
      ]),
    );
  }
}
