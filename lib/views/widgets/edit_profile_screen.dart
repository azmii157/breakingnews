import 'dart:io';
import 'package:breaknews/views/utils/form_validaror.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/edit_profile_controller.dart';
import '../utils/helper.dart' as helper;

class EditProfileScreen extends StatefulWidget {
  final int userId;

  const EditProfileScreen({super.key, required this.userId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  void _showImageSourceActionSheet(
    BuildContext context,
    EditProfileController controller,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.photo_library_rounded,
                  color: helper.cPrimary,
                ),
                title: Text(
                  'Pilih dari Galeri',
                  style: helper.subtitle1.copyWith(color: helper.cTextBlue),
                ),
                onTap: () {
                  controller.pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: helper.cPrimary),
                title: Text(
                  'Ambil Foto dari Kamera',
                  style: helper.subtitle1.copyWith(color: helper.cTextBlue),
                ),
                onTap: () {
                  controller.pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              if (controller.selectedImageFile != null ||
                  controller.currentProfileImagePathFromDb != null)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: helper.cError,
                  ),
                  title: Text(
                    'Hapus Foto Profil',
                    style: helper.subtitle1.copyWith(color: helper.cError),
                  ),
                  onTap: () {
                    controller.removeProfileImage();
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: helper.subtitle1.copyWith(
            color: helper.cTextBlue,
            fontWeight: helper.medium,
          ),
        ),
        helper.vsSuperTiny,
        TextFormField(
          controller: controller,
          validator: validator,
          style: helper.subtitle1.copyWith(color: helper.cTextBlue),
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
            hintStyle: helper.subtitle2.copyWith(color: helper.cLinear),
            prefixIcon: Icon(icon, color: helper.cTextBlue, size: 22),
            filled: true,
            fillColor: readOnly ? helper.cGrey.withOpacity(0.4) : helper.cGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: helper.cPrimary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
          ),
          keyboardType: keyboardType,
          readOnly: readOnly,
          maxLines: maxLines,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        helper.vsMedium,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditProfileController(userId: widget.userId),
      child: Scaffold(
        backgroundColor: helper.cWhite,
        appBar: AppBar(
          backgroundColor: helper.cwhite,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: helper.cBlack),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Edit Profil',
            style: helper.headline4.copyWith(
              color: helper.cBlack,
              fontSize: 18,
            ),
          ),
          actions: [
            Consumer<EditProfileController>(
              builder: (context, controller, child) {
                return TextButton(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            Map<String, dynamic> result = await controller
                                .saveProfileChanges(widget.userId);
                            if (context.mounted) {
                              if (result['success']) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result['message'],
                                      style: TextStyle(color: helper.cWhite),
                                    ),
                                    backgroundColor: helper.cSuccess,
                                  ),
                                );
                                context.pop(true);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result['message'],
                                      style: TextStyle(color: helper.cWhite),
                                    ),
                                    backgroundColor: helper.cError,
                                  ),
                                );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Harap periksa kembali input Anda.',
                                  style: TextStyle(color: helper.cWhite),
                                ),
                                backgroundColor: helper.cError,
                              ),
                            );
                          }
                        },
                  child: controller.isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                helper.cWhite,
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            'Simpan',
                            style: helper.subtitle1.copyWith(
                              color: helper.cBlack,
                              fontWeight: helper.bold,
                            ),
                          ),
                        ),
                );
              },
            ),
          ],
        ),
        body: Consumer<EditProfileController>(
          builder: (context, controller, child) {
            if (controller.isLoading &&
                controller.usernameController.text.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(helper.cPrimary),
                ),
              );
            }
            if (controller.errorMessage != null &&
                controller.usernameController.text.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    controller.errorMessage!,
                    style: helper.subtitle1.copyWith(color: helper.cError),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            Widget profileImageWidget;
            if (controller.selectedImageFile != null) {
              profileImageWidget = Image.file(
                controller.selectedImageFile!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              );
            } else if (controller.currentProfileImagePathFromDb != null &&
                controller.currentProfileImagePathFromDb!.isNotEmpty) {
              profileImageWidget = Image.file(
                File(controller.currentProfileImagePathFromDb!),
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Icon(
                  Icons.person_rounded,
                  size: 80,
                  color: helper.cLinear.withOpacity(0.7),
                ),
              );
            } else {
              profileImageWidget = Icon(
                Icons.person_rounded,
                size: 80,
                color: helper.cLinear.withOpacity(0.7),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () =>
                          _showImageSourceActionSheet(context, controller),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: helper.cGrey,
                            child: ClipOval(child: profileImageWidget),
                          ),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: helper.cPrimary.withOpacity(0.85),
                            child: Icon(
                              Icons.edit_rounded,
                              color: helper.cWhite,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    helper.vsLarge,

                    _buildTextField(
                      controller: controller.usernameController,
                      label: "Nama Pengguna (Username)",
                      icon: Icons.person_outline_rounded,
                      validator: AppValidators.validateName,
                    ),
                    _buildTextField(
                      controller: controller.emailController,
                      label: "Email",
                      icon: Icons.email_outlined,
                      validator: AppValidators.validateEmail,
                      readOnly: true,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      controller: controller.phoneController,
                      label: "Nomor Telepon",
                      icon: Icons.phone_outlined,
                      validator: AppValidators.validatePhoneNumber,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextField(
                      controller: controller.addressController,
                      label: "Alamat",
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                    ),
                    _buildTextField(
                      controller: controller.cityController,
                      label: "Kota",
                      icon: Icons.location_city_outlined,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
