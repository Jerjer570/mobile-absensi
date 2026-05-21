import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class AuthService {
  // =========================================================
  // GET DEVICE ID
  // =========================================================
  static Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios';
      }
    } catch (e) {
      print("DEVICE ID ERROR: $e");
    }
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // =========================================================
  // LOGIN
  // =========================================================
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      String deviceId = await getDeviceId();

      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Accept': 'application/json'},
        body: {
          'email': email,
          'password': password,
          'device_id': deviceId,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'token': data['token'],
          'user': data['user'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Login gagal, periksa email/password',
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal ke server'};
    }
  }

  // =========================================================
  // FORGOT PASSWORD
  // =========================================================
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.forgotPassword),
        headers: {'Accept': 'application/json'},
        body: {'email': email},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memproses permintaan',
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal ke server'};
    }
  }

  // =========================================================
  // NEW PASSWORD
  // =========================================================
  static Future<Map<String, dynamic>> newPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.newPassword),
        headers: {'Accept': 'application/json'},
        body: {
          'email': email,
          'otp': otp,
          'new_password': newPassword,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memproses permintaan',
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal ke server'};
    }
  }

  // =========================================================
  // REGISTER
  // =========================================================
  static Future<Map<String, dynamic>> register({
    required String namaLengkap,
    required String email,
    required String password,
    required String tanggalLahir,
    required String noHp,
    required String alamat,
    required String jenisKelamin,
  }) async {
    try {
      List<String> parts = tanggalLahir.split('/');
      String tglDatabase = "${parts[2]}-${parts[1]}-${parts[0]}";
      String deviceId = await getDeviceId();

      final response = await http.post(Uri.parse(ApiConstants.register,),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'nama_lengkap': namaLengkap,
          'email': email,
          'password': password,
          'tanggal_lahir': tglDatabase,
          'no_hp': noHp,
          'device_id': deviceId,
          'jenis_kelamin': jenisKelamin,
          'alamat': alamat,
        },
      );

      final data = jsonDecode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi berhasil',
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Registrasi gagal',
      };
    } catch (e) {
      print("REGISTER ERROR: $e");
      return {
        'success': false,
        'message': 'Koneksi gagal ke server',
      };
    }
  }


  
}