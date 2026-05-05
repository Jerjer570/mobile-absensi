import 'package:absensi_tunas_jaya/home_page.dart';
import 'package:absensi_tunas_jaya/main_page.dart';
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Absensi Tunas Jaya',
      
      // --- TAMBAHKAN PENGATURAN LOKALISASI BAHASA INDONESIA DI SINI ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Kode untuk Bahasa Indonesia
      ],
      // ---------------------------------------------------------------

      theme: ThemeData(
        primaryColor: const Color(0xFF3498DB),
        useMaterial3: true,
      ),
      home: const MainPage(), 
    );
  }
}

class OnboardingPageFinal extends StatefulWidget {
  const OnboardingPageFinal({super.key});

  @override
  State<OnboardingPageFinal> createState() => _OnboardingPageFinalState();
}

class _OnboardingPageFinalState extends State<OnboardingPageFinal> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/Cover.png",
      "title": "Absen Kerja Lebih Mudah & Cepat",
      "desc": "Selamat datang di aplikasi absensi resmi PT. Tunas Jaya. Sekarang Anda bisa melakukan absen masuk dan pulang langsung dari HP Anda di lokasi kerja."
    },
    {
      "image": "assets/images/Cover2.png",
      "title": "Pencatatan Kehadiran yang Akurat",
      "desc": "Aplikasi ini menggunakan sistem foto wajah dan deteksi lokasi agar data kehadiran Anda tercatat dengan aman, tepat, dan adil."
    },
    {
      "image": "assets/images/Cover3.png",
      "title": "Siap Memulai Pekerjaan Hari Ini?",
      "desc": "Silakan masuk ke akun Anda untuk mulai melakukan absensi. Pilih metode masuk yang telah diberikan oleh pengawas Anda."
    },
  ];

  Widget _buildIndicator(int index) {
    bool isActive = (index == _currentIndex);
    return Transform(
      transform: Matrix4.skewX(-0.4), // Efek jajar genjang Figma
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        height: 6.0,
        width: isActive ? 20.0 : 16.0,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3498DB) : const Color(0xFFC4C4C4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- AREA PAGEVIEW (Gambar, Teks, & Tombol Khusus Slide 3) ---
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        
                        // Gambar Cover
                        Image.asset(
                          _onboardingData[index]["image"]!,
                          width: screenWidth * 0.8,
                          height: 280,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image, size: 200, color: Colors.grey);
                          },
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Teks Judul
                        Text(
                          _onboardingData[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Teks Deskripsi
                        Text(
                          _onboardingData[index]["desc"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),

                        // --- MUNCULKAN TOMBOL BESAR HANYA DI SLIDE KE-3 ---
                        if (index == 2) ...[
                          const SizedBox(height: 40),
                          // Tombol Masuk (Biru Solid)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3498DB),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Tombol Mendaftar (Garis Biru)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                debugPrint("Ke Halaman Daftar");
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF3498DB), width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Mendaftar',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  color: Color(0xFF3498DB),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // --- AREA NAVIGASI BAWAH (Stack = Pasti Tengah) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: SizedBox(
                height: 50, // Kunci tinggi agar rapi
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // KIRI: Tombol "Kembali" (Muncul di Slide 2 dan 3)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: (_currentIndex > 0)
                          ? TextButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              },
                              child: const Text(
                                'Kembali',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  color: Color(0xFF3498DB), // Biru Figma
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(), // Kosong jika slide 1
                    ),

                    // TENGAH: Indikator Jajar Genjang
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => _buildIndicator(index),
                      ),
                    ),

                    // KANAN: Tombol "Selanjutnya" (HILANG di Slide 3)
                    Align(
                      alignment: Alignment.centerRight,
                      child: (_currentIndex < _onboardingData.length - 1)
                          ? TextButton(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              },
                              child: const Text(
                                'Selanjutnya',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  color: Color(0xFF3498DB),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(), // Kosong jika slide 3
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}