import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'services/api_constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends State<RegisterPage> {

  bool _obscureText = true;
  bool _isLoading = false;

  final TextEditingController
      _emailController =
          TextEditingController();

  final TextEditingController
      _namaController =
          TextEditingController();

  final TextEditingController
      _dobController =
          TextEditingController();

  final TextEditingController
      _phoneController =
          TextEditingController();

  final TextEditingController
      _passwordController =
          TextEditingController();

  final TextEditingController
      _alamatController =
          TextEditingController();

  String selectedGender = "L";

  @override
  void dispose() {

    _emailController.dispose();
    _namaController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _alamatController.dispose();

    super.dispose();
  }

  // =========================================================
  // GET DEVICE ID
  // =========================================================

  Future<String> _getDeviceId() async {

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

      print(
        "DEVICE ID ERROR: $e",
      );
    }

    return DateTime.now()
        .millisecondsSinceEpoch
        .toString();
  }

  // =========================================================
  // REGISTER PROCESS
  // =========================================================

  Future<void>
      _registerProcess() async {

    // =====================================================
    // VALIDATION
    // =====================================================

    if (_emailController.text.isEmpty ||
        _namaController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _alamatController.text.isEmpty ||
        _dobController.text.isEmpty) {

      _showSnackBar(
        'Semua field wajib diisi!',
        Colors.red,
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      // ===================================================
      // FORMAT DATE
      // ===================================================

      String tglInput =
          _dobController.text;

      List<String> parts =
          tglInput.split('/');

      String tglDatabase =
          "${parts[2]}-${parts[1]}-${parts[0]}";

      // ===================================================
      // GET DEVICE ID
      // ===================================================

      String deviceId =
          await _getDeviceId();

      // ===================================================
      // API REQUEST
      // ===================================================

      final response = await http.post(
        Uri.parse(
          ApiConstants.register,
        ),

        headers: {
          'Accept':
              'application/json',
        },

        body: {

          'nama_lengkap':
              _namaController.text,

          'email':
              _emailController.text,

          'password':
              _passwordController.text,

          'tanggal_lahir':
              tglDatabase,

          'no_hp':
              _phoneController.text,

          'device_id':
              deviceId,

          'jenis_kelamin':
              selectedGender,

          'alamat':
              _alamatController.text,
        },
      );

      print(
        "STATUS: ${response.statusCode}",
      );

      print(
        "BODY: ${response.body}",
      );

      final data =
          jsonDecode(response.body);

      // ===================================================
      // SUCCESS
      // ===================================================

      if ((response.statusCode == 200 ||
              response.statusCode ==
                  201) &&
          data['success'] == true) {

        _showSnackBar(
          data['message'] ??
              'Registrasi berhasil',
          Colors.green,
        );

        Future.delayed(
          const Duration(seconds: 2),
          () {

            if (!mounted) return;

            Navigator.pop(context);
          },
        );
      }

      // ===================================================
      // FAILED
      // ===================================================

      else {

        _showSnackBar(
          data['message'] ??
              'Registrasi gagal',
          Colors.orange,
        );
      }

    } catch (e) {

      print(
        "REGISTER ERROR: $e",
      );

      _showSnackBar(
        'Koneksi gagal. Pastikan server berjalan!',
        Colors.red,
      );

    } finally {

      setState(() {
        _isLoading = false;
      });
    }
  }

  // =========================================================
  // DATE PICKER
  // =========================================================

  Future<void> _selectDate(
    BuildContext context,
  ) async {

    final picked =
        await showDatePicker(

      context: context,

      initialDate:
          DateTime(2000),

      firstDate:
          DateTime(1900),

      lastDate:
          DateTime.now(),
    );

    if (picked != null) {

      setState(() {

        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  // =========================================================
  // INPUT FIELD
  // =========================================================

  Widget _buildInputField({

    required String label,
    required String hint,
    required TextEditingController
        controller,

    bool isPassword = false,
    bool readOnly = false,

    VoidCallback? onTap,

    TextInputType? keyboardType,

    Widget? suffix,

  }) {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(label),

        const SizedBox(height: 6),

        TextFormField(

          controller: controller,

          obscureText: isPassword,

          readOnly: readOnly,

          onTap: onTap,

          keyboardType:
              keyboardType,

          decoration: InputDecoration(

            hintText: hint,

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(8),
            ),

            suffixIcon: suffix,
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // =========================================================
  // SNACKBAR
  // =========================================================

  void _showSnackBar(
    String message,
    Color color,
  ) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Register"),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            // =================================================
            // EMAIL
            // =================================================

            _buildInputField(
              label: 'Email',
              hint: 'email@gmail.com',
              controller:
                  _emailController,
              keyboardType:
                  TextInputType
                      .emailAddress,
            ),

            // =================================================
            // NAMA
            // =================================================

            _buildInputField(
              label: 'Nama Lengkap',
              hint: 'Nama lengkap',
              controller:
                  _namaController,
            ),

            // =================================================
            // TANGGAL LAHIR
            // =================================================

            _buildInputField(

              label: 'Tanggal Lahir',

              hint: 'dd/mm/yyyy',

              controller:
                  _dobController,

              readOnly: true,

              onTap: () =>
                  _selectDate(context),

              suffix: const Icon(
                Icons.calendar_today,
              ),
            ),

            // =================================================
            // NO HP
            // =================================================

            _buildInputField(

              label: 'No HP',

              hint: '08xxxx',

              controller:
                  _phoneController,

              keyboardType:
                  TextInputType.phone,
            ),

            // =================================================
            // ALAMAT
            // =================================================

            _buildInputField(

              label: 'Alamat',

              hint:
                  'Alamat lengkap',

              controller:
                  _alamatController,
            ),

            // =================================================
            // JENIS KELAMIN
            // =================================================

            DropdownButtonFormField<
                String>(

              value: selectedGender,

              decoration:
                  InputDecoration(

                labelText:
                    'Jenis Kelamin',

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          8),
                ),
              ),

              items: const [

                DropdownMenuItem(
                  value: "L",
                  child: Text(
                    "Laki-laki",
                  ),
                ),

                DropdownMenuItem(
                  value: "P",
                  child: Text(
                    "Perempuan",
                  ),
                ),
              ],

              onChanged: (value) {

                setState(() {

                  selectedGender =
                      value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // =================================================
            // PASSWORD
            // =================================================

            _buildInputField(

              label: 'Password',

              hint: '********',

              controller:
                  _passwordController,

              isPassword:
                  _obscureText,

              suffix: IconButton(

                icon: Icon(

                  _obscureText
                      ? Icons
                          .visibility_off
                      : Icons
                          .visibility,
                ),

                onPressed: () {

                  setState(() {

                    _obscureText =
                        !_obscureText;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // BUTTON REGISTER
            // =================================================

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed:
                    _isLoading
                        ? null
                        : _registerProcess,

                child: _isLoading

                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          color:
                              Colors.white,
                          strokeWidth: 2,
                        ),
                      )

                    : const Text(
                        "Register",
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}