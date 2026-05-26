// lib/services/alarm_service.dart
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/alarm_model.dart';

class AlarmService {
  static const String _storageKey = 'alarm_list_v2';

  static final FlutterLocalNotificationsPlugin _notif =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ════════════════════════════════════════════════════════
  // INISIALISASI — panggil sekali di main()
  // ════════════════════════════════════════════════════════
  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings     = DarwinInitializationSettings(
      requestAlertPermission : true,
      requestBadgePermission : true,
      requestSoundPermission : true,
    );

    await _notif.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Minta izin di Android 13+
    await _notif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;

    // Re-schedule semua alarm aktif (dibutuhkan setelah restart HP)
    await rescheduleAll();
  }

  // ════════════════════════════════════════════════════════
  // LOAD dari SharedPreferences
  // ════════════════════════════════════════════════════════
  static Future<List<AlarmModel>> loadAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw   = prefs.getString(_storageKey);
      if (raw == null) return [];
      final list  = jsonDecode(raw) as List;
      return list
          .map((e) => AlarmModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ════════════════════════════════════════════════════════
  // SAVE ke SharedPreferences
  // ════════════════════════════════════════════════════════
  static Future<void> saveAlarms(List<AlarmModel> alarms) async {
    final prefs   = await SharedPreferences.getInstance();
    final encoded = jsonEncode(alarms.map((a) => a.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  // ════════════════════════════════════════════════════════
  // JADWALKAN ALARM (satu alarm bisa berulang di banyak hari)
  // ════════════════════════════════════════════════════════
  static Future<void> scheduleAlarm(AlarmModel alarm) async {
    await cancelAlarm(alarm.id); // hapus dulu yang lama

    if (!alarm.isActive) return;

    final parts   = alarm.time.split(':');
    final hour    = int.parse(parts[0]);
    final minute  = int.parse(parts[1]);
    final anyDay  = alarm.days.every((d) => !d); // semua false = satu kali

    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Absensi',
      channelDescription: 'Pengingat jam absen masuk dan pulang',
      importance        : Importance.max,
      priority          : Priority.high,
      playSound         : true,
      enableVibration   : true,
      icon              : '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert : true,
      presentBadge : true,
      presentSound : true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    if (anyDay) {
      // Satu kali — jadwalkan di waktu berikutnya
      final nextTime = _nextOccurrence(hour, minute, -1);
      await _notif.zonedSchedule(
        _idFromAlarmAndDay(alarm.id, 7), // hari 7 = satu kali
        '🔔 ${alarm.label}',
        'Waktunya absen — ${alarm.time}',
        nextTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } else {
      // Berulang per hari
      // days[0]=Sen(=1 dalam DateTime), days[6]=Min(=7)
      for (int i = 0; i < 7; i++) {
        if (!alarm.days[i]) continue;
        final weekday = i + 1; // DateTime: 1=Mon … 7=Sun
        final nextTime = _nextOccurrence(hour, minute, weekday);

        await _notif.zonedSchedule(
          _idFromAlarmAndDay(alarm.id, i),
          '🔔 ${alarm.label}',
          'Waktunya absen — ${alarm.time}',
          nextTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  // ════════════════════════════════════════════════════════
  // BATALKAN ALARM
  // ════════════════════════════════════════════════════════
  static Future<void> cancelAlarm(String alarmId) async {
    for (int i = 0; i <= 7; i++) {
      await _notif.cancel(_idFromAlarmAndDay(alarmId, i));
    }
  }

  // ════════════════════════════════════════════════════════
  // RE-SCHEDULE SEMUA (setelah reboot atau restart app)
  // ════════════════════════════════════════════════════════
  static Future<void> rescheduleAll() async {
    final alarms = await loadAlarms();
    for (final alarm in alarms) {
      if (alarm.isActive) await scheduleAlarm(alarm);
    }
  }

  // ════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════

  /// Buat int ID unik dari alarmId string + hari
  static int _idFromAlarmAndDay(String alarmId, int day) {
    // Ambil 6 digit terakhir dari hashcode dan tambahkan offset hari
    return (alarmId.hashCode.abs() % 100000) * 10 + day;
  }

  /// Kembalikan TZDateTime berikutnya untuk jam [hour]:[minute]
  /// pada weekday [weekday] (1=Mon…7=Sun, atau -1 untuk sehari sekali)
  static tz.TZDateTime _nextOccurrence(int hour, int minute, int weekday) {
    final jakarta = tz.getLocation('Asia/Jakarta');
    var   now     = tz.TZDateTime.now(jakarta);
    var   scheduled = tz.TZDateTime(jakarta, now.year, now.month, now.day, hour, minute);

    if (weekday == -1) {
      // Satu kali — jika jam sudah lewat hari ini, jadwalkan besok
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      return scheduled;
    }

    // Geser ke weekday yang diminta
    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
