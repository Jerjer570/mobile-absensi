import 'package:geolocator/geolocator.dart';

class LocationService {

  // =========================
  // GET CURRENT LOCATION
  // =========================
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 🔍 Cek GPS aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {
        'success': false,
        'message': 'GPS tidak aktif'
      };
    }

    // 🔐 Cek permission
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return {
          'success': false,
          'message': 'Izin lokasi ditolak'
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {
        'success': false,
        'message': 'Izin lokasi ditolak permanen, buka setting'
      };
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return {
        'success': true,
        'data': position
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mendapatkan lokasi'
      };
    }
  }
}