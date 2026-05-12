import 'dart:convert';
import 'package:flutter/material.dart';
import 'verification_page.dart';
import 'package:http/http.dart' as http;
import 'services/api_constants.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  final TextEditingController _emailController =
      TextEditingController();

  bool _isLoading = false;

  Future<void> _sendForgotPassword() async {

    // VALIDASI EMAIL
    if (_emailController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email wajib diisi"),
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      final response = await http.post(
        Uri.parse(ApiConstants.forgotPassword),

        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({
          "email": _emailController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      // BERHASIL
      if (response.statusCode == 200) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"]),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationPage(
              email: _emailController.text.trim(),
            ),
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ?? "Terjadi kesalahan",
            ),
          ),
        );

      }

    } catch (e) {

      debugPrint("Error : $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal terhubung ke server"),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          _isLoading = false;
        });

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
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),

          child: Column(
            children: [

              const SizedBox(height: 20),

              const Text(
                'Lupa Password ?',

                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // UI TETAP SAMA
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 2.0,
                  ),

                  borderRadius:
                      BorderRadius.circular(16),
                ),

                child: Stack(
                  children: [

                    Image.asset(
                      'assets/images/Picture.png',

                      errorBuilder:
                          (context, error, stackTrace) {

                        return const Icon(
                          Icons.warning,
                          color: Colors.red,
                        );
                      },
                    ),

                    Align(
                      alignment: Alignment.topRight,

                      child: Image.asset(
                        'assets/images/icon.png',
                        height: 40,

                        errorBuilder:
                            (context, error, stackTrace) {

                          return const Icon(
                            Icons.warning,
                            color: Colors.red,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: _emailController,

                decoration: InputDecoration(
                  hintText: "Masukkan Email",

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(

                  onPressed:
                      _isLoading
                          ? null
                          : _sendForgotPassword,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                  ),

                  child:
                      _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )

                          : const Text(
                              "Berikutnya",

                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}