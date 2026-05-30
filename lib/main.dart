import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'UserSettingPage.dart'; 
import 'layanan_page.dart';


import 'login_page.dart';
import 'register_page.dart';
import 'services/alarm_service.dart';   // ← import AlarmService


// ════════════════════════════════════════════════════════════
// ENTRY POINT
// AlarmService.init() dipanggil di sini agar:
//   1. flutter_local_notifications ter-inisialisasi sebelum widget apapun
//   2. Semua alarm aktif di-reschedule otomatis saat app dibuka
// ════════════════════════════════════════════════════════════
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AlarmService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Absensi Tunas Jaya',

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
      ],

      theme: ThemeData(
        primaryColor: const Color(0xFF3498DB),
        useMaterial3: true,
      ),


      home: const  OnboardingPageFinal(), 

    );
  }
}

// ════════════════════════════════════════════════════════════
// ONBOARDING (tidak diubah)
// ════════════════════════════════════════════════════════════
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
      'image': 'assets/images/Cover.png',
      'title': 'Absen Kerja Lebih Mudah & Cepat',
      'desc' : 'Selamat datang di aplikasi absensi resmi PT. Tunas Jaya. Sekarang Anda bisa melakukan absen masuk dan pulang langsung dari HP Anda di lokasi kerja.',
    },
    {
      'image': 'assets/images/Cover2.png',
      'title': 'Pencatatan Kehadiran yang Akurat',
      'desc' : 'Aplikasi ini menggunakan sistem deteksi lokasi agar data kehadiran Anda tercatat dengan aman, tepat, dan adil.',
    },
    {
      'image': 'assets/images/Cover3.png',
      'title': 'Siap Memulai Pekerjaan Hari Ini?',
      'desc' : 'Silakan masuk ke akun Anda untuk mulai melakukan absensi. Pilih metode masuk yang telah diberikan oleh pengawas Anda.',
    },
  ];

  Widget _buildIndicator(int index) {
    final isActive = index == _currentIndex;
    return Transform(
      transform: Matrix4.skewX(-0.4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin : const EdgeInsets.symmetric(horizontal: 4),
        height : 6,
        width  : isActive ? 20 : 16,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3498DB) : const Color(0xFFC4C4C4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller  : _pageController,
                itemCount   : _onboardingData.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder : (context, index) => SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Image.asset(
                        _onboardingData[index]['image']!,
                        width : w * 0.8,
                        height: 280,
                        fit   : BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image, size: 200, color: Colors.grey),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        _onboardingData[index]['title']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'PlusJakartaSans', fontSize: 22,
                            fontWeight: FontWeight.bold, color: Colors.black87, height: 1.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _onboardingData[index]['desc']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Roboto', fontSize: 14,
                            color: Colors.grey, fontWeight: FontWeight.w400, height: 1.5),
                      ),
                      if (index == 2) ...[
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const LoginPage())),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3498DB),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Masuk',
                                style: TextStyle(fontFamily: 'PlusJakartaSans',
                                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const RegisterPage())),  
                            style: OutlinedButton.styleFrom(
                              side   : const BorderSide(color: Color(0xFF3498DB), width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape  : RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Mendaftar',
                                style: TextStyle(fontFamily: 'PlusJakartaSans',
                                    color: Color(0xFF3498DB), fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Navigasi bawah
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: SizedBox(
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _currentIndex > 0
                          ? TextButton(
                              onPressed: () => _pageController.previousPage(
                                  duration: const Duration(milliseconds: 500), curve: Curves.ease),
                              child: const Text('Kembali',
                                  style: TextStyle(fontFamily: 'PlusJakartaSans',
                                      color: Color(0xFF3498DB), fontSize: 15, fontWeight: FontWeight.w600)),
                            )
                          : const SizedBox.shrink(),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                          _onboardingData.length, (i) => _buildIndicator(i)),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _currentIndex < _onboardingData.length - 1
                          ? TextButton(
                              onPressed: () => _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500), curve: Curves.ease),
                              child: const Text('Selanjutnya',
                                  style: TextStyle(fontFamily: 'PlusJakartaSans',
                                      color: Color(0xFF3498DB), fontSize: 15, fontWeight: FontWeight.w600)),
                            )
                          : const SizedBox.shrink(),
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
