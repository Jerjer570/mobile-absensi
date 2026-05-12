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

    DeviceInfoPlugin deviceInfo =
        DeviceInfoPlugin();

    try {

      if (Platform.isAndroid) {

        AndroidDeviceInfo androidInfo =
            await deviceInfo.androidInfo;

        return androidInfo.id;
      }

      else if (Platform.isIOS) {

        IosDeviceInfo iosInfo =
            await deviceInfo.iosInfo;

        return iosInfo.identifierForVendor ??
            'unknown_ios';
      }

    } catch (e) {

      print("DEVICE ID ERROR: $e");
    }

    return DateTime.now()
        .millisecondsSinceEpoch
        .toString();
  }

  // =========================================================
  // REGISTER
  // =========================================================

  static Future<Map<String, dynamic>>
      register({

    required String namaLengkap,
    required String email,
    required String password,
    required String tanggalLahir,
    required String noHp,
    required String alamat,
    required String jenisKelamin,

  }) async {

    try {

      // =====================================================
      // FORMAT TANGGAL
      // =====================================================

      List<String> parts =
          tanggalLahir.split('/');

      String tglDatabase =
          "${parts[2]}-${parts[1]}-${parts[0]}";

      // =====================================================
      // DEVICE ID
      // =====================================================

      String deviceId =
          await getDeviceId();

      // =====================================================
      // REQUEST API
      // =====================================================

      final response = await http.post(
        Uri.parse(
          ApiConstants.register,
        ),

        headers: {
          'Accept': 'application/json',
        },

        body: {

          'nama_lengkap':
              namaLengkap,

          'email':
              email,

          'password':
              password,

          'tanggal_lahir':
              tglDatabase,

          'no_hp':
              noHp,

          'device_id':
              deviceId,

          'jenis_kelamin':
              jenisKelamin,

          'alamat':
              alamat,
        },
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      final data =
          jsonDecode(response.body);

      // =====================================================
      // SUCCESS
      // =====================================================

      if ((response.statusCode == 200 ||
              response.statusCode == 201) &&
          data['success'] == true) {

        return {
          'success': true,
          'message':
              data['message'] ??
              'Registrasi berhasil',
        };
      }

      // =====================================================
      // FAILED
      // =====================================================

      return {
        'success': false,
        'message':
            data['message'] ??
            'Registrasi gagal',
      };

    } catch (e) {

      print("REGISTER ERROR: $e");

      return {
        'success': false,
        'message':
            'Koneksi gagal ke server',
      };
    }
  }
}