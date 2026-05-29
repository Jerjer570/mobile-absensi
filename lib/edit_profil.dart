import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'services/api_constants.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  // =========================================================
  // CONTROLLER
  // =========================================================
  final TextEditingController _nameController    = TextEditingController();
  final TextEditingController _emailController   = TextEditingController();
  final TextEditingController _phoneController   = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateController    = TextEditingController();
  final TextEditingController _genderController  = TextEditingController();

  // =========================================================
  // STATE
  // =========================================================
  final Color _navyColor = const Color(0xFF20295F);
  bool   _isLoading        = false;
  bool   _isFetchingProfile= true;
  File?  _imageFile;
  String? _existingPhotoUrl;
  int?   _userId;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  // =========================================================
  // FETCH PROFIL dari GET /api/profile/{id}
  // =========================================================
  Future<void> _fetchProfileData() async {
    setState(() => _isFetchingProfile = true);
    try {
      final prefs  = await SharedPreferences.getInstance();
      final token  = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        _showSnackBar('Session tidak ditemukan, silakan login ulang', Colors.red);
        return;
      }

      _userId = userId;

      final response = await http.get(
        Uri.parse(ApiConstants.getProfile(userId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept'       : 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as Map<String, dynamic>;

        setState(() {
          _nameController.text    = data['nama_lengkap']  ?? '';
          _emailController.text   = data['email']         ?? '';
          _phoneController.text   = data['no_hp']         ?? '';
          _addressController.text = data['alamat']        ?? '';
          _dateController.text    = data['tanggal_lahir'] ?? '';
          _genderController.text  = data['jenis_kelamin'] ?? '';
          _existingPhotoUrl       = data['foto_profile'];
        });

        // Simpan nama ke SharedPreferences agar HomePage langsung update
        await prefs.setString('user_name', data['nama_lengkap'] ?? '');

      } else {
        final body = jsonDecode(response.body);
        _showSnackBar(body['message'] ?? 'Gagal memuat profil', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Gagal terhubung ke server', Colors.red);
    } finally {
      if (mounted) setState(() => _isFetchingProfile = false);
    }
  }

  // =========================================================
  // PICK IMAGE
  // =========================================================
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 60);
      if (picked != null) {
        final originalFile = File(picked.path);
        final bytes = await originalFile.readAsBytes();
        final decodedImage = img.decodeImage(bytes);

        if (decodedImage != null) {
          final jpgBytes = img.encodeJpg(decodedImage, quality: 60);
          final jpgFile = File(picked.path.replaceAll(RegExp(r'\.\w+$'), '.jpg'));
          await jpgFile.writeAsBytes(jpgBytes);

          setState(() => _imageFile = jpgFile);
        }
      }
    } catch (e) {
      _showSnackBar('Gagal memilih gambar', Colors.red);
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.blue),
            title: const Text('Galeri'),
            onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera, color: Colors.green),
            title: const Text('Kamera'),
            onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
          ),
        ]),
      ),
    );
  }

  // =========================================================
  // SELECT DATE
  // =========================================================
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context    : context,
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime(2000),
      firstDate  : DateTime(1970),
      lastDate   : DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  // =========================================================
  // SELECT GENDER
  // =========================================================
  void _selectGender() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Pilih Jenis Kelamin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            ListTile(
              leading: const Icon(Icons.male, color: Colors.blue),
              title: const Text('Laki - Laki'),
              onTap: () { setState(() => _genderController.text = 'Laki - Laki'); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.female, color: Colors.pink),
              title: const Text('Perempuan'),
              onTap: () { setState(() => _genderController.text = 'Perempuan'); Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // UPDATE PROFIL — POST /api/profile/{id} (multipart)
  // =========================================================
  Future<void> _updateProfile() async {
    if (_userId == null) {
      _showSnackBar('Session tidak valid', Colors.red);
      return;
    }

    // Validasi minimal
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Nama tidak boleh kosong', Colors.red);
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Email tidak boleh kosong', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        _showSnackBar('Session habis, silakan login ulang', Colors.red);
        return;
      }

      final url     = Uri.parse(ApiConstants.updateProfileUrl(_userId!));
      var   request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept']        = 'application/json';

      request.fields['email']         = _emailController.text.trim();
      request.fields['nama_lengkap']  = _nameController.text.trim();
      request.fields['no_hp']         = _phoneController.text.trim();
      request.fields['alamat']        = _addressController.text.trim();
      request.fields['tanggal_lahir'] = _dateController.text.trim();
      request.fields['jenis_kelamin'] = _genderController.text.trim();

      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', _imageFile!.path));
      }

      final streamed = await request.send();
      final res      = await http.Response.fromStream(streamed);
      final data     = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        // Update nama di cache lokal
        await prefs.setString('user_name', _nameController.text.trim());

        _showSnackBar(data['message'] ?? 'Profil berhasil diperbarui', Colors.green);
        if (mounted) Navigator.pop(context, true); // return true agar halaman sebelumnya bisa refresh
      } else {
        // Tampilkan pesan validasi dari backend
        if (data['errors'] != null) {
          final errors   = data['errors'] as Map<String, dynamic>;
          final firstMsg = errors.values.first;
          final msg      = firstMsg is List ? firstMsg.first : firstMsg.toString();
          _showSnackBar(msg, Colors.red);
        } else {
          _showSnackBar(data['message'] ?? 'Gagal memperbarui profil', Colors.red);
        }
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan koneksi', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // =========================================================
  // SNACKBAR
  // =========================================================
  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  // =========================================================
  // UI
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isFetchingProfile
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ─── FOTO PROFIL ───
                  Center(
                    child: GestureDetector(
                      onTap: _showImagePicker,
                      child: Stack(
                        children: [
                          Container(
                            width: 130, height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _navyColor, width: 2),
                              color: Colors.grey.shade200,
                              image: _imageFile != null
                                  ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                                  : (_existingPhotoUrl != null
                                      ? DecorationImage(image: NetworkImage(_existingPhotoUrl!), fit: BoxFit.cover)
                                      : null),
                            ),
                            child: (_imageFile == null && _existingPhotoUrl == null)
                                ? const Icon(Icons.person, size: 70, color: Colors.grey)
                                : null,
                          ),
                          Positioned(
                            bottom: 6, right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Color(0xFF5C607E), shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Text('Ketuk foto untuk mengubah', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 28),

                  // ─── FORM FIELDS ───
                  _buildField(label: 'Nama Lengkap',   controller: _nameController),
                  const SizedBox(height: 16),
                  _buildField(label: 'Email',           controller: _emailController, keyboard: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildField(label: 'No HP',           controller: _phoneController, keyboard: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildField(label: 'Alamat',          controller: _addressController, maxLines: 2),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Tanggal Lahir', controller: _dateController,
                    suffixIcon: Icons.calendar_today, readOnly: true, onTap: _selectDate,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Jenis Kelamin', controller: _genderController,
                    suffixIcon: Icons.keyboard_arrow_down, readOnly: true, onTap: _selectGender,
                  ),

                  const SizedBox(height: 36),

                  // ─── TOMBOL SIMPAN ───
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navyColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Simpan Perubahan',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // =========================================================
  // INPUT FIELD BUILDER
  // =========================================================
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    IconData? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller   : controller,
          keyboardType : keyboard,
          readOnly     : readOnly,
          onTap        : onTap,
          maxLines     : maxLines,
          decoration: InputDecoration(
            filled      : readOnly,
            fillColor   : readOnly ? Colors.grey.shade100 : Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            suffixIcon  : suffixIcon != null ? Icon(suffixIcon, color: Colors.black54) : null,
            border      : OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide  : BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide  : BorderSide(color: _navyColor),
            ),
          ),
        ),
      ],
    );
  }
}
