// lib/views/widgets/change_password_screen.dart
import 'package:breaknews/views/utils/form_validaror.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../controllers/change_password_controller.dart';
import '../../utils/helper.dart' as helper;

// import '../../../utils/validators.dart';
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  Widget _buildPasswordField({
    required BuildContext context, // Tambahkan BuildContext
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    required String? Function(String?) validator,
  }) {
    final ThemeData theme = Theme.of(context); // Ambil tema di sini
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText,
            style: theme.textTheme.titleSmall?.copyWith(
                color: theme.textTheme.bodyMedium?.color,
                fontWeight: helper.medium)),
        helper.vsSuperTiny,
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          validator: validator,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle:
                theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            prefixIcon: Icon(Icons.lock_outline_rounded,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                size: 22),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: theme.hintColor,
              ),
              onPressed: onVisibilityToggle,
            ),
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? Colors.grey.shade800.withOpacity(0.5)
                : helper.cGrey.withOpacity(0.7),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: theme.colorScheme.primary, width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: theme.colorScheme.error, width: 1.0)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: theme.colorScheme.error, width: 1.5)),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        helper.vsMedium,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    return ChangeNotifierProvider(
      create: (_) => ChangePasswordController(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: theme.appBarTheme.foregroundColor),
            onPressed: () => context.pop(),
          ),
          title: Text('Ubah Password', style: theme.appBarTheme.titleTextStyle),
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: theme.appBarTheme.elevation,
        ),
        body: Consumer<ChangePasswordController>(
          builder: (context, controller, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Untuk keamanan akun Anda, mohon jangan sebarkan password Anda kepada siapapun.',
                      style: textTheme.bodyMedium?.copyWith(
                          color: textTheme.bodyMedium?.color?.withOpacity(0.8)),
                      textAlign: TextAlign.center,
                    ),
                    helper.vsLarge,
                    _buildPasswordField(
                      context: context, // Teruskan context
                      controller: controller.oldPasswordController,
                      labelText: 'Password Lama',
                      hintText: 'Masukkan password lama Anda',
                      isVisible: controller.isOldPasswordVisible,
                      onVisibilityToggle:
                          controller.toggleOldPasswordVisibility,
                      validator: (value) {
                        // Validator sederhana, validasi utama ada di controller
                        if (value == null || value.isEmpty) {
                          return 'Password lama tidak boleh kosong.';
                        }
                        return null;
                      },
                    ),
                    _buildPasswordField(
                      context: context, // Teruskan context
                      controller: controller.newPasswordController,
                      labelText: 'Password Baru',
                      hintText: 'Minimal 8 karakter',
                      isVisible: controller.isNewPasswordVisible,
                      onVisibilityToggle:
                          controller.toggleNewPasswordVisibility,
                      validator: AppValidators.validatePassword,
                    ),
                    _buildPasswordField(
                      context: context, // Teruskan context
                      controller: controller.confirmNewPasswordController,
                      labelText: 'Konfirmasi Password Baru',
                      hintText: 'Ulangi password baru Anda',
                      isVisible: controller.isConfirmNewPasswordVisible,
                      onVisibilityToggle:
                          controller.toggleConfirmNewPasswordVisibility,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password tidak boleh kosong.';
                        }
                        if (value != controller.newPasswordController.text) {
                          return 'Password baru tidak cocok.';
                        }
                        return null;
                      },
                    ),
                    helper.vsLarge,
                    if (controller.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          controller.errorMessage!,
                          style: textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (controller.successMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          controller.successMessage!,
                          style: textTheme.bodyMedium?.copyWith(
                              color: helper
                                  .cSuccess), // Gunakan warna sukses dari helper
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ElevatedButton(
                      onPressed: controller.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                FocusScope.of(context)
                                    .unfocus(); // Tutup keyboard
                                bool success =
                                    await controller.changePassword();
                                if (success && mounted) {
                                  // Cek mounted
                                  // Password berhasil diubah, dialog sukses akan muncul dari controller jika ada
                                  // Anda bisa tambahkan navigasi pop atau pesan lain jika mau
                                  // Setelah sukses, field sudah di-clear oleh controller
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        controller.successMessage ??
                                            'Password berhasil diubah!',
                                        style: TextStyle(color: helper.cWhite)),
                                    backgroundColor: helper.cSuccess,
                                  ));
                                  // Mungkin delay sedikit lalu pop? atau biarkan user pop manual
                                  Future.delayed(const Duration(seconds: 1),
                                      () {
                                    if (mounted) context.pop();
                                  });
                                }
                                // Pesan error sudah dihandle dengan _errorMessage dan ditampilkan di atas tombol
                                // atau bisa juga dengan SnackBar jika _errorMessage di controller tidak null
                                else if (controller.errorMessage != null &&
                                    mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(controller.errorMessage!,
                                        style: TextStyle(color: helper.cWhite)),
                                    backgroundColor: helper.cError,
                                  ));
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textStyle: textTheme.labelLarge,
                      ),
                      child: controller.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white)))
                          : const Text('Ubah Password'),
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
