import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class AttendanceService {

  // =========================================================
  // SUBMIT ATTENDANCE (Punch In/Out)
  // =========================================================
  static Future<Map<String, dynamic>> submitAttendance({
    required bool isPunchIn,
    required double lat,
    required double lng,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');

      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      String today = DateTime.now().toIso8601String().split('T')[0];
      String timeNow = DateTime.now().toIso8601String().split('T')[1].substring(0, 8);

      final response = await http.post(
        Uri.parse(ApiConstants.punchIn),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'tanggal': today,
          'id_user': userId.toString(),
          'absen_masuk': isPunchIn ? timeNow : null,
          'absen_keluar': isPunchIn ? null : timeNow,
          'status': 'hadir',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _saveAttendanceHistory(
          isPunchIn: isPunchIn,
          lat: lat,
          lng: lng,
        );
        return {
          'success': true,
          'message': data['message'] ?? 'Berhasil',
          'data': data,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Terjadi kesalahan',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal koneksi ke server'};
    }
  }

  // =========================================================
  // SUBMIT KOREKSI ABSEN
  // =========================================================
  static Future<Map<String, dynamic>> submitKoreksi({
    required String tanggal,
    required String jenisKoreksi,
    required String waktu,
    required String alasan,
    String? fileNama,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http.post(
        Uri.parse(ApiConstants.koreksiAbsen),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'tanggal': tanggal,
          'jenis_koreksi': jenisKoreksi,
          'waktu_koreksi': waktu,
          'alasan': alasan,
          'bukti': fileNama ?? '',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Koreksi berhasil dikirim',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengirim koreksi',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  // =========================================================
  // GET ATTENDANCE HISTORY
  // =========================================================
  static Future<Map<String, dynamic>> getAttendanceHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http.get(
        Uri.parse(ApiConstants.history),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await prefs.setString('attendance_history', jsonEncode(data['data']));
        return {'success': true, 'data': data['data']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengambil history',
      };
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('attendance_history');
      if (saved != null) {
        return {'success': true, 'data': jsonDecode(saved)};
      }
      return {'success': false, 'message': 'Gagal koneksi ke server'};
    }
  }

  // =========================================================
  // SUBMIT PERMOHONAN IZIN
  // =========================================================
  static Future<Map<String, dynamic>> submitIzin({
    required String jenisIzin,
    required List<String> tanggalIzin,
    required String alasan,
    String? fileNama,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http.post(
        Uri.parse(ApiConstants.permohonanIzin),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'jenis_izin': jenisIzin,
          'tanggal_izin': jsonEncode(tanggalIzin),
          'alasan': alasan,
          'bukti': fileNama ?? '',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Izin berhasil diajukan',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengajukan izin',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  // =========================================================
  // LOGIKA PENDUKUNG (Internal)
  // =========================================================

  static Future<void> _saveAttendanceHistory({
    required bool isPunchIn,
    required double lat,
    required double lng,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    List history = [];
    final saved = prefs.getString('attendance_history');
    if (saved != null) {
      history = jsonDecode(saved);
    }

    DateTime now = DateTime.now();
    String today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    String formattedTime = _formatTime(now);

    if (isPunchIn) {
      history.add({
        "date": today,
        "check_in": formattedTime,
        "check_out": "--:--",
        "total_hours": "--:--",
        "latitude": lat,
        "longitude": lng,
        "status": "Masuk",
      });
    } else {
      for (int i = history.length - 1; i >= 0; i--) {
        if (history[i]['date'] == today && history[i]['check_out'] == "--:--") {
          history[i]['check_out'] = formattedTime;
          history[i]['total_hours'] = _calculateHours(history[i]['check_in'], formattedTime);
          history[i]['status'] = "Pulang";
          break;
        }
      }
    }
    await prefs.setString('attendance_history', jsonEncode(history));
  }

  static String _formatTime(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $ampm";
  }

  static String _calculateHours(String checkIn, String checkOut) {
    try {
      final inParts = _convertTo24Hour(checkIn);
      final outParts = _convertTo24Hour(checkOut);
      DateTime inTime = DateTime(2025, 1, 1, inParts[0], inParts[1]);
      DateTime outTime = DateTime(2025, 1, 1, outParts[0], outParts[1]);
      Duration diff = outTime.difference(inTime);
      return "${diff.inHours.toString().padLeft(2, '0')}:${diff.inMinutes.remainder(60).toString().padLeft(2, '0')}";
    } catch (e) {
      return "--:--";
    }
  }

  static List<int> _convertTo24Hour(String time) {
    List<String> split = time.split(' ');
    List<String> hm = split[0].split(':');
    int hour = int.parse(hm[0]);
    int minute = int.parse(hm[1]);
    String period = split[1];
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    return [hour, minute];
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('attendance_history');
  }
}