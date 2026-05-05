import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Wajib untuk inputFormatters Nomer HP

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscureText = true;
  
  // --- 1. SIAPKAN CONTROLLER UNTUK SEMUA KOLOM ---
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // Jangan lupa dibersihkan agar tidak bocor memori
    _emailController.dispose();
    _namaController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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
      fieldLabelText: 'Masukkan Tanggal',
      fieldHintText: 'Tanggal/Bulan/Tahun',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B5CF6), 
              onPrimary: Colors.white,    
              onSurface: Color(0xFF1F2937), 
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
              elevation: 10,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB), 
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
              ),
            ),
          ),
          child: child!,
        );
      },
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

  // --- WIDGET BANTUAN UNTUK FORM INPUT ---
  Widget _buildInputField({
    required String label,
    required String hint,
    Widget? prefix,
    Widget? suffix,
    bool isPassword = false,
    bool readOnly = false,           
    VoidCallback? onTap,             
    TextEditingController? controller, // Controller disambungkan ke sini
    TextInputType? keyboardType, 
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF6B7280), 
            fontSize: 13,
            fontWeight: FontWeight.w600, 
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
          child: TextFormField(
            controller: controller, // <-- Controller aktif membaca teks
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

  // --- FUNGSI MENAMPILKAN PERINGATAN ---
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
          // Latar belakang elips...
          Positioned(
            top: -30, left: -30,
            child: Image.asset('assets/images/Ellipse_1.png', width: 250, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const SizedBox()),
          ),
          Positioned(
            top: -30, right: -30,
            child: Image.asset('assets/images/Ellipse_2.png', width: 250, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const SizedBox()),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 20.0, bottom: 30.0), 
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

                          // --- 2. PASANG CONTROLLER KE MASING-MASING KOLOM ---
                          _buildInputField(
                            label: 'Email', 
                            hint: 'Jony@Gmail.com',
                            controller: _emailController, // Pasang!
                            keyboardType: TextInputType.emailAddress, 
                          ),
                          
                          _buildInputField(
                            label: 'Nama Lengkap', 
                            hint: 'Abdusi Salam',
                            controller: _namaController, // Pasang!
                          ),
                          
                          _buildInputField(
                            label: 'Tanggal Lahir',
                            hint: '18/03/2024',
                            controller: _dobController, // Pasang!
                            readOnly: true,             
                            onTap: () => _selectDate(context),
                            suffix: const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20),
                          ),

                          _buildInputField(
                            label: 'Nomer HP',
                            hint: '089-726-0592',
                            controller: _phoneController, // Pasang!
                            keyboardType: TextInputType.number, // Fix bug emulator!
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
                            prefix: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🇮🇩', style: TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Container(height: 24, width: 1, color: Colors.black12), 
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ),

                          _buildInputField(
                            label: 'Masukan Password',
                            hint: '********',
                            controller: _passwordController, // Pasang!
                            isPassword: _obscureText, 
                            suffix: IconButton(
                              icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 20),
                              onPressed: () {
                                setState(() { _obscureText = !_obscureText; });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- 3. LOGIKA TOMBOL REGISTER (VALIDASI) ---
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Tarik semua teks dari controller
                                String email = _emailController.text;
                                String nama = _namaController.text;
                                String dob = _dobController.text;
                                String phone = _phoneController.text;
                                String password = _passwordController.text;

                                // Cek apakah ada yang kosong
                                if (email.isEmpty || nama.isEmpty || dob.isEmpty || phone.isEmpty || password.isEmpty) {
                                  // Tampilkan peringatan merah elegan
                                  _showSnackBar('Mohon lengkapi semua kolom pendaftaran!', const Color(0xFFEF4444));
                                } else {
                                  // Jika sukses, tampilkan hijau sebentar lalu pindah ke Login
                                  _showSnackBar('Registrasi Berhasil!', Colors.green);
                                  
                                  // Tunggu 1 detik biar user baca pesannya, lalu mundur ke halaman Login
                                  Future.delayed(const Duration(seconds: 1), () {
                                    if (!mounted) return; // <--- TAMBAHKAN BARIS PENGAMAN INI
                                    
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB), 
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Register',
                                style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
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
        ],
      ),
    );
  }
}