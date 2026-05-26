// lib/services/profile_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class ProfileService {

  // =========================================================
  // GET PROFIL — GET /api/profile/{id}
  // =========================================================
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      final token  = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        return {'success': false, 'message': 'Session tidak ditemukan. Silakan login ulang.'};
      }

      final response = await http.get(
        Uri.parse(ApiConstants.getProfile(userId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept'       : 'application/json',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final profileData = data['data'] as Map<String, dynamic>;

        // Cache nama ke SharedPreferences
        await prefs.setString('user_name', profileData['nama_lengkap'] ?? '');

        return {'success': true, 'data': profileData};
      }

      return {'success': false, 'message': data['message'] ?? 'Gagal memuat profil'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }

  // =========================================================
  // UPDATE PROFIL — POST /api/profile/{id} (multipart/form-data)
  // =========================================================
  static Future<Map<String, dynamic>> updateProfile({
    required String namaLengkap,
    required String email,
    required String noHp,
    required String alamat,
    required String tanggalLahir,
    required String jenisKelamin,
    String?  password,
    File?    foto,
  }) async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      final token  = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        return {'success': false, 'message': 'Session tidak ditemukan. Silakan login ulang.'};
      }

      final url     = Uri.parse(ApiConstants.updateProfileUrl(userId));
      var   request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept']        = 'application/json';

      request.fields['email']         = email;
      request.fields['nama_lengkap']  = namaLengkap;
      request.fields['no_hp']         = noHp;
      request.fields['alamat']        = alamat;
      request.fields['tanggal_lahir'] = tanggalLahir;
      request.fields['jenis_kelamin'] = jenisKelamin;

      if (password != null && password.isNotEmpty) {
        request.fields['password'] = password;
      }

      if (foto != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', foto.path));
      }

      final streamed  = await request.send();
      final response  = await http.Response.fromStream(streamed);
      final data      = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // Update cache
        await prefs.setString('user_name', namaLengkap);

        return {
          'success': true,
          'message': data['message'] ?? 'Profil berhasil diperbarui',
          'data'   : data['data'],
        };
      }

      if (response.statusCode == 422 && data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        final first  = errors.values.first;
        final msg    = first is List ? first.first : first.toString();
        return {'success': false, 'message': msg};
      }

      return {'success': false, 'message': data['message'] ?? 'Gagal memperbarui profil'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }
}
