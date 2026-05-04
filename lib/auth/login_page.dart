import 'package:cashier/controller/authcontroller.dart';
import 'package:cashier/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final AuthController _auth = Get.find<AuthController>();

  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onLoginTap() {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      Get.rawSnackbar(
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        backgroundColor: AppColors.danger,
        duration: const Duration(seconds: 3),
        icon: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Icon(
            Icons.error_outline_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        messageText: const Text(
          'Username dan password tidak boleh kosong',
          style: TextStyle(
            fontFamily: 'm',
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      return;
    }

    _auth.login(username, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo ──────────────────────────────────────────────────
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.navy.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/logo_cropped.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.store_rounded,
                            size: 48,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── App name ──────────────────────────────────────────────
                  const Text(
                    'Kasir Kilat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'm',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ── Subtitle ──────────────────────────────────────────────
                  const Text(
                    'Masuk ke akun Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'm',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Login card ────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.navy.withOpacity(0.07),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Username field ───────────────────────────────
                        _buildLabel('Username'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _usernameCtrl,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                            fontFamily: 'm',
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          decoration: _inputDecoration(
                            hint: 'Masukkan username',
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Password field ───────────────────────────────
                        _buildLabel('Password'),
                        const SizedBox(height: 6),
                        StatefulBuilder(
                          builder: (_, setLocal) => TextField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _onLoginTap(),
                            style: const TextStyle(
                              fontFamily: 'm',
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                            decoration: _inputDecoration(
                              hint: 'Masukkan password',
                              prefixIcon: Icons.lock_outline_rounded,
                            ).copyWith(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setLocal(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Login button ─────────────────────────────────
                        Obx(() {
                          final loading = _auth.isLoading.value;
                          return SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: loading ? null : _onLoginTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.navy,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    AppColors.navy.withOpacity(0.5),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Masuk',
                                      style: TextStyle(
                                        fontFamily: 'm',
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Footer note ───────────────────────────────────────────
                  const Text(
                    'Akun dibuat oleh administrator',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'm',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper widgets ─────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'm',
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'm',
        color: AppColors.textSecondary,
        fontSize: 13,
      ),
      prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary, size: 20),
      filled: true,
      fillColor: AppColors.bgLight,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        borderSide: const BorderSide(color: AppColors.teal, width: 2),
      ),
    );
  }
}
