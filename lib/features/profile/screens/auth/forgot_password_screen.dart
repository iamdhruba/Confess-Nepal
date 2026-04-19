import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import 'package:confess_nepal/core/utils/app_alerts.dart';
import '../../providers/profile_provider.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _otpSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_emailCtrl.text.trim().isEmpty) return;
    await context.read<ProfileProvider>().forgotPassword(_emailCtrl.text.trim());
    if (!mounted) return;
    setState(() => _otpSent = true);
    AppAlerts.showSuccess(context, 'Check your email for the OTP');
  }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.trim().length != 6) return;
    final error = await context.read<ProfileProvider>().verifyOtp(
          email: _emailCtrl.text.trim(),
          otp: _otpCtrl.text.trim(),
        );
    if (!mounted) return;
    if (error != null) {
      AppAlerts.showError(context, error);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(email: _emailCtrl.text.trim(), otp: _otpCtrl.text.trim()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProfileProvider>().isAuthLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundPrimary : AppColors.lightSurface;
    final cardColor = isDark ? AppColors.backgroundSecondary : AppColors.lightElevated;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final textTertiary = isDark ? AppColors.textTertiary : AppColors.textTertiaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.arrow_back_rounded, color: textPrimary, size: 20),
                ),
              ),
              const SizedBox(height: 40),
              ShaderMask(
                shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                child: const Text('Forgot\nPassword 🔐',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
              ),
              const SizedBox(height: 8),
              Text("Enter your email and we'll send you a 6-digit OTP",
                  style: TextStyle(color: textTertiary, fontSize: 14)),
              const SizedBox(height: 40),
              Text('Email', style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailCtrl,
                      enabled: !_otpSent,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: textPrimary, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'your@email.com',
                        hintStyle: TextStyle(color: textTertiary),
                        prefixIcon: Icon(Icons.email_outlined, color: textTertiary, size: 20),
                        filled: true,
                        fillColor: cardColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: isLoading ? null : _sendOtp,
                    child: Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
                      child: Center(
                        child: isLoading && !_otpSent
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(_otpSent ? 'Resend' : 'Send OTP',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
              if (_otpSent) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mark_email_read_outlined, color: AppColors.success, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text('OTP sent to ${_emailCtrl.text.trim()}',
                          style: const TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Enter OTP', style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: TextStyle(color: textPrimary, fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '------',
                    hintStyle: TextStyle(color: textTertiary, letterSpacing: 8),
                    counterText: '',
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: isLoading ? null : _verifyOtp,
                  child: Container(
                    width: double.infinity, height: 54,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('Verify OTP', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
