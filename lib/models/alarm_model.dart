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

  // --- PERBAIKAN DI SINI ---
  // Menambahkan parameter label dan time agar bisa diupdate di NotificationPage
  AlarmModel copyWith({
    String? label,
    String? time,
    bool? isActive,
  }) {
    return AlarmModel(
      label: label ?? this.label, // Jika label baru kosong, pakai label lama
      time: time ?? this.time,    // Jika time baru kosong, pakai time lama
      isActive: isActive ?? this.isActive,
    );
  }

  // --- Fungsi untuk simpan ke Memori HP (Shared Preferences) ---
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