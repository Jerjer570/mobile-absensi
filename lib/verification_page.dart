import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'new_password_page.dart';
import 'services/auth_service.dart'; 

class VerificationPage extends StatefulWidget {
  final String email;
  const VerificationPage({super.key, required this.email});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final List<String> _otpValues = ["", "", "", "", "", ""];
  
  bool _isLoading = false; 

  Widget _otpBox(BuildContext context, {required int index, bool first = false, bool last = false}) {
    return SizedBox(
      height: 64,
      width: 48, // Sedikit diperkecil agar pas di layar HP yang lebih ramping (6 kotak)
      child: TextField(
        autofocus: first, 
        onChanged: (value) {
          _otpValues[index] = value;

          if (value.length == 1 && !last) {
            FocusScope.of(context).nextFocus(); 
          }
          if (value.isEmpty && !first) {
            FocusScope.of(context).previousFocus(); 
          }
        },
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1), 
          FilteringTextInputFormatter.digitsOnly, 
        ],
        style: const TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "", 
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black26, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2.0),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Helper widget untuk mempermudah pemanggilan snackbar pesan error/sukses
  void _showCustomSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
        duration: const Duration(seconds: 3),
      ),
    );
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
        centerTitle: true, 
        title: const Text(
          'Lupa Password',
          style: TextStyle(fontFamily: 'Inter', color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text(
                'Verifikasi',
                style: TextStyle(fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 12),
              Text(
                'Silakan masukkan kode yang\ntelah kami kirimkan ke ${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _otpBox(context, index: 0, first: true),
                  _otpBox(context, index: 1),
                  _otpBox(context, index: 2),
                  _otpBox(context, index: 3),
                  _otpBox(context, index: 4),
                  _otpBox(context, index: 5, last: true),
                ],
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  const Text('Tidak Menerima Kode?', style: TextStyle(fontFamily: 'Inter', color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _isLoading ? null : () => debugPrint("Kirim ulang kode OTP..."),
                    child: const Text(
                      'Kirim Ulang Kode?',
                      style: TextStyle(fontFamily: 'Inter', color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '1 of 2',
                    style: TextStyle(fontFamily: 'Inter', color: Color(0xFF1E3A8A), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 6), 
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading 
                      ? null 
                      : () async {
                          String fullOtp = _otpValues.join(""); 

                          if (fullOtp.length < 6) {
                            _showCustomSnackBar('Mohon isi 6 digit kode verifikasi terlebih dahulu!', const Color(0xFFEF4444));
                          } else {
                            setState(() {
                              _isLoading = true;
                            });
                            final result = await AuthService().verifyOtp(widget.email, fullOtp);
                            setState(() {
                              _isLoading = false;
                            });

                            if (result['success'] == true) {
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewPasswordPage(
                                      email: widget.email, // Mengirim email
                                      otp: fullOtp,        // Mengirim string kode OTP lengkap (6 digit)
                                    ),
                                  ),
                                );
                              }
                            } else {
                              _showCustomSnackBar(result['message'] ?? 'Terjadi kesalahan.', const Color(0xFFEF4444));
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  // Mengubah teks button menjadi loading spinner kecil saat request diproses
                  child: _isLoading 
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}