import 'package:flutter/material.dart';
import 'package:absensi_tunas_jaya/services/notification_service.dart'; // ✅ FIX IMPORT

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isMasukOn = false;
  bool isPulangOn = false;
  bool _isLoading = false;

  Future<void> _toggleNotification(String type, bool value) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      bool success =
          await NotificationService.updateNotificationStatus(type, value);

      if (success) {
        setState(() {
          if (type == 'masuk') {
            isMasukOn = value;
          } else {
            isPulangOn = value;
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal memperbarui pengaturan")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error toggle notif: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingatkan Absen',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildSwitchTile(
                    icon: Icons.wb_sunny_rounded,
                    iconColor: Colors.yellow.shade700,
                    title: 'Masuk',
                    value: isMasukOn,
                    onChanged: _isLoading
                        ? null
                        : (val) => _toggleNotification('masuk', val),
                  ),

                  Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: Colors.grey.shade300,
                  ),

                  _buildSwitchTile(
                    icon: Icons.wb_sunny_rounded,
                    iconColor: Colors.orange.shade700,
                    title: 'Pulang',
                    value: isPulangOn,
                    onChanged: _isLoading
                        ? null
                        : (val) => _toggleNotification('pulang', val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: iconColor, size: 28),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected)
              ? Colors.black
              : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected)
              ? Colors.grey.shade400
              : Colors.grey.shade300,
        ),
      ),
    );
  }
}