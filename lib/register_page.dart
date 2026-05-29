import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'services/api_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscureText = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  String selectedGender = "laki-laki";
  File?  _imageFile;
  String? _existingPhotoUrl;
  final Color _navyColor = const Color(0xFF20295F);

  @override
  void dispose() {
    _emailController.dispose();
    _namaController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<String> _getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios';
      }
    } catch (e) {
      print("DEVICE ID ERROR: $e");
    }
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _registerProcess() async {
    if (_emailController.text.isEmpty ||
        _namaController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _alamatController.text.isEmpty ||
        _dobController.text.isEmpty) {
      _showSnackBar('Semua field wajib diisi!', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String tglInput = _dobController.text;
      List<String> parts = tglInput.split('/');
      String tglDatabase = "${parts[2]}-${parts[1]}-${parts[0]}";

      String deviceId = await _getDeviceId();
      var request = http.MultipartRequest('POST',Uri.parse(ApiConstants.register));
      request.headers['Accept'] = 'application/json';

      request.fields['nama_lengkap'] = _namaController.text;
      request.fields['email'] = _emailController.text;
      request.fields['password'] = _passwordController.text;
      request.fields['tanggal_lahir'] = tglDatabase;
      request.fields['no_hp'] = _phoneController.text;
      request.fields['device_id'] = deviceId;
      request.fields['jenis_kelamin'] = selectedGender;
      request.fields['alamat'] = _alamatController.text;

      // Tambahkan file gambar
      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', _imageFile!.path));
      }

      final streamed = await request.send();
      final res      = await http.Response.fromStream(streamed);
      final data     = jsonDecode(res.body) as Map<String, dynamic>;

      if ((res.statusCode == 200 || res.statusCode == 201) &&
          data['success'] == true) {
        _showSnackBar(data['message'] ?? 'Registrasi berhasil', Colors.green);
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.pop(context);
        });
      } else {
          if (data['errors'] != null) {
            Map<String, dynamic> errors = data['errors'];

            String errorMessage = errors.entries.map((entry) {
              return "${entry.key}: ${(entry.value as List).join(", ")}";
            }).join("\n");

            _showSnackBar(errorMessage, Colors.orange);
          } else {
            _showSnackBar('Registrasi gagal', Colors.orange);
          }
      }
    } catch (e) {
      print("REGISTER ERROR: $e");
      _showSnackBar('Koneksi gagal. Pastikan server berjalan!', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: suffix,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  

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


  Future<void> _pickImagee(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image  = await picker.pickImage(source: source, imageQuality: 50);
      if (image != null) setState(() => _imageFile = File(image.path));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
                  
            _buildInputField(
              label: 'Email',
              hint: 'email@gmail.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildInputField(
              label: 'Nama Lengkap',
              hint: 'Nama lengkap',
              controller: _namaController,
            ),
            _buildInputField(
              label: 'Tanggal Lahir',
              hint: 'dd/mm/yyyy',
              controller: _dobController,
              readOnly: true,
              onTap: () => _selectDate(context),
              suffix: const Icon(Icons.calendar_today),
            ),
            _buildInputField(
              label: 'No HP',
              hint: '08xxxx',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            _buildInputField(
              label: 'Alamat',
              hint: 'Alamat lengkap',
              controller: _alamatController,
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedGender,
              decoration: InputDecoration(
                labelText: 'Jenis Kelamin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: "laki-laki", child: Text("Laki-laki")),
                DropdownMenuItem(value: "perempuan", child: Text("Perempuan")),
              ],
              onChanged: (value) => setState(() => selectedGender = value!),
            ),
            const SizedBox(height: 16),
            _buildInputField(
              label: 'Password',
              hint: '********',
              controller: _passwordController,
              isPassword: _obscureText,
              suffix: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscureText = !_obscureText),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerProcess,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
