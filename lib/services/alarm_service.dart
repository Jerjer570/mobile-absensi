import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmService {
  static Future<void> setPengingat({
    required String type,
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${type}_hour', hour);
    await prefs.setInt('${type}_minute', minute);
    await prefs.setBool('${type}_active', true);

    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    int idNotification = type == 'masuk' ? 201 : 202;
    String titleText = type == 'masuk' ? '⏰ Waktunya Absen Masuk!' : '🔔 Waktunya Absen Pulang!';
    String bodyText = type == 'masuk' 
        ? 'Jangan lupa lakukan presensi masuk kerja sekarang.' 
        : 'Jam kerja selesai, pastikan presensi keluar sebelum pulang.';

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: idNotification,
        channelKey: 'absensi_alarm_channel',
        title: titleText,
        body: bodyText,
        category: NotificationCategory.Alarm,
        wakeUpScreen: true,
        fullScreenIntent: true,
        customSound: 'resource://raw/alarm1',
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'DISMISS',
          label: 'Matikan Alarm',
          actionType: ActionType.DismissAction,
        ),
      ],
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
    );
  }

  

  static Future<void> batalkanPengingat(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${type}_active', false);

    int idNotification = type == 'masuk' ? 201 : 202;
    await AwesomeNotifications().cancelSchedule(idNotification);
  }

  static Future<Map<String, dynamic>> getSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'masuk_hour': prefs.getInt('masuk_hour') ?? 8,
      'masuk_minute': prefs.getInt('masuk_minute') ?? 0,
      'masuk_active': prefs.getBool('masuk_active') ?? false,
      'keluar_hour': prefs.getInt('keluar_hour') ?? 17,
      'keluar_minute': prefs.getInt('keluar_minute') ?? 0,
      'keluar_active': prefs.getBool('keluar_active') ?? false,
    };
  }
}