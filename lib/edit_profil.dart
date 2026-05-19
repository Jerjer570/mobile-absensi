import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _addressController =
      TextEditingController();

  final TextEditingController _dateController =
      TextEditingController();

  final TextEditingController _genderController =
      TextEditingController();

  // =========================================================
  // VARIABLE
  // =========================================================

  final Color navyColor = const Color(0xFF20295F);

  bool _isLoading = false;

  File? _imageFile;

  String? _existingPhotoUrl;

  // =========================================================
  // INIT
  // =========================================================

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
  // FETCH PROFILE
  // =========================================================

  Future<void> _fetchProfileData() async {

    setState(() {
      _isLoading = true;
    });

    try {

      final prefs =
          await SharedPreferences.getInstance();

      final token =
          prefs.getString('auth_token');

      final userId =
          prefs.getInt('user_id');

      if (token == null || userId == null) {
        return;
      }

      final response = await http.get(
        Uri.parse(
          "${ApiConstants.updateProfile}/$userId",
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print(response.body);

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body)['data'];

        setState(() {

          _nameController.text =
              data['nama_lengkap'] ?? '';

          _emailController.text =
              data['email'] ?? '';

          _phoneController.text =
              data['no_hp'] ?? '';

          _addressController.text =
              data['alamat'] ?? '';

          _dateController.text =
              data['tanggal_lahir'] ?? '';

          _genderController.text =
              data['jenis_kelamin'] ?? '';

          _existingPhotoUrl =
              data['foto_profile'];

        });
      }

    } catch (e) {

      print("ERROR FETCH PROFILE: $e");

    } finally {

      setState(() {
        _isLoading = false;
      });

    }
  }

  // =========================================================
  // PICK IMAGE
  // =========================================================

  Future<void> _pickImage(
      ImageSource source) async {

    try {

      final ImagePicker picker =
          ImagePicker();

      final XFile? image =
          await picker.pickImage(
        source: source,
        imageQuality: 50,
      );

      if (image != null) {

        setState(() {
          _imageFile = File(image.path);
        });

      }

    } catch (e) {

      print("Error Pick Image: $e");

    }
  }

  // =========================================================
  // SHOW PICKER
  // =========================================================

  void _showPicker() {

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {

        return SafeArea(
          child: Wrap(
            children: [

              ListTile(
                leading:
                    const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () async {

                  Navigator.pop(context);

                  await _pickImage(
                    ImageSource.gallery,
                  );
                },
              ),

              ListTile(
                leading:
                    const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () async {

                  Navigator.pop(context);

                  await _pickImage(
                    ImageSource.camera,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // SELECT DATE
  // =========================================================

  Future<void> _selectDate() async {

    DateTime? picked =
        await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );

    if (picked != null) {

      setState(() {

        _dateController.text =
            "${picked.year}-"
            "${picked.month.toString().padLeft(2, '0')}-"
            "${picked.day.toString().padLeft(2, '0')}";

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Pilih Jenis Kelamin",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.male,
                  color: Colors.blue,
                ),
                title:
                    const Text("Laki - Laki"),
                onTap: () {

                  setState(() {
                    _genderController.text =
                        "Laki - Laki";
                  });

                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.female,
                  color: Colors.pink,
                ),
                title:
                    const Text("Perempuan"),
                onTap: () {

                  setState(() {
                    _genderController.text =
                        "Perempuan";
                  });

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // UPDATE PROFILE
  // =========================================================

  Future<void> _updateProfile() async {

    setState(() {
      _isLoading = true;
    });

    try {

      final prefs =
          await SharedPreferences.getInstance();

      final token =
          prefs.getString('auth_token');

      final userId =
          prefs.getInt('user_id');

      if (token == null || userId == null) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Session habis",
            ),
          ),
        );

        return;
      }

      final url = Uri.parse(
        "${ApiConstants.updateProfile}/$userId",
      );

      var request =
          http.MultipartRequest(
        'POST',
        url,
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['email'] =
          _emailController.text;

      request.fields['nama_lengkap'] =
          _nameController.text;

      request.fields['no_hp'] =
          _phoneController.text;

      request.fields['alamat'] =
          _addressController.text;

      request.fields['tanggal_lahir'] =
          _dateController.text;

      request.fields['jenis_kelamin'] =
          _genderController.text;

      request.fields['device_id'] =
          'android_001';

      if (_imageFile != null) {

        request.files.add(
          await http.MultipartFile.fromPath(
            'foto_profile',
            _imageFile!.path,
          ),
        );

      }

      var response =
          await request.send();

      var res =
          await http.Response.fromStream(
              response);

      final data =
          jsonDecode(res.body);

      print(data);

      if (response.statusCode == 200) {

        if (mounted) {

          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                "Profil berhasil diperbarui",
              ),
            ),
          );

          Navigator.pop(context, true);

        }

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ??
                  "Gagal update profile",
            ),
          ),
        );

      }

    } catch (e) {

      print("ERROR UPDATE: $e");

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Terjadi kesalahan",
          ),
        ),
      );

    } finally {

      setState(() {
        _isLoading = false;
      });

    }
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: _isLoading &&
              _nameController.text.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
              ),

              child: Column(
                children: [

                  const SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: _showPicker,

                      child: Stack(
                        children: [

                          Container(
                            width: 140,
                            height: 140,

                            decoration:
                                BoxDecoration(
                              shape:
                                  BoxShape.circle,

                              border: Border.all(
                                color: navyColor,
                                width: 1.5,
                              ),

                              color: Colors
                                  .grey.shade200,

                              image:
                                  _imageFile !=
                                          null
                                      ? DecorationImage(
                                          image:
                                              FileImage(
                                            _imageFile!,
                                          ),
                                          fit: BoxFit
                                              .cover,
                                        )
                                      : (_existingPhotoUrl !=
                                              null
                                          ? DecorationImage(
                                              image:
                                                  NetworkImage(
                                                _existingPhotoUrl!,
                                              ),
                                              fit: BoxFit
                                                  .cover,
                                            )
                                          : null),
                            ),

                            child: _imageFile ==
                                        null &&
                                    _existingPhotoUrl ==
                                        null
                                ? const Icon(
                                    Icons.person,
                                    size: 80,
                                    color:
                                        Colors.grey,
                                  )
                                : null,
                          ),

                          Positioned(
                            bottom: 10,
                            right: 5,

                            child: Container(
                              padding:
                                  const EdgeInsets
                                      .all(6),

                              decoration:
                                  const BoxDecoration(
                                color: Color(
                                    0xFF5C607E),
                                shape:
                                    BoxShape.circle,
                              ),

                              child: const Icon(
                                Icons.camera_alt,
                                color:
                                    Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildInputField(
                    label: 'Nama',
                    controller:
                        _nameController,
                  ),

                  const SizedBox(height: 16),

                  _buildInputField(
                    label: 'Email',
                    controller:
                        _emailController,
                    keyboardType:
                        TextInputType
                            .emailAddress,
                  ),

                  const SizedBox(height: 16),

                  _buildInputField(
                    label: 'No HP',
                    controller:
                        _phoneController,
                    keyboardType:
                        TextInputType.phone,
                  ),

                  const SizedBox(height: 16),

                  _buildInputField(
                    label: 'Alamat',
                    controller:
                        _addressController,
                  ),

                  const SizedBox(height: 16),

                  _buildInputField(
                    label: 'Tanggal Lahir',
                    controller:
                        _dateController,
                    suffixIcon:
                        Icons.calendar_today,
                    readOnly: true,
                    onTap: _selectDate,
                  ),

                  const SizedBox(height: 16),

                  _buildInputField(
                    label: 'Jenis Kelamin',
                    controller:
                        _genderController,
                    suffixIcon:
                        Icons.keyboard_arrow_down,
                    readOnly: true,
                    onTap: _selectGender,
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : _updateProfile,

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            navyColor,
                      ),

                      child: Text(
                        _isLoading
                            ? 'Memproses...'
                            : 'Save Changes',

                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // =========================================================
  // INPUT FIELD
  // =========================================================

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType =
        TextInputType.text,
    IconData? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          label,

          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,

          decoration: InputDecoration(

            filled: readOnly,

            fillColor: readOnly
                ? Colors.grey.shade100
                : Colors.transparent,

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 15,
            ),

            suffixIcon: suffixIcon != null
                ? Icon(
                    suffixIcon,
                    color: Colors.black,
                  )
                : null,

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(8),
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(8),

              borderSide: BorderSide(
                color:
                    Colors.grey.shade300,
              ),
            ),

            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(8),

              borderSide: BorderSide(
                color: navyColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}