import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_constants.dart';

class ProfileService {

  // =========================================================
  // PICK IMAGE
  // =========================================================

  static Future<File?> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 50,
      );

      if (image != null) {
        return File(image.path);
      }

      return null;
    } catch (e) {
      print("Error Pick Image: $e");
      return null;
    }
  }

  // =========================================================
  // DATE PICKER
  // =========================================================

  static Future<void> selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    try {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime(1995, 5, 23),
        firstDate: DateTime(1970),
        lastDate: DateTime.now(),
      );

      if (picked != null) {
        controller.text =
        "${picked.day.toString().padLeft(2, '0')}/"
            "${picked.month.toString().padLeft(2, '0')}/"
            "${picked.year}";
      }
    } catch (e) {
      print("Error Select Date: $e");
    }
  }

  // =========================================================
  // GENDER PICKER
  // =========================================================

  static void selectGender(
    BuildContext context,
    TextEditingController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 10,
              top: 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Pilih Jenis Kelamin",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                // =========================
                // LAKI LAKI
                // =========================

                ListTile(
                  leading: const Icon(
                    Icons.male,
                    color: Colors.blue,
                  ),
                  title: const Text("Laki - Laki"),
                  onTap: () {
                    controller.text = "Laki - Laki";
                    Navigator.pop(context);
                  },
                ),

                // =========================
                // PEREMPUAN
                // =========================

                ListTile(
                  leading: const Icon(
                    Icons.female,
                    color: Colors.pink,
                  ),
                  title: const Text("Perempuan"),
                  onTap: () {
                    controller.text = "Perempuan";
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // UPDATE PROFILE API
  // =========================================================

  static Future<bool> updateProfile({
    required String nama,
    required String email,
    required String noHp,
    required String alamat,
    required String tanggalLahir,
    required String jenisKelamin,
    File? imageFile,
  }) async {
    try {

      // =========================
      // AMBIL TOKEN & USER ID
      // =========================

      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        print("Token atau User ID tidak ditemukan");
        return false;
      }

      // =========================
      // URL API
      // =========================

      final url = Uri.parse(
        "${ApiConstants.updateProfile}/$userId",
      );

      // =========================
      // MULTIPART REQUEST
      // =========================

      var request = http.MultipartRequest(
        'POST',
        url,
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // =========================
      // FIELD DATA
      // =========================

      request.fields['email'] = email;
      request.fields['nama_lengkap'] = nama;
      request.fields['no_hp'] = noHp;
      request.fields['alamat'] = alamat;
      request.fields['tanggal_lahir'] = tanggalLahir;
      request.fields['jenis_kelamin'] = jenisKelamin;
      request.fields['device_id'] = 'android_001';

      // =========================
      // UPLOAD IMAGE
      // =========================

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto_profile',
            imageFile.path,
          ),
        );
      }

      // =========================
      // SEND REQUEST
      // =========================

      var response = await request.send();

      var res = await http.Response.fromStream(response);

      final data = jsonDecode(res.body);

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE: $data");

      return response.statusCode == 200;

    } catch (e) {
      print("Error Update Profile: $e");
      return false;
    }
  }

  // =========================================================
  // HANDLE SAVE
  // =========================================================

  static Future<void> handleSave(
    BuildContext context, {
    required String nama,
    required String email,
    required String noHp,
    required String alamat,
    required String tanggalLahir,
    required String jenisKelamin,
    File? imageFile,
  }) async {

    bool success = await updateProfile(
      nama: nama,
      email: email,
      noHp: noHp,
      alamat: alamat,
      tanggalLahir: tanggalLahir,
      jenisKelamin: jenisKelamin,
      imageFile: imageFile,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Profile Updated Successfully!"
              : "Failed Update Profile!",
        ),
      ),
    );
  }
}