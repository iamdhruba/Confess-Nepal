import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import 'package:confess_nepal/core/utils/app_alerts.dart';
import '../providers/profile_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await context.read<ProfileProvider>().changePassword(
          currentPassword: _currentCtrl.text,
          newPassword: _newCtrl.text,
        );
    if (!mounted) return;
    if (error != null) {
      AppAlerts.showError(context, error);
    } else {
      AppAlerts.showSuccess(context, 'Password changed successfully');
      Navigator.pop(context);
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.arrow_back_rounded, color: textPrimary, size: 20),
                    ),
                  ),
                  const Spacer(),
                  Text('Change Password', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildField(context, controller: _currentCtrl, label: 'Current Password', hint: '••••••••', obscure: _obscureCurrent, toggle: () => setState(() => _obscureCurrent = !_obscureCurrent), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null, fillColor: cardColor, textColor: textPrimary, labelColor: textSecondary, hintColor: textTertiary),
                      const SizedBox(height: 16),
                      _buildField(context, controller: _newCtrl, label: 'New Password', hint: 'Min 8 characters', obscure: _obscureNew, toggle: () => setState(() => _obscureNew = !_obscureNew), validator: (v) { if (v == null || v.isEmpty) return 'Required'; if (v.length < 8) return 'Minimum 8 characters'; return null; }, fillColor: cardColor, textColor: textPrimary, labelColor: textSecondary, hintColor: textTertiary),
                      const SizedBox(height: 16),
                      _buildField(context, controller: _confirmCtrl, label: 'Confirm New Password', hint: '••••••••', obscure: _obscureConfirm, toggle: () => setState(() => _obscureConfirm = !_obscureConfirm), validator: (v) => v != _newCtrl.text ? 'Passwords do not match' : null, fillColor: cardColor, textColor: textPrimary, labelColor: textSecondary, hintColor: textTertiary),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: isLoading ? null : _submit,
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
                                : const Text('Update Password', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
    required String? Function(String?)? validator,
    required Color fillColor,
    required Color textColor,
    required Color labelColor,
    required Color hintColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(color: textColor, fontSize: 15),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor),
            prefixIcon: Icon(Icons.lock_outline_rounded, color: hintColor, size: 20),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: hintColor, size: 20),
              onPressed: toggle,
            ),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error, width: 1)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
