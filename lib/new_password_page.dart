import 'package:flutter/material.dart';
import 'dart:async'; // Dibutuhkan untuk fitur timer (Future.delayed)

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  bool _isPasswordVisible = false;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Widget khusus untuk membuat kolom input password berulang
  Widget _buildPasswordField(TextEditingController controller) {
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
          hintText: '********', 
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

  // --- FUNGSI MEMUNCULKAN POP-UP SELAMAT (VERSI FIX POSISI BUBBLE) ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User tidak bisa menutup dialog dengan klik di luar
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Membuat latar dialog transparan agar container utama terlihat melengkung sempurna
          elevation: 0, 
          child: Container(
            width: double.infinity,
            height: 380, // Kotak memanjang ke bawah sesuai Figma
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30), // Kotak dialog melengkung
            ),
            // Menggunakan Column agar konten rata tengah secara vertikal
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Semua isi Column di tengah
              children: [
                // --------------------------------------------------------------------------------------
                // --- UPDATE: MENYATUKAN BUBBLES DAN VERIFIED DI TENGAH (FIX OFF SITE) ---
                // --------------------------------------------------------------------------------------
                Stack(
                  alignment: Alignment.center, // Memaksa semua gambar di Stack ini bertumpuk tepat di tengah
                  children: [
                    // Lapisan 1: Bubbles.png (Background dekorasi)
                    Image.asset(
                      'assets/images/Bubbles.png', // Gambar bubbles custom
                      width: 140, // <-- Ukuran diperkecil agar radius pas di area Verified
                      height: 140,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(), 
                    ),

                    // Lapisan 2: Verified.png (Tameng centang - Di depan bubbles)
                    Image.asset(
                      'assets/images/Verified.png', // Gambar tameng custom
                      width: 100, // Ukuran ideal agar tameng terlihat jelas
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.verified, size: 80, color: Colors.blue),
                    ),
                  ],
                ),
                // --------------------------------------------------------------------------------------
                // --------------------------------------------------------------------------------------

                const SizedBox(height: 30), // Jarak ke judul

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
                const SizedBox(height: 10), // Memberi sedikit ruang di bawah agar tidak terlalu padat
              ],
            ),
          ),
        );
      },
    );

    // --- LOGIKA MUNDUR OTOMATIS SETELAH 3 DETIK ---
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return; // <--- TAMBAHKAN BARIS PENGAMAN INI

      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  // --- FUNGSI MENAMPILKAN PERINGATAN MERAH ---
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
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),

              _buildPasswordField(_passwordController),
              
              const SizedBox(height: 20),

              _buildPasswordField(_confirmPasswordController),

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
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    '2 of 2',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF1E3A8A), 
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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
                  onPressed: () {
                    String pass1 = _passwordController.text;
                    String pass2 = _confirmPasswordController.text;

                    if (pass1.isEmpty || pass2.isEmpty) {
                      _showError("Kedua kolom password tidak boleh kosong!");
                    } else if (pass1 != pass2) {
                      _showError("Kata sandi tidak cocok, silakan periksa kembali!");
                    } else if (pass1.length < 6) {
                      _showError("Kata sandi minimal 6 karakter!");
                    } else {
                      _showSuccessDialog();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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