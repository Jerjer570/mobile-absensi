import 'package:absensi_tunas_jaya/main_page.dart';
import 'package:flutter/material.dart';
import 'register_page.dart'; // Menyambungkan ke halaman Registrasi
import 'forgot_password_page.dart';
import 'home_page.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // Variabel untuk menyembunyikan/menampilkan password
  bool _obscureText = true;

// Fungsi untuk memunculkan peringatan
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: color,
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
      // 1. WARNA DASAR BACKGROUND GELAP (HEX #0d0d1b)
      backgroundColor: const Color(0xFF0D0D1B), 
      
      // 2. STACK UNTUK MENUMPUK BACKGROUND BINTANG & CAHAYA
      body: Stack(
        children: [
          // --- LAYER BACKGROUND ---
          
          // Layer Bintang (Star.png)
          Positioned.fill(
            child: Image.asset(
              'assets/images/Star.png',
              fit: BoxFit.cover, 
              errorBuilder: (context, error, stackTrace) => const SizedBox(), 
            ),
          ),
          
          // Layer Cahaya (Light.png) - Pojok kanan atas
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              'assets/images/Light.png',
              width: 250, 
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),

          // --- LAYER KONTEN UTAMA ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. LOGO PERUSAHAAN (Pastikan nama file-nya benar)
                    Image.asset(
                      'assets/images/logo_tunas_jaya.png', 
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 80, color: Colors.red); 
                      },
                    ),
                    const SizedBox(height: 32),

                    // 2. JUDUL (Inter Bold)
                    const Text(
                      'Masuk ke Akun Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.bold, // Inter Bold
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. TEKS REGISTRASI (Inter Medium & SemiBold)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum punya akun? ',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white70, 
                            fontSize: 14,
                            fontWeight: FontWeight.w500, // Inter Medium
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigasi Pindah ke Halaman Registrasi
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterPage()),
                            );
                          },
                          child: const Text(
                            'Registrasi',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFF3B82F6), // Biru terang
                              fontWeight: FontWeight.w600, // Inter SemiBold
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // 4. KOTAK FORM INPUT (Warna Gelap)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A), // Kotak form gelap
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12, width: 1),
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white), 
                            decoration: const InputDecoration(
                              hintText: 'Jony@Gmail.com',
                              hintStyle: TextStyle(color: Colors.white38), 
                              prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF3B82F6)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                          const Divider(height: 1, color: Colors.white12), 
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText, 
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: '********',
                              hintStyle: const TextStyle(color: Colors.white38),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF3B82F6)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.white38,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 5. LUPA KATA SANDI
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                        );
                      },
                      child: const Text(
                        'Lupa Kata Sandi Anda?',
                        style: TextStyle(
                          color: Colors.white70,
                          decoration: TextDecoration.underline, 
                          decorationColor: Colors.white70, 
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 6. TOMBOL LOG IN
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Ambil teks dari controller email dan password
                          String email = _emailController.text;
                          String password = _passwordController.text;

                          // LOGIKA VALIDASI
                          if (email.isEmpty && password.isEmpty) {
                            _showSnackBar('Email dan Password tidak boleh kosong!', Colors.red);
                          } else if (email.isEmpty) {
                            _showSnackBar('Mohon isi Email Anda terlebih dahulu!', Colors.red);
                          } else if (password.isEmpty) {
                            _showSnackBar('Mohon isi Password Anda terlebih dahulu!', Colors.red);
                          } else {
                            // JIKA BERHASIL TERISI SEMUA:
                            // Pindah ke halaman Home Page dan hapus riwayat halaman agar tidak bisa di-back ke login
                              Navigator.pushReplacement(
                              context, 
                              MaterialPageRoute(builder: (context) => const MainPage()), 
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}