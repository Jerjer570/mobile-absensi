// lib/models/alarm_model.dart

class AlarmModel {
  final String     id;
  final String     label;
  final String     time;      // "HH:mm" — 24 jam, mis "07:30"
  final List<bool> days;      // index 0=Sen … 6=Min
  final String     sound;
  final bool       isActive;

  const AlarmModel({
    required this.id,
    required this.label,
    required this.time,
    required this.days,
    this.sound    = 'Default',
    this.isActive = true,
  });

  // ── copyWith ──────────────────────────────────────
  AlarmModel copyWith({
    String?      id,
    String?      label,
    String?      time,
    List<bool>?  days,
    String?      sound,
    bool?        isActive,
  }) {
    return AlarmModel(
      id      : id       ?? this.id,
      label   : label    ?? this.label,
      time    : time     ?? this.time,
      days    : days     != null ? List<bool>.from(days) : List<bool>.from(this.days),
      sound   : sound    ?? this.sound,
      isActive: isActive ?? this.isActive,
    );
  }

  // ── Serialisasi ──────────────────────────────────
  Map<String, dynamic> toMap() => {
    'id'      : id,
    'label'   : label,
    'time'    : time,
    'days'    : days,
    'sound'   : sound,
    'isActive': isActive,
  };

  factory AlarmModel.fromMap(Map<String, dynamic> map) {
    return AlarmModel(
      id      : map['id']?.toString()   ?? DateTime.now().millisecondsSinceEpoch.toString(),
      label   : map['label']?.toString() ?? 'Alarm',
      time    : map['time']?.toString()  ?? '07:00',
      days    : (map['days'] as List<dynamic>?)
                  ?.map((e) => e == true || e == 1)
                  .toList()                             ?? List.filled(7, false),
      sound   : map['sound']?.toString() ?? 'Default',
      isActive: map['isActive'] == true  || map['isActive'] == 1,
    );
  }

  // ── Label hari aktif ─────────────────────────────
  static const _dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  String get activeDaysLabel {
    final active = <String>[];
    for (int i = 0; i < days.length; i++) {
      if (days[i]) active.add(_dayLabels[i]);
    }
    if (active.isEmpty) return 'Satu kali';
    if (active.length == 7) return 'Setiap hari';
    return active.join(', ');
  }

  @override
  String toString() => 'AlarmModel(id:$id, time:$time, label:$label, active:$isActive)';
}
