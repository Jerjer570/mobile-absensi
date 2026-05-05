import 'dart:convert';

class AlarmModel {
  final String label;
  final String time;
  final bool isActive;

  AlarmModel({
    required this.label,
    required this.time,
    this.isActive = false,
  });

  AlarmModel copyWith({bool? isActive}) {
    return AlarmModel(
      label: label,
      time: time,
      isActive: isActive ?? this.isActive,
    );
  }

  // --- Tambahan agar bisa simpan ke Memori HP dengan mudah ---
  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'time': time,
      'isActive': isActive,
    };
  }

  factory AlarmModel.fromMap(Map<String, dynamic> map) {
    return AlarmModel(
      label: map['label'] ?? '',
      time: map['time'] ?? '',
      isActive: map['isActive'] ?? false,
    );
  }

  // Mengubah objek ke teks (JSON) untuk disimpan
  String toJson() => json.encode(toMap());

  // Mengubah teks (JSON) kembali ke objek
  factory AlarmModel.fromJson(String source) => AlarmModel.fromMap(json.decode(source));
}