import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert'; // Ditambahkan untuk jsonEncode
import 'package:http/http.dart' as http;
import 'services/api_constants.dart'; 

class NewPasswordPage extends StatefulWidget {
  // --- SEPADAN DENGAN LARAVEL: Menerima email dan otp dari halaman sebelumnya ---
  final String email;
  final String otp;

  const NewPasswordPage({
    super.key, 
    required this.email, 
    required this.otp,
  });

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  bool _isPasswordVisible = false;
  bool _isLoading = false; // Menghindari multi-klik saat request berlangsung

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildPasswordField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), 
        borderRadius: BorderRadius.circular(30), 
      ),
      child: TextField(
        controller: controller, 
        obscureText: !_isPasswordVisible, 
        obscuringCharacter: '*', 
        style: const TextStyle(
          fontFamily: 'Inter', 
          color: Colors.black, 
          fontSize: 16,
          letterSpacing: 3.0, 
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: hint, 
          hintStyle: const TextStyle(
            color: Colors.black38,
            letterSpacing: 3.0,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Image.asset(
              'assets/images/lock.png', 
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.lock_outline, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, 
          elevation: 0, 
          child: Container(
            width: double.infinity,
            height: 380, 
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30), 
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Stack(
                  alignment: Alignment.center, 
                  children: [
                    Image.asset(
                      'assets/images/Bubbles.png', 
                      width: 140, 
                      height: 140,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(), 
                    ),
                    Image.asset(
                      'assets/images/Verified.png', 
                      width: 100, 
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.verified, size: 80, color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 30), 
                const Text(
                  'Selamat !',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Reset kata sandi berhasil\nAnda akan dialihkan ke\nlayar masuk sekarang',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'plus jakarta sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10), 
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return; 
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Lupa Password',
          style: TextStyle(fontFamily: 'Inter', color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'Buat Kata Sandi Baru',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              
              const SizedBox(height: 40),
              _buildPasswordField(_passwordController, 'Kata Sandi Baru'),
              const SizedBox(height: 20),
              _buildPasswordField(_confirmPasswordController, 'Ulangi Kata Sandi'),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.only(left: 16.0), 
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible; 
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(6), 
                        ),
                        width: 20,
                        height: 20,
                        child: _isPasswordVisible 
                            ? const Icon(Icons.check, size: 16, color: Colors.black) 
                            : null, 
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Tampilkan Password',
                      style: TextStyle(fontFamily: 'Inter', color: Colors.black87, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const Spacer(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '2 of 2',
                    style: TextStyle(fontFamily: 'Inter', color: Color(0xFF1E3A8A), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black, 
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading 
                    ? null 
                    : () async {
                        String pass1 = _passwordController.text;
                        String pass2 = _confirmPasswordController.text;

                        // 1. Validasi lokal (Disamakan dengan aturan Laravel min:8)
                        if (pass1.isEmpty || pass2.isEmpty) {
                          _showError("Kolom password tidak boleh kosong!");
                        } else if (pass1 != pass2) {
                          _showError("Kata sandi tidak cocok!");
                        } else if (pass1.length < 8) {
                          _showError("Password minimal harus 8 karakter!");
                        } else {
                          setState(() {
                            _isLoading = true;
                          });

                          // 2. Kirim ke API dengan struktur JSON yang tepat sesuai Laravel
                          try {
                            final response = await http.post(
                              Uri.parse(ApiConstants.newPassword),
                              headers: {
                                'Content-Type': 'application/json',
                                'Accept': 'application/json',
                              },
                              body: jsonEncode({
                                'email': widget.email,
                                'otp': int.tryParse(widget.otp) ?? widget.otp, // Konversi ke numeric sesuai validasi Laravel
                                'password': pass1,
                                'password_confirmation': pass2,
                              }),
                            );

                            final responseData = jsonDecode(response.body);

                            if (response.statusCode == 200 && responseData['success'] == true) {
                              _showSuccessDialog();
                            } else {
                              // Mengambil message error langsung dari response Laravel jika ada
                              String errorMsg = responseData['message'] ?? "Gagal mereset password.";
                              _showError(errorMsg);
                            }
                          } catch (e) {
                            _showError("Terjadi kesalahan koneksi!");
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading 
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}