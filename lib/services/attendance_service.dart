import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';
//import 'package:flutter/foundation.dart';

class AttendanceService {

  // =========================================================
  // HELPER — ambil token & userId dari SharedPreferences
  // =========================================================
  static Future<Map<String, dynamic>> _getCredentials() async {
    final prefs  = await SharedPreferences.getInstance();
    final token  = prefs.getString('auth_token');
    final userId = prefs.getInt('user_id');
    return {'token': token, 'userId': userId};
  }

  // =========================================================
  // CEK STATUS ABSENSI HARI INI
  // =========================================================
  static Future<Map<String, dynamic>> getTodayAttendance() async {
    try {
      final creds = await _getCredentials();
      final token = creds['token'];
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http.get(
        Uri.parse(ApiConstants.absensiToday),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      }

      return {'success': false, 'message': data['message'] ?? 'Gagal memuat data'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal koneksi ke server'};
    }
  }

  // =========================================================
  // SUBMIT ABSENSI (Punch In / Punch Out)
  // =========================================================
  static Future<Map<String, dynamic>> submitAttendance({
    required bool isPunchIn,
    required double lat,
    required double lng,
  }) async {
    try {
      final creds  = await _getCredentials();
      final token  = creds['token'] as String?;
      final userId = creds['userId'] as int?;

      if (token == null || userId == null) {
        return {'success': false, 'message': 'Session tidak ditemukan, silakan login ulang'};
      }

      final now     = DateTime.now();
      final today   = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final timeNow = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      // Body sesuai dengan validasi backend AbsensiApiController@store
      final Map<String, String> body = {
        'tanggal'   : today,
        'id_user'   : userId.toString(),
        'status'    : 'hadir',
        'latitude'  : lat.toString(),
        'longitude' : lng.toString(),
      };

      if (isPunchIn) {
        body['absen_masuk'] = timeNow;
      } else {
        body['absen_keluar'] = timeNow;
      }

      final response = await http.post(
        Uri.parse(ApiConstants.absensi),
        headers: {
          'Accept'       : 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Simpan juga ke cache lokal agar HistoryPage tetap bisa tampil offline
        await _saveAttendanceCache(
          isPunchIn : isPunchIn,
          lat       : lat,
          lng       : lng,
          time      : timeNow,
          date      : today,
        );
        return {
          'success': true,
          'message': data['message'] ?? 'Berhasil',
          'data'   : data['data'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Terjadi kesalahan pada server',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal koneksi ke server'};
    }
  }

  // =========================================================
  // GET HISTORY ABSENSI
  // GET /api/absensi?awal=YYYY-MM-DD&akhir=YYYY-MM-DD
  // =========================================================
  static Future<Map<String, dynamic>> getAttendanceHistory({
    String? awal,
    String? akhir,
  }) async {
    try {
      final creds = await _getCredentials();
      final token = creds['token'] as String?;

      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      String url = ApiConstants.history;
      if (awal != null && akhir != null) {
        url += '?awal=$awal&akhir=$akhir';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept'       : 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List list = data['data'] ?? [];
        // Simpan ke cache lokal
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('attendance_history_server', jsonEncode(list));
        return {'success': true, 'data': list};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengambil history',
      };
    } catch (e) {
      // Fallback: kembalikan cache lokal jika offline
      final prefs  = await SharedPreferences.getInstance();
      final cached = prefs.getString('attendance_history_server');
      if (cached != null) {
        return {'success': true, 'data': jsonDecode(cached), 'offline': true};
      }
      return {'success': false, 'message': 'Tidak ada koneksi dan tidak ada data cache'};
    }
  }

  // =========================================================
  // SUBMIT PENGAJUAN IZIN
  // POST /api/pengajuan-izin
  // =========================================================
  static Future<Map<String, dynamic>> submitIzin({
    required String jenisIzin,
    required List<String> tanggalIzin,
    required String alasan,
    File? fileMedia,
  }) async {
    try {
      final creds  = await _getCredentials();
      final token  = creds['token'] as String?;
      final userId = creds['userId'] as int?;

      if (token == null || userId == null) {
        return {'success': false, 'message': 'Session tidak ditemukan, silakan login ulang'};
      }
      if (tanggalIzin.isEmpty) {
        return {'success': false, 'message': 'Pilih minimal satu tanggal izin'};
      }
      tanggalIzin.sort();

      final uri = Uri.parse(ApiConstants.permohonanIzin);
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['jenis_izin'] = jenisIzin;
      request.fields['alasan'] = alasan;
      request.fields['id_user'] = userId.toString();
      for (int i = 0; i < tanggalIzin.length; i++) {
        request.fields['tanggal[$i]'] = tanggalIzin[i];
      }
      if (fileMedia != null) {
        final multipartFile = await http.MultipartFile.fromPath(
          'media_pendukung',
          fileMedia.path,
        );
        request.files.add(multipartFile);
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Izin berhasil diajukan',
        };
      }

      if (response.statusCode == 422 && data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        final msg = firstError is List ? firstError.first : firstError.toString();
        return {'success': false, 'message': msg};
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
  // SUBMIT KOREKSI ABSEN
  // POST /api/koreksi-absen
  // =========================================================
  static Future<Map<String, dynamic>> submitKoreksi({
    required String tanggal,         // YYYY-MM-DD
    required String jenisKoreksi,
    required String waktu,           // HH:mm:ss — waktu masuk
    required String alasan,
    String?  waktuKeluar,
    File? fileMedia,
  }) async {
    try {
      final creds = await _getCredentials();
      final token = creds['token'] as String?;
      final userId = creds['userId'] as int?;

      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      // Pastikan format HH:mm:ss
      String _toHms(String t) {
        final parts = t.split(':');
        if (parts.length == 2) return '${parts[0]}:${parts[1]}:00';
        return t;
      }

      final uri = Uri.parse(ApiConstants.koreksiAbsen);
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['tanggal'] = tanggal;
      request.fields['jenis_koreksi'] = jenisKoreksi;
      request.fields['alasan'] = alasan;
      request.fields['id_user_opsional'] = userId.toString();
      if (waktu.isNotEmpty) {
        request.fields['absen_masuk'] = _toHms(waktu);
      }
      if (waktuKeluar != null && waktuKeluar.isNotEmpty) {
        request.fields['absen_keluar'] = _toHms(waktuKeluar);
      }
      if (fileMedia != null) {
        final multipartFile = await http.MultipartFile.fromPath(
          'media_pendukung',
          fileMedia.path,
        );
        request.files.add(multipartFile);
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Koreksi berhasil dikirim',
        };
      }

      if (response.statusCode == 422 && data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        final msg = firstError is List ? firstError.first : firstError.toString();
        return {'success': false, 'message': msg};
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
  // SIMPAN KE CACHE LOKAL (setelah berhasil absen)
  // =========================================================
  static Future<void> _saveAttendanceCache({
    required bool isPunchIn,
    required double lat,
    required double lng,
    required String time,
    required String date,
  }) async {
    final prefs   = await SharedPreferences.getInstance();
    final saved   = prefs.getString('attendance_history');
    List history  = saved != null ? jsonDecode(saved) : [];

    final String formattedTime = from24ToAmPm(time);

    if (isPunchIn) {
      history.add({
        'date'       : date,
        'check_in'   : formattedTime,
        'check_out'  : '--:--',
        'total_hours': '--:--',
        'latitude'   : lat,
        'longitude'  : lng,
        'status'     : 'Masuk',
      });
    } else {
      for (int i = history.length - 1; i >= 0; i--) {
        if (history[i]['date'] == date && history[i]['check_out'] == '--:--') {
          history[i]['check_out']  = formattedTime;
          history[i]['total_hours']= calcTotalHours(history[i]['check_in'], formattedTime);
          history[i]['status']     = 'Pulang';
          break;
        }
      }
    }
    await prefs.setString('attendance_history', jsonEncode(history));
  }

  // =========================================================
  // HAPUS HISTORY CACHE
  // =========================================================
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('attendance_history');
    await prefs.remove('attendance_history_server');
  }

  // =========================================================
  // HELPER WAKTU
  // =========================================================
  static String from24ToAmPm(String time24) {
    try {
      final parts = time24.split(':');
      int h = int.parse(parts[0]);
      int m = int.parse(parts[1]);
      final period = h >= 12 ? 'PM' : 'AM';
      h = h % 12;
      h = h == 0 ? 12 : h;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return time24;
    }
  }
  static String formatTime(DateTime time) {
    int h = time.hour;
    final period = h >= 12 ? 'PM' : 'AM';
    h = h % 12;
    h = h == 0 ? 12 : h;
    return '${h.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  static String formatTimeTo24(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  static String formatTime24(String time24) {
    try {
      final parts = time24.split(':');
      int h = int.parse(parts[0]);
      int m = int.parse(parts[1]);
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    } catch (_) {
      return time24;
    }
  }
  

  static String calcTotalHours(String masuk, String keluar) {
    try {
      final mParts = masuk.split(':');
      final kParts = keluar.split(':');
      final mTime  = DateTime(2000, 1, 1, int.parse(mParts[0]), int.parse(mParts[1]));
      final kTime  = DateTime(2000, 1, 1, int.parse(kParts[0]), int.parse(kParts[1]));
      final diff   = kTime.difference(mTime);
      return '${diff.inHours.toString().padLeft(2, '0')}:${diff.inMinutes.remainder(60).toString().padLeft(2, '0')}';
    } catch (_) {
      return '--:--';
    }
  }
}
