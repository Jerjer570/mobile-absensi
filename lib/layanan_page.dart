import 'package:flutter/material.dart';
import 'koreksi_absen.dart';
import 'permohonan_izin.dart';
import 'lihat_pengajuan_izin.dart';
import 'lihat_pengajuan_koreksiAbsen.dart';

class LayananPage extends StatelessWidget {
  const LayananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC), // Warna background putih bersih
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Layanan',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // --- GRID LAYANAN ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: [
                  const SizedBox(height: 10),
                  // BARIS 1: Permohonan
                  Row(
                    children: [
                      Expanded(
                        child: _buildServiceCard(
                          context,
                          Icons.calendar_today_outlined, 
                          'permohonan\nIzin', 
                          const PermohonanIzinPage(), // Halaman Tujuan
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildServiceCard(
                          context,
                          Icons.assignment_turned_in_outlined, 
                          'Koreksi\nAbsen', 
                          const KoreksiAbsenPage(), // Halaman Tujuan
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // BARIS 2: Lihat Pengajuan
                  Row(
                    children: [
                      Expanded(
                        child: _buildServiceCard(
                          context,
                          Icons.description_outlined, 
                          'Lihat pengajuan\nizin', 
                          const PengajuanIzinPage(), // Halaman Tujuan
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildServiceCard(
                          context,
                          Icons.access_time, 
                          'Lihat Pengajuan\nKoreksi Absen', 
                          const PengajuanKoreksiAbsenPage(), // Halaman Tujuan
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk membuat Kartu Menu
  Widget _buildServiceCard(BuildContext context, IconData iconData, String title, Widget targetPage) {
    return InkWell(
      onTap: () {
        // Navigasi ke halaman tujuan
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 180, 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container Ikon dengan Background Pink Muda
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                iconData,
                size: 32,
                color: const Color(0xFFB74154), // Warna maroon icon
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A4A4A),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}