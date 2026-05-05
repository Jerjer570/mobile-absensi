import 'package:absensi_tunas_jaya/koreksi_absen.dart';
import 'package:absensi_tunas_jaya/permohonan_izin.dart';
import 'package:flutter/material.dart';

class LayananPage extends StatelessWidget {
  const LayananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Layanan',
                style: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _buildServiceCard('assets/images/icon_pezin.png', 'Permohonan\nIzin', () {
                      // --- TAMBAH PRINT DI SINI ---
                      print("✅ TOMBOL IZIN BERHASIL DIKLIK!"); 
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PermohonanIzinPage()));
                    }),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildServiceCard('assets/images/icon_korab.png', 'Koreksi\nAbsen', () {
                      // --- TAMBAH PRINT DI SINI ---
                      print("✅ TOMBOL KOREKSI BERHASIL DIKLIK!");
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const KoreksiAbsenPage()));
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(String iconPath, String title, VoidCallback onTap) {
    return GestureDetector(
      // Bumbu rahasia agar seluruh kotak putih bisa diklik (tidak perlu pas di tengah ikon)
      behavior: HitTestBehavior.opaque, 
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Image.asset(iconPath, width: 45, height: 45),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
          ],
        ),
      ),
    );
  }
}