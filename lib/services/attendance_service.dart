import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class AttendanceService {

  // =========================
  // SUBMIT ABSEN
  // =========================
  static Future<Map<String, dynamic>> submitAttendance({
    required bool isPunchIn,
    required double lat,
    required double lng,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token == null) {
      return {
        'success': false,
        'message': 'Token tidak ditemukan, silakan login ulang'
      };
    }

    String url = isPunchIn 
        ? ApiConstants.punchIn 
        : ApiConstants.punchOut;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'latitude': lat.toString(),
          'longitude': lng.toString(),
        },
      );

      final data = jsonDecode(response.body);

      // ✅ response sukses dari backend
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data
        };
      }

      // ❌ error dari backend
      return {
        'success': false,
        'message': data['message'] ?? 'Terjadi kesalahan'
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal koneksi ke server'
      };
    }
  }
}