import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'new_password_page.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  // --- FITUR BARU: Variabel untuk menyimpan 4 digit OTP ---
  final List<String> _otpValues = ["", "", "", ""];

  // Widget khusus untuk membuat kotak OTP (Ditambah parameter index)
  Widget _otpBox(BuildContext context, {required int index, bool first = false, bool last = false}) {
    return SizedBox(
      height: 64,
      width: 60,
      child: TextField(
        autofocus: first, 
        onChanged: (value) {
          // --- Menyimpan angka yang diketik ke dalam List ---
          _otpValues[index] = value;

          // Logika otomatis pindah kotak saat mengetik atau menghapus
          if (value.length == 1 && !last) {
            FocusScope.of(context).nextFocus(); // Pindah ke kanan
          }
          if (value.isEmpty && !first) {
            FocusScope.of(context).previousFocus(); // Pindah ke kiri saat dihapus
          }
        },
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1), // Maksimal 1 angka per kotak
          FilteringTextInputFormatter.digitsOnly, // Hanya boleh angka
        ],
        style: const TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "", 
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black26, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2.0),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              const Text(
                'Verifikasi',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 12),

              const Text(
                'Silakan masukkan kode yang\ntelah kami kirimkan ke email Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // --- MENGHUBUNGKAN KOTAK DENGAN INDEX MEMORI ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _otpBox(context, index: 0, first: true),
                  _otpBox(context, index: 1),
                  _otpBox(context, index: 2),
                  _otpBox(context, index: 3, last: true),
                ],
              ),

              const SizedBox(height: 40),

              Column(
                children: [
                  const Text(
                    'Tidak Menerima Kode?',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      debugPrint("Kirim ulang kode OTP...");
                    },
                    child: const Text(
                      'Kirim Ulang Kode?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    '1 of 2',
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
              
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.black, 
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6), 
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.black12, 
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 6. TOMBOL VERIFY
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    String fullOtp = _otpValues.join(""); 

                    if (fullOtp.length < 4) {
                      // --- ALERT / SNACKBAR YANG DIPERBAGUS ---
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Mohon isi 4 digit kode verifikasi terlebih dahulu!',
                            textAlign: TextAlign.center, // Memaksa teks ke tengah
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600, // Teks sedikit ditebalkan
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: const Color(0xFFEF4444), // Merah terang yang elegan (Tailwind Red-500)
                          behavior: SnackBarBehavior.floating, // Membuat kotak melayang
                          elevation: 6, // Memberikan efek bayangan jatuh (shadow)
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16), // Memberikan Corner Radius
                          ),
                          margin: const EdgeInsets.only(
                            bottom: 40, // Jarak melayang dari bawah
                            left: 24,   // Jarak dari pinggir kiri
                            right: 24,  // Jarak dari pinggir kanan
                          ),
                          duration: const Duration(seconds: 3), // Hilang otomatis dalam 3 detik
                        ),
                      );
                      // ----------------------------------------
                    } else {
                      Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => const NewPasswordPage()),
                    );
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