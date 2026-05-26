import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'services/api_constants.dart';

class UbahPasswordPage extends StatefulWidget {
  const UbahPasswordPage({super.key});

  @override
  State<UbahPasswordPage> createState() => _UbahPasswordPageState();
}

class _UbahPasswordPageState extends State<UbahPasswordPage> {
  final _formKey               = GlobalKey<FormState>();
  final _passwordBaruCtrl      = TextEditingController();
  final _konfirmasiCtrl        = TextEditingController();

  bool _showBaru       = false;
  bool _showKonfirmasi = false;
  bool _isLoading      = false;

  // Indikator kekuatan password
/*  
  int get _strength {
    final p = _passwordBaruCtrl.text;
    int s = 0;
    if (p.length >= 8)                         s++;
    if (RegExp(r'[A-Z]').hasMatch(p))          s++;
    if (RegExp(r'[0-9]').hasMatch(p))          s++;
    if (RegExp(r'[!@#\$&*~_\-]').hasMatch(p)) s++;
    return s;
  }

  String get _strengthLabel {
    switch (_strength) {
      case 0:
      case 1: return 'Lemah';
      case 2: return 'Cukup';
      case 3: return 'Kuat';
      case 4: return 'Sangat Kuat';
      default: return '';
    }
  }

  Color get _strengthColor {
    switch (_strength) {
      case 0:
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.blue;
      case 4: return Colors.green;
      default: return Colors.grey;
    }
  }
*/
  @override
  void dispose() {
    _passwordBaruCtrl.dispose();
    _konfirmasiCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════
  // SUBMIT — POST /api/profile/{id}
  // ═══════════════════════════════════
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final prefs  = await SharedPreferences.getInstance();
      final token  = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        _showSnack('Session tidak valid, silakan login ulang', Colors.red);
        return;
      }

      final email = prefs.getString('user_email') ?? '';
      final response = await http.post(
        Uri.parse(ApiConstants.userResetPassword),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email,
          'password': _passwordBaruCtrl.text,
        }),
      );
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showSnack('Password berhasil diubah!', Colors.green);
        if (mounted) Navigator.pop(context);
      } else {
        if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          final first  = errors.values.first;
          _showSnack(first is List ? first.first : first.toString(), Colors.red);
        } else {
          _showSnack(responseData['message'] ?? 'Gagal mengubah password', Colors.red);
        }
      }
    } catch (_) {
      _showSnack('Terjadi kesalahan koneksi', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  // ═══════════════════════════════════
  // UI
  // ═══════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final navyColor = const Color(0xFF20295F);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation      : 0,
        leading        : IconButton(
          icon    : const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title  : const Text('Ubah Password',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── ILUSTRASI ──
              Center(
                child: Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color       : navyColor.withOpacity(0.08),
                    shape       : BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_reset_rounded, size: 44, color: navyColor),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: Text(
                  'Buat Password Baru',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: navyColor),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Password baru harus minimal 8 karakter.\nSimpan password Anda dengan aman.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 36),

              // ── PASSWORD BARU ──
              const Text('Password Baru *',
                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller : _passwordBaruCtrl,
                obscureText: !_showBaru,
                onChanged  : (_) => setState(() {}),
                validator  : (v) {
                  if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                  if (v.length < 8)           return 'Password minimal 8 karakter';
                  return null;
                },
                decoration: InputDecoration(
                  hintText    : 'Masukkan password baru',
                  border      : OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide  : BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide  : BorderSide(color: navyColor)),
                  suffixIcon  : IconButton(
                    icon    : Icon(_showBaru ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _showBaru = !_showBaru),
                  ),
                ),
              ),

              // ── INDIKATOR KEKUATAN ──
              if (_passwordBaruCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(children: [
                  ...List.generate(4, (i) => Expanded(
                    child: Container(
                      margin : const EdgeInsets.only(right: 4),
                      height : 4,
                      decoration: BoxDecoration(
                        // i < _strength ? _strengthColor : 
                        color       : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
                /*  
                  const SizedBox(width: 8),
                  Text(_strengthLabel, style: TextStyle(fontSize: 12, color: _strengthColor, fontWeight: FontWeight.w600)),
                */
                ]),
                const SizedBox(height: 6),
                _buildPasswordHints(),
              ],

              const SizedBox(height: 20),

              // ── KONFIRMASI PASSWORD ──
              const Text('Konfirmasi Password *',
                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller : _konfirmasiCtrl,
                obscureText: !_showKonfirmasi,
                onChanged  : (_) => setState(() {}),
                validator  : (v) {
                  if (v == null || v.isEmpty)           return 'Konfirmasi password tidak boleh kosong';
                  if (v != _passwordBaruCtrl.text)      return 'Password tidak cocok';
                  return null;
                },
                decoration: InputDecoration(
                  hintText    : 'Ulangi password baru',
                  border      : OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide  : BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide  : BorderSide(color: navyColor)),
                  suffixIcon: IconButton(
                    icon    : Icon(_showKonfirmasi ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _showKonfirmasi = !_showKonfirmasi),
                  ),
                  // Ikon cek jika cocok
                  prefixIcon: _konfirmasiCtrl.text.isNotEmpty
                      ? Icon(
                          _konfirmasiCtrl.text == _passwordBaruCtrl.text
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _konfirmasiCtrl.text == _passwordBaruCtrl.text
                              ? Colors.green
                              : Colors.red,
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 36),

              // ── TOMBOL SIMPAN ──
              SizedBox(
                width : double.infinity,
                height: 52,
                child : ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navyColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('SIMPAN PASSWORD',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════
  // HINTS PASSWORD
  // ═══════════════════════════════════
  Widget _buildPasswordHints() {
    final p = _passwordBaruCtrl.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hint('Minimal 8 karakter',        p.length >= 8),
        _hint('Mengandung huruf besar',     RegExp(r'[A-Z]').hasMatch(p)),
        _hint('Mengandung angka',           RegExp(r'[0-9]').hasMatch(p)),
        _hint('Mengandung karakter khusus', RegExp(r'[!@#\$&*~_\-]').hasMatch(p)),
      ],
    );
  }

  Widget _hint(String text, bool ok) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(children: [
        Icon(ok ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            size: 14, color: ok ? Colors.green : Colors.grey),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 11, color: ok ? Colors.green : Colors.grey)),
      ]),
    );
  }
}
