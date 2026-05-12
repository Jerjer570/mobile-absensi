import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class NotificationService {
  static Future<bool> updateNotificationStatus(String type, bool isOn) async {
    return true; // Sementara, ganti dengan logika sebenarnya nanti
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // 🔴 Cegah token null
      if (token == null) {
        print("Token tidak ditemukan");
        return false;
      }

      final response = await http.post(
        Uri.parse(ApiConstants.updateNotification),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'type': type,
          'status': isOn ? '1' : '0',
        },
      );

      // 🔍 Debug response
      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Error NotificationService: $e");
      return false;
    }
  }
}