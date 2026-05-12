// lib/services/api_constants.dart

class ApiConstants {

  // =====================================================
  // BASE URL
  // =====================================================

  static const String baseUrl =
      'http://10.208.225.65:8000/api';

  // =====================================================
  // AUTH
  // =====================================================

  static const String register =
      '$baseUrl/register';

  static const String login =
      '$baseUrl/login';

  static const String forgotPassword =
      '$baseUrl/forgot-password';

  static const String newPassword =
      '$baseUrl/password/reset';

  // =====================================================
  // PRESENCE
  // =====================================================

  static const String punchIn =
      '$baseUrl/PresenceController/punch-in';

  static const String punchOut =
      '$baseUrl/PresenceController/punch-out';

  static const String koreksiAbsen = 
      "$baseUrl/attendance/correction";

  static const String permohonanIzin = 
      "$baseUrl/attendance/leave";

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