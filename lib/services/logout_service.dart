// lib/services/logout_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class LogoutService {
  /// Logout: hapus token di server terlebih dahulu,
  /// baru bersihkan semua data lokal.
  static Future<Map<String, dynamic>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Jika ada token, panggil endpoint logout di server
      if (token != null) {
        try {
          await http.post(
            Uri.parse(ApiConstants.logout),
            headers: {
              'Accept'       : 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 5));
        } catch (_) {
          // Lanjutkan meski koneksi gagal — tetap hapus data lokal
        }
      }

      // Bersihkan semua data lokal
      await prefs.clear();

      return {'success': true, 'message': 'Logout berhasil'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan saat logout'};
    }
  }
}
