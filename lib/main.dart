import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'services/auth_service.dart';
import 'main_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelGroupKey: 'absensi_reminders_group',
        channelKey: 'absensi_alarm_channel',
        channelName: 'Pengingat Absensi',
        channelDescription: 'Saluran pengingat jam masuk dan pulang kerja PT Tunas Jaya',
        defaultColor: const Color(0xFF3498DB),
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        criticalAlerts: true,
        playSound: true,
        soundSource: 'resource://raw/alarm1',
      )
    ],
  );
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


      home: FutureBuilder<String>(
        future: AuthService.tentukanHalamanAwal(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: Color(0xFF3498DB))),
            );
          }
          if (snapshot.hasData) {
            if (snapshot.data == 'home') {
              return const MainPage();
            } else if (snapshot.data == 'login') {
              return const LoginPage();
            }
          }

          return const OnboardingPageFinal();
        },
      ),

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

  void _selesaikanOnboarding(Widget targetPage) async {
    await AuthService.setOnboardingSelesai(); // Kunci status agar tidak muncul lagi
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => targetPage));
    }
  }

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
                            onPressed: () => _selesaikanOnboarding(const LoginPage()),
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
                            onPressed: () => _selesaikanOnboarding(const RegisterPage()),
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
