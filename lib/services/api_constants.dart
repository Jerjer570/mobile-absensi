// lib/services/api_constants.dart

class ApiConstants {

  // =====================================================
  // BASE URL
  // =====================================================

  static const String baseUrl = 'http://localhost:8000/api';

  // =====================================================
  // AUTH
  // =====================================================

  static const String register = '$baseUrl/storeUserWithKaryawan';
  static const String login = '$baseUrl/login';
  static const String forgotPassword = '$baseUrl/forgot-password';
  static const String newPassword = '$baseUrl/password/reset';

  // =====================================================
  // PRESENCE
  // =====================================================

static const String punchIn  = '$baseUrl/absensi';
static const String punchOut = '$baseUrl/absensi';
static const String koreksiAbsen = '$baseUrl/koreksi-absen';
static const String permohonanIzin = '$baseUrl/pengajuan-izin';
static const String history = '$baseUrl/absensi';

  // =====================================================
  // PROFILE
  // =====================================================

  // GET PROFILE
  static const String getProfile =
      '$baseUrl/profile';

  // UPDATE PROFILE
  static const String updateProfile =
      '$baseUrl/profile/update';

  // =====================================================
  // NOTIFICATION
  // =====================================================

  static const String updateNotification =
      '$baseUrl/notification/update';
}