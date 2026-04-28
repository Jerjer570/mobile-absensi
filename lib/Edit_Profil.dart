import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: const EditProfile(),
    debugShowCheckedModeBanner: false, // Menghilangkan banner debug
  ));
}

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna Navy sesuai desain
    const Color navyColor = Color(0xFF20295F);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            // Aksi kembali
          },
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // --- Foto Profil Section ---
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: navyColor, width: 1),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF5C607E), // Warna abu keunguan icon kamera
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Form Input Section (Sesuai Gambar) ---
            _buildInputField(
              label: 'Name',
              hint: 'Nia Santika Putri',
            ),
            const SizedBox(height: 16),
            
            _buildInputField(
              label: 'Email',
              hint: 'niatsnk@gmail.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            _buildInputField(
              label: 'No HP',
              hint: '+62',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            _buildInputField(
              label: 'Alamat',
              hint: 'Jl. Ahmad Yani',
            ),
            const SizedBox(height: 16),
            
            _buildInputField(
              label: 'Tanggal Lahir',
              hint: '23/05/1995',
              suffixIcon: Icons.keyboard_arrow_down,
            ),
            const SizedBox(height: 16),

            _buildInputField(
              label: 'Jenis Kelamin',
              hint: 'Laki - Laki',
              suffixIcon: Icons.keyboard_arrow_down,
            ),

            const SizedBox(height: 40),

            // --- Tombol Save Changes ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Aksi simpan perubahan
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyColor, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Label dan TextField
  Widget _buildInputField({
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black87, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            suffixIcon: suffixIcon != null 
                ? Icon(suffixIcon, color: Colors.black, size: 28) 
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF20295F)),
            ),
          ),
        ),
      ],
    );
  }
}