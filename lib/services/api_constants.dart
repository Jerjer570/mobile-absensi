// lib/services/api_constants.dart

class ApiConstants {

  // =====================================================
  // BASE URL — sesuaikan dengan IP server Laravel
  // =====================================================
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // =====================================================
  // AUTH
  // =====================================================
  static const String register       = '$baseUrl/register';
  static const String login          = '$baseUrl/login';
  static const String logout         = '$baseUrl/logout';
  static const String me             = '$baseUrl/me';

  static const String forgotPassword = '$baseUrl/forgot-password/send-otp';
  static const String verifyOtp      = '$baseUrl/forgot-password/verify-otp';
  static const String newPassword    = '$baseUrl/forgot-password/reset-password';

  // =====================================================
  // ABSENSI
  // =====================================================
  static const String absensi         = '$baseUrl/absensi';
  static const String absensiToday    = '$baseUrl/absensi/today';

  static const String punchIn         = '$baseUrl/absensi';
  static const String punchOut        = '$baseUrl/absensi';
  static const String history         = '$baseUrl/absensi';

  // =====================================================
  // PENGAJUAN IZIN & KOREKSI
  // =====================================================
  static const String koreksiAbsen    = '$baseUrl/koreksi-absen';
  static const String koreksiHistory  = '$baseUrl/koreksi-absen/history';
  static String destroyKoreksi(int idKoreksi)  => '$baseUrl/koreksi-absen/destroy/$idKoreksi';
  static const String permohonanIzin  = '$baseUrl/pengajuan-izin';
  static const String izinHistory  = '$baseUrl/pengajuan-izin/history';
  static String destroyIzin(int idIzin) => '$baseUrl/pengajuan-izin/destroy/$idIzin';

  // =====================================================
  // PROFIL KARYAWAN
  // =====================================================
  static String getProfile(int userId)    => '$baseUrl/profile/$userId';
  static String updateProfileUrl(int userId) => '$baseUrl/profile/$userId';
  
  static const String updateNotification ='$baseUrl/notification/update';

  static const String userResetPassword = '$baseUrl/user-resetpassword';

}
