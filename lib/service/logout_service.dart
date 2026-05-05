// auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<void> logout() async {
    // 1. Hapus session/token dari storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 

    // 2. Jika pakai Firebase, tambahkan: await FirebaseAuth.instance.signOut();
    
    print("User berhasil logout dari sistem");
  }
}