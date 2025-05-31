// lib/views/widgets/login_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/helper.dart' as helper; // Menggunakan helper Anda
import '../../routes/route_name.dart';
import '../utils/form_validaror.dart';
import '../../services/database_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
          backgroundColor: Theme.of(context).cardColor,
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
                  color: Theme.of(context).textTheme.bodyLarge?.color,
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _attemptLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String email = _emailController.text.trim();
        String password = _passwordController.text;

        Map<String, dynamic> result = await DatabaseHelper.instance.loginUser(
          email,
          password,
        );

        if (!mounted) return;

        if (result['success']) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('currentUserId', result['userId']);
          await prefs.setString('currentUsername', result['username']);
          await prefs.setString('currentUserEmail', email);
          debugPrint(
            'Login sukses, userId: ${result['userId']}, username: ${result['username']} disimpan.',
          );

          await _showSuccessDialogAndNavigate(
            context,
            result['message'],
            RouteName.home,
          );
        } else {
          _showErrorSnackBar(result['message']);
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar(
            'Terjadi kesalahan saat login. Silakan coba lagi.',
          );
        }
        debugPrint('Error di _attemptLogin: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      debugPrint('Form tidak valid.');
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIconData,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
    required Color contentColor, // Warna untuk teks input dan ikon prefix
    required Color hintColorValue, // Warna untuk hint text
    required Color fillColorValue, // Warna untuk isian field
    required Color focusedBorderColor, // Warna border saat fokus
    required Color enabledBorderColor, // Warna border saat enable
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
          color: contentColor.withOpacity(
            0.8,
          ), // Ikon sedikit lebih transparan dari teks
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
          : TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? defaultFontFamily = helper.headline1.fontFamily;
    final screenHeight = MediaQuery.of(context).size.height;

    // Tentukan warna berdasarkan mode tema untuk kontras di atas gambar latar
    // Jika gambar latar gelap, teks harus terang, dan sebaliknya.
    // Untuk contoh ini, saya asumsikan gambar latar Anda bisa gelap atau terang,
    // jadi kita buat overlay gelap dan teks terang.
    final Color overlayColor = Colors.black.withOpacity(
      0.50,
    ); // Overlay gelap untuk kontras
    final Color textOnBgColor = helper.cWhite; // Teks putih di atas overlay
    final Color primaryColorOnBg =
        helper.cPrimary; // Warna primer untuk aksen, pastikan kontras
    final Color fieldFillColor = Colors.white.withOpacity(
      0.15,
    ); // Isian field semi-transparan
    final Color fieldHintColor = Colors.white.withOpacity(0.7);
    final Color fieldEnabledBorderColor = Colors.white.withOpacity(0.3);

    return Scaffold(
      // backgroundColor tidak di-set di sini agar Stack bisa mengisi layar
      body: Stack(
        // Gunakan Stack untuk menumpuk gambar latar dan konten
        fit: StackFit.expand, // Agar Stack mengisi seluruh layar
        children: [
          // 1. Gambar Latar Belakang
          Image.asset(
            'assets/images/iconlogin1.png', // GANTI DENGAN PATH GAMBAR LATAR ANDA
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback jika gambar gagal dimuat
              return Container(color: theme.colorScheme.background);
            },
          ),

          // 2. Overlay Gelap (Opsional, untuk meningkatkan kontras teks)
          Container(color: overlayColor),

          // 3. Konten Utama (Form Login)
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                ), // Lebar maksimal form
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Pusatkan konten secara vertikal
                      children: [
                        // Salam Pembuka
                        Text(
                          'Hello Again!',
                          textAlign: TextAlign.center,
                          style: helper.headline1.copyWith(
                            color: textOnBgColor, // Teks putih
                            fontWeight: helper.bold,
                            fontFamily: defaultFontFamily,
                            fontSize: 38, // Sedikit lebih besar
                            shadows: [
                              // Bayangan untuk keterbacaan
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
                          'Welcome back, you\'ve been missed!',
                          textAlign: TextAlign.center,
                          style: helper.subtitle1.copyWith(
                            color: textOnBgColor.withOpacity(
                              0.9,
                            ), // Teks putih dengan sedikit transparansi
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
                        SizedBox(height: screenHeight * 0.07),

                        // Input Email
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Enter your email',
                          prefixIconData: Icons.alternate_email_rounded,
                          validator: AppValidators.validateEmail,
                          contentColor:
                              textOnBgColor, // Warna teks di dalam field
                          hintColorValue: fieldHintColor,
                          fillColorValue: fieldFillColor,
                          focusedBorderColor:
                              primaryColorOnBg, // Warna primer untuk fokus
                          enabledBorderColor: fieldEnabledBorderColor,
                        ),
                        helper.vsMedium,

                        // Input Password
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'Enter your password',
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.pushNamed(RouteName.forgotPassword);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: helper.subtitle2.copyWith(
                                color: primaryColorOnBg.withOpacity(0.9),
                              ), // Warna primer
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),

                        // Tombol Login
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _attemptLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  primaryColorOnBg, // Warna primer dari helper
                              foregroundColor:
                                  helper.cWhite, // Teks putih di atas tombol
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 5.0, // Bayangan lebih tegas
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
                                : const Text('LOGIN'),
                          ),
                        ),
                        helper.vsLarge,

                        // Link ke Halaman Sign Up
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: 'Don’t have an account? ',
                              style: helper.subtitle2.copyWith(
                                color: textOnBgColor.withOpacity(
                                  0.85,
                                ), // Teks putih
                                fontFamily: defaultFontFamily,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Sign Up Now',
                                  style: helper.subtitle2.copyWith(
                                    color: primaryColorOnBg, // Warna primer
                                    fontWeight: helper.bold,
                                    fontFamily: defaultFontFamily,
                                    decoration: TextDecoration.underline,
                                    decorationColor: primaryColorOnBg,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () =>
                                        context.goNamed(RouteName.register),
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
