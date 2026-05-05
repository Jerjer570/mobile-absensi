import 'dart:io'; // Untuk manajemen File gambar
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Dibutuhkan untuk memanggil ImageSource
import '../service/edit_profile_service.dart'; // Import logika service

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // 1. Definisikan Controller (UX Part - Menampung Input)
  final TextEditingController nameController = TextEditingController(text: 'Nia Santika Putri');
  final TextEditingController emailController = TextEditingController(text: 'niatsnk@gmail.com');
  final TextEditingController phoneController = TextEditingController(text: '+62');
  final TextEditingController addressController = TextEditingController(text: 'Jl. Ahmad Yani');
  final TextEditingController dateController = TextEditingController(text: '23/05/1995');
  final TextEditingController genderController = TextEditingController(text: 'Laki - Laki');

  // 2. State Variables
  final Color navyColor = const Color(0xFF20295F);
  File? _imageFile; // Menyimpan foto profil yang dipilih

  // 3. Fungsi Dialog Pilihan Foto (UX Part)
  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () async {
                  File? img = await EditProfileService.pickImage(ImageSource.gallery);
                  if (img != null) setState(() => _imageFile = img);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () async {
                  File? img = await EditProfileService.pickImage(ImageSource.camera);
                  if (img != null) setState(() => _imageFile = img);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      
      // --- AREA ISI (Bisa di-scroll) ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Foto Profil Section
            Center(
              child: GestureDetector(
                onTap: () => _showPicker(context),
                child: Stack(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: navyColor, width: 1.5),
                        color: Colors.grey.shade200,
                        image: _imageFile != null
                            ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _imageFile == null
                          ? const Icon(Icons.person, size: 80, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 10,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFF5C607E), shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Form Inputs
            _buildInputField(label: 'Name', controller: nameController),
            const SizedBox(height: 16),
            _buildInputField(label: 'Email', controller: emailController, keyboardType: TextInputType.emailAddress, readOnly: true),
            const SizedBox(height: 16),
            _buildInputField(label: 'No HP', controller: phoneController, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildInputField(label: 'Alamat', controller: addressController),
            const SizedBox(height: 16),
            _buildInputField(
              label: 'Tanggal Lahir',
              controller: dateController,
              suffixIcon: Icons.keyboard_arrow_down,
              readOnly: true,
              onTap: () => EditProfileService.selectDate(context, dateController),
            ),
            const SizedBox(height: 16),
            _buildInputField(
              label: 'Jenis Kelamin',
              controller: genderController,
              suffixIcon: Icons.keyboard_arrow_down,
              readOnly: true,
              onTap: () => EditProfileService.selectGender(context, genderController),
            ),

            // Beri sedikit jarak di bawah agar input terakhir tidak terlalu mepet dengan tombol sticky
            const SizedBox(height: 40),
          ],
        ),
      ),

      // --- TOMBOL SAVE (Sticky di Bawah & Aman dari Navigasi HP) ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16), // Jarak horizontal 24, bawah 16
          child: SizedBox(
            width: double.infinity, 
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Kirim data ke Service untuk disimpan
                EditProfileService.handleSave(context, {
                  'name': nameController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'address': addressController.text,
                  'dob': dateController.text,
                  'gender': genderController.text,
                  'image_path': _imageFile?.path ?? '',
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: navyColor, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Label dan TextField
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    IconData? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            filled: readOnly, 
            fillColor: readOnly ? Colors.grey.shade100 : Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.black, size: 28) : null,
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
              borderSide: BorderSide(color: navyColor),
            ),
          ),
        ),
      ],
    );
  }
}