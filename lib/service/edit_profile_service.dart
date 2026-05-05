import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileService {

   static Future<File?> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 50, // Kompres agar tidak terlalu berat
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Logika untuk menampilkan Date Picker (UX Tanggal Lahir)
  static Future<void> selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 5, 23),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
     controller.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  // Logika untuk memilih Jenis Kelamin (UX Dropdown/ActionSheet)
 static void selectGender(BuildContext context, TextEditingController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      // Penting: Agar area bawah tidak terpotong navigasi sistem
      useSafeArea: true, 
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea( // <--- Bungkus dengan SafeArea
          child: Padding(
            // Tambahkan padding bawah ekstra agar tidak mepet tombol navigasi
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 10, 
              top: 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Agar tinggi menyesuaikan isi saja
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Pilih Jenis Kelamin",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.male, color: Colors.blue),
                  title: const Text("Laki - Laki"),
                  onTap: () {
                    controller.text = "Laki - Laki";
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.female, color: Colors.pink),
                  title: const Text("Perempuan"),
                  onTap: () {
                    controller.text = "Perempuan";
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // Logika untuk Simpan Data (Backend Logic)
  static void handleSave(BuildContext context, Map<String, String> data) {
    print("Menyimpan data: $data");
    // Di sini biasanya ada kodingan API (http.post)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Updated Successfully!")),
    );
  }
}