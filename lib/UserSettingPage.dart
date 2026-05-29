import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Edit_Profil.dart';
import 'ubah_password.dart';
import 'Notification_Page.dart';
import 'login_page.dart';
import 'services/logout_service.dart';

class UserSettingPage extends StatefulWidget {
  const UserSettingPage({super.key});

  @override
  State<UserSettingPage> createState() => _UserSettingPageState();
}

class _UserSettingPageState extends State<UserSettingPage> {
  String _userName  = '';
  String _userEmail = '';
  String _userRole  = '';
  String _fotoProfile = '';
  bool   _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName  = prefs.getString('user_name')  ?? 'username';
      _userEmail = prefs.getString('user_email') ?? '-';
      _userRole  = prefs.getString('user_role')  ?? 'Karyawan';
      _fotoProfile = prefs.getString('foto_profile') ?? '';
    });
  }

  // ═══════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════
  Future<void> _handleLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title  : const Text('Konfirmasi Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style    : ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    setState(() => _isLoggingOut = true);
    final result = await LogoutService.logout();
    if (!mounted) return;
    setState(() => _isLoggingOut = false);

    if (result['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content        : Text(result['message'] ?? 'Logout gagal'),
          backgroundColor: Colors.red,
          behavior       : SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ═══════════════════════════════════
  // UI
  // ═══════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation      : 0,
        leading: IconButton(
          icon     : const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title      : const Text('Pengaturan',
            style: TextStyle(fontFamily: 'Inter', color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── KARTU PROFIL ──
            Container(
              margin    : const EdgeInsets.only(bottom: 20, top: 8),
              padding   : const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color       : const Color(0xFFF5F6F9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(children: [
                CircleAvatar(
                      radius: 24,
                      backgroundImage: (_fotoProfile.isNotEmpty && _fotoProfile != '')
                          ? NetworkImage(_fotoProfile)
                          : null, 
                      child: (_fotoProfile.isEmpty || _fotoProfile == '')
                          ? const Icon(Icons.person, size: 24, color: Colors.grey)
                          : null,
                    ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_userName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(_userEmail,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color       : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_userRole.toUpperCase(),
                          style: TextStyle(fontSize: 10, color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )),
              ]),
            ),

            // ── SECTION AKUN ──
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text('Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            Card(
              elevation: 0,
              color    : const Color(0xFFF5F6F9),
              shape    : RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child    : Column(children: [

                _buildMenuTile(
                  icon    : Icons.person_outline,
                  title   : 'Edit Profil',
                  subtitle: 'Ubah nama, foto, dan data diri',
                  onTap   : () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfile()),
                    );
                    if (updated == true) _loadUser();
                  },
                ),

                _divider(),

                _buildMenuTile(
                  icon    : Icons.lock_outline,
                  title   : 'Ubah Password',
                  subtitle: 'Ganti kata sandi akun Anda',
                  onTap   : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UbahPasswordPage()),
                    );
                  },
                ),

                _divider(),

                _buildMenuTile(
                  icon    : Icons.notifications_none,
                  title   : 'Notifikasi & Alarm',
                  subtitle: 'Atur pengingat jam masuk & pulang',
                  onTap   : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationPage()),
                    );
                  },
                ),
              ]),
            ),

            const SizedBox(height: 24),

            // ── SECTION ACTIONS ──
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text('Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Card(
              elevation: 0,
              color    : const Color(0xFFF5F6F9),
              shape    : RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child    : _isLoggingOut
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator(color: Colors.red)),
                    )
                  : _buildMenuTile(
                      icon    : Icons.logout,
                      title   : 'Log out',
                      subtitle: 'Keluar dari akun Anda',
                      iconColor: Colors.red,
                      onTap   : _handleLogout,
                    ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData  icon,
    required String    title,
    required String    subtitle,
    required VoidCallback onTap,
    Color?   iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding   : const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.blue).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? Colors.blue.shade700, size: 22),
      ),
      title   : Text(title,    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap   : onTap,
    );
  }

  Widget _divider() =>
      const Divider(height: 1, indent: 60, endIndent: 16, color: Color(0xFFE0E0E0));
}
