import 'package:flutter/material.dart';
import 'Edit_Profil.dart';
import 'Notification_Page.dart';

void main() {
  runApp(const MaterialApp(
    home: UserSetting(),
    debugShowCheckedModeBanner: false,
  ));
}

class UserSetting extends StatelessWidget {
  const UserSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Menggunakan ikon back standar Android
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section Akun ---
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Akun',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            Card(
              elevation: 0,
              color: const Color(0xFFF5F6F9), // Abu-abu sangat muda
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.person_outline,
                    title: 'Edit profile',
                    onTap: () {
                      print("Tombol Edit Profile diklik");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfile(), 
                        ), 
                      ); 
                    },// Aksi edit profile 
                  ),
                  _buildMenuTile(
                    icon: Icons.notifications_none,
                    title: 'Notifikasi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationPage(), 
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Section Actions ---
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Card(
              elevation: 0,
              color: const Color(0xFFF5F6F9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: _buildMenuTile(
                icon: Icons.logout,
                title: 'Log out',
                onTap: () {
                  // Aksi logout
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk membuat baris menu dengan efek sentuhan Android
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          color: Colors.black, 
        ),
      ),
      // Efek ripple Android otomatis muncul karena ListTile ada di dalam Card/Material
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}