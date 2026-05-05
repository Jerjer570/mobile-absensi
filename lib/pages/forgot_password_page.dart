import 'package:flutter/material.dart';
import 'verification_page.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih bersih
      
      // --- APP BAR DENGAN TOMBOL BACK ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // Kembali ke halaman Login
        ),
      ),

      // --- KONTEN UTAMA ---
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // 1. JUDUL
              const Text(
                'Lupa Password ?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 30),

              // 2. GAMBAR ILUSTRASI
              Image.asset(
                'assets/images/Picture.png',
                height: 220, // Sesuaikan ukuran gambar
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.broken_image, size: 100, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // 3. TEKS PERTANYAAN
              const Text(
                'Di mana Anda ingin menerima\nKode Verifikasi Anda?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.bold, // Dibuat tebal sesuai desain
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 24),

              // 4. KOTAK PILIHAN EMAIL
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.0), // Garis hitam tebal
                  borderRadius: BorderRadius.circular(16), // Ujung melengkung
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Stack(
                  alignment: Alignment.center, 
                  children: [
                    // --- UPDATE: MENGGUNAKAN GAMBAR CUSTOM MESSAGE ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/images/message_fill.png', // Pastikan namanya sama persis
                        width: 32, // Ukurannya disesuaikan agar pas dengan teks
                        fit: BoxFit.contain,
                        // Alarm merah jika salah ketik nama file
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.warning, color: Colors.red),
                      ),
                    ),
                    // ------------------------------------------------
                    
                    // Teks via Email & Alamat Email tepat di tengah kotak
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center, 
                      children: [
                        const Text(
                          'via Email',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.grey, 
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'jon********com', 
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Mendorong tombol ke bagian paling bawah layar
              const Spacer(),

              // 5. TOMBOL "Berikutnya"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Nanti di sini kita arahkan ke Halaman Verifikasi OTP
                    debugPrint("Lanjut ke Verifikasi");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VerificationPage()),
                    );

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Warna tombol hitam
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Sangat melengkung (stadium)
                    ),
                  ),
                  child: const Text(
                    'Berikutnya',
                    style: TextStyle(
                      fontFamily: 'PlusJakarta Sans',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30), // Jarak tombol ke batas bawah layar
            ],
          ),
        ),
      ),
    );
  }
}