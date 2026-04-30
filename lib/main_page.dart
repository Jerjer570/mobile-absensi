import 'package:flutter/material.dart';

// --- IMPORT SEMUA HALAMAN MENU DI SINI ---
import 'home_page.dart';
import 'layanan_page.dart';
import 'history_page.dart'; // Pastikan nama file history-mu benar (history_page.dart)

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditukar-tukar saat tombol bawah diklik
  final List<Widget> _pages = [
    const HomePage(),
    const LayananPage(),
    const HistoryPage(), // Jika file history_page.dart belum siap, ganti jadi: const Center(child: Text('History'))
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody wajib true agar background layar tembus sampai ke belakang navigasi bawah
      extendBody: true, 
      body: _pages[_selectedIndex],
      
      // --- INI DIA NAVIGASI BAWAH BIRUNYA ---
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24), // Melayang di atas dasar layar
        height: 65,
        decoration: BoxDecoration(
          color: const Color(0xFF2854C6), // Warna biru solid khas Tunas Jaya
          borderRadius: BorderRadius.circular(30), // Ujung membulat
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_filled, "HOME", 0),
            _buildNavItem(Icons.grid_view_rounded, "Layanan", 1),
            _buildNavItem(Icons.calendar_today_rounded, "History", 2),
          ],
        ),
      ),
    );
  }

  // Widget cetakan untuk tombol menu
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedIndex = index; // Mengganti halaman saat diklik
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250), // Efek transisi mulus
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent, // Background hitam jika dipilih
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}