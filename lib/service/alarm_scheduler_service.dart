import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class AlarmSchedulerService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    // 1. Ambil implementasi Android untuk meminta izin khusus
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    // Minta izin notifikasi (Android 13+)
    await androidImplementation?.requestNotificationsPermission();
    
    // Minta izin Alarm Tepat Waktu (Android 14+). 
    // Jika tidak diizinkan, zonedSchedule akan gagal/error di Android terbaru.
    await androidImplementation?.requestExactAlarmsPermission();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notifikasi Absen Diklik");
      },
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: _nextInstanceOfTime(hour, minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'alarm_absensi_channel_v1', // Ganti ID jika Anda merubah settingan channel
            'Alarm Absensi Tunas Jaya', 
            channelDescription: 'Peringatan absen masuk dan pulang',
            importance: Importance.max,
            priority: Priority.max, // Set ke MAX agar muncul di atas aplikasi lain
            playSound: true,
            enableVibration: true,
            audioAttributesUsage: AudioAttributesUsage.alarm, // Memberitahu sistem ini adalah ALARM
            fullScreenIntent: true, // PENTING: Membuat notifikasi muncul di layar kunci
            category: AndroidNotificationCategory.alarm,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBanner: true,
          ),
        ),
        // exactAllowWhileIdle: Membuat notifikasi tetap bunyi meski HP sedang mode hemat baterai (Doze Mode)
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print("Alarm Berhasil disetel: $hour:$minute");
    } catch (e) {
      print("Gagal menyetel alarm: $e");
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
    print("Alarm ID $id dibatalkan");
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}