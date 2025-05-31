// lib/views/widgets/register_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/helper.dart' as helper; // Menggunakan helper Anda
import '../../routes/route_name.dart';
import '../utils/form_validaror.dart';
import '../../services/database_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  Future<void> _showSuccessDialogAndNavigate(
    BuildContext context,
    String message,
    String routeName,
  ) async {
    void navigateAction() {
      if (mounted) {
        context.goNamed(routeName);
      }
    }

    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
            navigateAction();
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Theme.of(
            context,
          ).cardColor, // Menggunakan warna kartu dari tema
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              helper.vsMedium,
              Icon(
                Icons.check_circle_outline_rounded,
                color: helper.cSuccess,
                size: 60.0,
              ),
              helper.vsMedium,
              Text(
                message,
                textAlign: TextAlign.center,
                style: helper.subtitle1.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color, // Warna teks dari tema
                  fontWeight: helper.bold,
                ),
              ),
              helper.vsMedium,
            ],
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: helper.cWhite)),
        backgroundColor: helper.cError,
        behavior: SnackBarBehavior.floating, // Membuat SnackBar mengambang
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _attemptRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String username = _usernameController.text.trim();
        String email = _emailController.text.trim();
        String password = _passwordController.text;
        Map<String, dynamic> result = await DatabaseHelper.instance
            .registerUser(username, email, password);

        if (!mounted) return;

        if (result['success']) {
          await _showSuccessDialogAndNavigate(
            context,
            result['message'],
            RouteName.login,
          );
        } else {
          _showErrorSnackBar(result['message']);
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar(
            'Terjadi kesalahan saat registrasi. Silakan coba lagi.',
          );
        }
        debugPrint('Error di _attemptRegister: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      debugPrint('Form tidak valid, silakan periksa input Anda.');
    }
  }

  // Helper widget untuk membangun TextFormField (mirip dengan LoginScreen)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIconData,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
    TextInputAction textInputAction = TextInputAction.next,
    required Color contentColor,
    required Color hintColorValue,
    required Color fillColorValue,
    required Color focusedBorderColor,
    required Color enabledBorderColor,
  }) {
    final ThemeData theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: isPassword && !isPasswordVisible,
      style: helper.subtitle1.copyWith(color: contentColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: helper.subtitle2.copyWith(color: hintColorValue),
        prefixIcon: Icon(
          prefixIconData,
          color: contentColor.withOpacity(0.8),
          size: 22,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: hintColorValue,
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        filled: true,
        fillColor: fillColorValue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: enabledBorderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
      ),
      keyboardType: isPassword
          ? TextInputType.visiblePassword
          : (prefixIconData == Icons.email_outlined
                ? TextInputType.emailAddress
                : TextInputType.text),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: textInputAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? defaultFontFamily = helper.headline1.fontFamily;
    final screenHeight = MediaQuery.of(context).size.height;

    // Warna untuk kontras di atas gambar latar (mirip LoginScreen)
    final Color overlayColor = Colors.black.withOpacity(
      0.40,
    ); // Lebih gelap untuk kontras lebih baik
    final Color textOnBgColor = helper.cWhite;
    final Color primaryColorOnBg =
        helper.cPrimary; // Bisa disesuaikan jika cPrimary tidak kontras
    final Color fieldFillColor = Colors.white.withOpacity(0.15);
    final Color fieldHintColor = Colors.white.withOpacity(0.7);
    final Color fieldEnabledBorderColor = Colors.white.withOpacity(0.3);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gambar Latar Belakang (opsional, ganti dengan path aset Anda)
          Image.asset(
            'assets/images/iconlogin1.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: theme.colorScheme.background); // Fallback
            },
          ),
          Container(color: overlayColor), // Overlay gelap

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Salam Pembuka
                        Text(
                          'Create Account', // Judul lebih jelas
                          textAlign: TextAlign.center,
                          style: helper.headline1.copyWith(
                            color: textOnBgColor,
                            fontWeight: helper.bold,
                            fontFamily: defaultFontFamily,
                            fontSize: 34, // Sedikit penyesuaian ukuran
                            shadows: [
                              const Shadow(
                                blurRadius: 4,
                                color: Colors.black54,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        helper.vsSmall,
                        Text(
                          'Join us and start your journey!', // Subtitle
                          textAlign: TextAlign.center,
                          style: helper.subtitle1.copyWith(
                            color: textOnBgColor.withOpacity(0.9),
                            fontSize: 16,
                            shadows: [
                              const Shadow(
                                blurRadius: 3,
                                color: Colors.black45,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),

                        // Input Username
                        _buildTextField(
                          controller: _usernameController,
                          hintText: 'Enter your username',
                          prefixIconData: Icons.person_outline_rounded,
                          validator: AppValidators.validateName,
                          contentColor: textOnBgColor,
                          hintColorValue: fieldHintColor,
                          fillColorValue: fieldFillColor,
                          focusedBorderColor: primaryColorOnBg,
                          enabledBorderColor: fieldEnabledBorderColor,
                        ),
                        helper.vsMedium,

                        // Input Email
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Enter your email',
                          prefixIconData: Icons.alternate_email_rounded,
                          validator: AppValidators.validateEmail,
                          contentColor: textOnBgColor,
                          hintColorValue: fieldHintColor,
                          fillColorValue: fieldFillColor,
                          focusedBorderColor: primaryColorOnBg,
                          enabledBorderColor: fieldEnabledBorderColor,
                        ),
                        helper.vsMedium,

                        // Input Password
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'Create a password',
                          prefixIconData: Icons.lock_outline_rounded,
                          validator: AppValidators.validatePassword,
                          isPassword: true,
                          isPasswordVisible: _isPasswordVisible,
                          onVisibilityToggle: () => setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          }),
                          contentColor: textOnBgColor,
                          hintColorValue: fieldHintColor,
                          fillColorValue: fieldFillColor,
                          focusedBorderColor: primaryColorOnBg,
                          enabledBorderColor: fieldEnabledBorderColor,
                        ),
                        helper.vsMedium,

                        // Input Confirm Password
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm your password',
                          prefixIconData: Icons.lock, // Ikon baru
                          validator: _validateConfirmPassword,
                          isPassword: true,
                          isPasswordVisible: _isConfirmPasswordVisible,
                          onVisibilityToggle: () => setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          }),
                          textInputAction:
                              TextInputAction.done, // Aksi terakhir
                          contentColor: textOnBgColor,
                          hintColorValue: fieldHintColor,
                          fillColorValue: fieldFillColor,
                          focusedBorderColor: primaryColorOnBg,
                          enabledBorderColor: fieldEnabledBorderColor,
                        ),
                        SizedBox(height: screenHeight * 0.04),

                        // Tombol Register
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _attemptRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColorOnBg,
                              foregroundColor: helper.cWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 5.0,
                              textStyle: helper.subtitle1.copyWith(
                                fontWeight: helper.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('REGISTER'),
                          ),
                        ),
                        helper.vsLarge,

                        // Link ke Halaman Login
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: helper.subtitle2.copyWith(
                                color: textOnBgColor.withOpacity(0.85),
                                fontFamily: defaultFontFamily,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Sign In Here', // Teks lebih ajakan
                                  style: helper.subtitle2.copyWith(
                                    color: primaryColorOnBg, // Warna primer
                                    fontWeight: helper.bold,
                                    fontFamily: defaultFontFamily,
                                    decoration: TextDecoration.underline,
                                    decorationColor: primaryColorOnBg,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () =>
                                        context.goNamed(RouteName.login),
                                ),
                              ],
                            ),
                          ),
                        ),
                        helper.vsMedium,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
