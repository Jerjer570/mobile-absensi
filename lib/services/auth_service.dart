// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class AuthService {

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
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode({
          'email'    : email,
          'password' : password,
          'device_id': deviceId,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['token'] as String;
        final user  = data['user']  as Map<String, dynamic>;

        // Ambil data karyawan dari nested object
        final karyawan = user['data_karyawan'] as Map<String, dynamic>?;
        final namaLengkap = karyawan?['nama_lengkap'] as String? ?? '';

        // Simpan ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token',  token);
        await prefs.setInt   ('user_id',     user['id'] as int);
        await prefs.setString('user_email',  user['email'] as String? ?? email);
        await prefs.setString('user_role',   user['role']  as String? ?? 'karyawan');
        await prefs.setString('user_name',   namaLengkap);
        await prefs.setString('user_status', user['status'] as String? ?? 'aktif');

        return {
          'success': true,
          'message': data['message'] ?? 'Login berhasil',
          'token'  : token,
          'user'   : user,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Email atau kata sandi salah',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server. Periksa koneksi internet Anda.'};
    }
  }

  // =========================================================
  // CEK APAKAH SUDAH LOGIN (token ada di SharedPreferences)
  // =========================================================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  // =========================================================
  // GET TOKEN
  // =========================================================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // =========================================================
  // GET USER ID
  // =========================================================
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }


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

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifyOtp),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': int.tryParse(otp) ?? otp, // Menyesuaikan dengan validasi 'numeric' di Laravel
        }),
      );

      // Decode response body
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;

    } catch (e) {
      // Menangani error jika koneksi gagal
      return {
        'success': false,
        'message': 'Gagal terhubung ke server: $e'
      };
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
      return {
        'success': false,
        'message': 'Koneksi gagal ke server',
      };
    }
  }





  static Future<String> tentukanHalamanAwal() async {
    final prefs = await SharedPreferences.getInstance();

    bool isFirstTime = prefs.getBool('is_first_time') ?? true;
    if (isFirstTime) {
      return 'onboarding';
    }

    String? token = prefs.getString('auth_token');
    String? tanggalLoginTerakhir = prefs.getString('last_login_date');

    if (token != null && tanggalLoginTerakhir != null) {
      String tanggalHariIni = DateTime.now().toIso8601String().split('T')[0];
      if (tanggalLoginTerakhir == tanggalHariIni) {
        return 'home';
      } else {
        await prefs.remove('auth_token');
        await prefs.remove('last_login_date');
      }
    }
    return 'login';
  }

  static Future<void> setOnboardingSelesai() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);
  }
}
