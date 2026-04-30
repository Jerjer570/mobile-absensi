import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscureText = true;
  
  // --- CONTROLLER ---
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController(); 

  String? _selectedGender; 
  final List<String> _genderList = ['Laki-laki', 'Perempuan'];
  
  String? _uploadedFileName; 

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'), 
      helpText: 'PILIH TANGGAL LAHIR', 
      cancelText: 'BATAL',
      confirmText: 'PILIH',
    );

    if (picked != null) {
      setState(() {
        String day = picked.day.toString().padLeft(2, '0');
        String month = picked.month.toString().padLeft(2, '0');
        String year = picked.year.toString();
        _dobController.text = "$day/$month/$year";
      });
    }
  }

  // --- WIDGET BANTUAN TEKS INPUT ---
  Widget _buildInputField({
    required String label,
    required String hint,
    Widget? prefix,
    Widget? suffix,
    bool isPassword = false,
    bool readOnly = false,           
    VoidCallback? onTap,             
    TextEditingController? controller, 
    TextInputType? keyboardType, 
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword, 
            obscuringCharacter: '*', 
            readOnly: readOnly,     
            onTap: onTap,           
            keyboardType: keyboardType, 
            inputFormatters: inputFormatters,
            style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF1F2937)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black38, fontWeight: FontWeight.w500),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: prefix,
              suffixIcon: suffix,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // --- FUNGSI SNACKBAR ---
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFEFE), 
      body: Stack(
        children: [
          // Background Elips
          Positioned(
            top: -30, left: -30,
            child: Image.asset('assets/images/Ellipse_1.png', width: 250, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const SizedBox()),
          ),
          Positioned(
            top: -30, right: -30,
            child: Image.asset('assets/images/Ellipse_2.png', width: 250, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const SizedBox()),
          ),

          // --- FIX SCROLL: Menggunakan Positioned.fill ---
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                // Tambahan Bumbu UX: Bouncing Scroll & Otomatis Tutup Keyboard saat di-scroll
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.only(top: 20.0, bottom: 50.0), 
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo_tunas_jaya.png',
                      height: 55, fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 55),
                    ),
                    const SizedBox(height: 20), 

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0), 
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF), 
                          borderRadius: BorderRadius.circular(20), 
                          boxShadow: const [BoxShadow(color: Color(0x0D000000), spreadRadius: 2, blurRadius: 15, offset: Offset(0, 5))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                            ),
                            const SizedBox(height: 16),

                            Center(
                              child: Column(
                                children: [
                                  ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)]).createShader(bounds),
                                    child: const Text('Registrasi', style: TextStyle(fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Sudah punya akun? ', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500)),
                                      GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: const Text('Login', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF3B82F6), fontWeight: FontWeight.w600, fontSize: 14)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // --- FORM ---
                            _buildInputField(label: 'Email', hint: 'Jony@Gmail.com', controller: _emailController, keyboardType: TextInputType.emailAddress),
                            _buildInputField(label: 'Nama Lengkap', hint: 'Abdusi Salam', controller: _namaController),
                            
                            const Text('Jenis Kelamin', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  hint: const Text('Laki-laki / Perempuan', style: TextStyle(color: Colors.black38, fontWeight: FontWeight.w500)),
                                  value: _selectedGender,
                                  items: _genderList.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                                  onChanged: (newValue) => setState(() => _selectedGender = newValue),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildInputField(label: 'Tanggal Lahir', hint: '18/03/2024', controller: _dobController, readOnly: true, onTap: () => _selectDate(context), suffix: const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20)),
                            
                            _buildInputField(
                              label: 'Nomer HP', hint: '089-726-0592', controller: _phoneController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
                              prefix: Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Row(mainAxisSize: MainAxisSize.min, children: [const Text('🇮🇩', style: TextStyle(fontSize: 20)), const SizedBox(width: 8), Container(height: 24, width: 1, color: Colors.black12), const SizedBox(width: 8)])),
                            ),

                            _buildInputField(
                              label: 'Masukan Password', hint: '********', controller: _passwordController, isPassword: _obscureText, 
                              suffix: IconButton(icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 20), onPressed: () => setState(() => _obscureText = !_obscureText)),
                            ),

                            _buildInputField(label: 'Alamat', hint: 'Sidoarjo', controller: _alamatController),

                            Row(
                              children: const [
                                Text('Unggah Foto ', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w600)),
                                Text('(Opsional)', style: TextStyle(fontFamily: 'Inter', color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => setState(() => _uploadedFileName = "foto_profil.jpg"), 
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                decoration: BoxDecoration(color: const Color(0xFFF8F9FA), border: Border.all(color: Colors.blue.shade200), borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  children: [
                                    const Icon(Icons.cloud_upload_outlined, color: Colors.blue, size: 32),
                                    const SizedBox(height: 8),
                                    Text(_uploadedFileName ?? 'Tarik file Anda atau telusuri', style: const TextStyle(color: Colors.blue, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    const Text('Ukuran file maksimal yang diizinkan adalah 10 MB', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // --- TOMBOL REGISTER ---
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  String email = _emailController.text;
                                  String nama = _namaController.text;
                                  String dob = _dobController.text;
                                  String phone = _phoneController.text;
                                  String password = _passwordController.text;
                                  String alamat = _alamatController.text;

                                  if (email.isEmpty || nama.isEmpty || _selectedGender == null || dob.isEmpty || phone.isEmpty || password.isEmpty || alamat.isEmpty) {
                                    _showSnackBar('Mohon lengkapi semua data diri wajib!', const Color(0xFFEF4444));
                                  } else {
                                    _showSnackBar('Registrasi Berhasil!', Colors.green);
                                    Future.delayed(const Duration(seconds: 1), () {
                                      if (!mounted) return; 
                                      if (Navigator.canPop(context)) Navigator.pop(context);
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                child: const Text('Register', style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}