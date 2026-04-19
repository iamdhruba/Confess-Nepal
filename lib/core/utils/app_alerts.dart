import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';

/// Centralized, theme-aware alerts for ConfessNepal.
/// All SnackBars and AlertDialogs route through here so they
/// automatically adapt to the current light/dark theme.
class AppAlerts {
  AppAlerts._();

  // ─── SnackBars ────────────────────────────────────────────────────

  /// Success snackbar (green tint, themed background).
  static void showSuccess(BuildContext context, String message) {
    _showThemedSnackBar(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      accentColor: AppColors.success,
    );
  }

  /// Error snackbar (red tint, themed background).
  static void showError(BuildContext context, String message) {
    _showThemedSnackBar(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      accentColor: AppColors.error,
    );
  }

  /// Info / neutral snackbar (primary pink tint).
  static void showInfo(BuildContext context, String message) {
    _showThemedSnackBar(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      accentColor: AppColors.primary,
    );
  }

  /// Warning snackbar (amber tint).
  static void showWarning(BuildContext context, String message) {
    _showThemedSnackBar(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      accentColor: AppColors.warning,
    );
  }

  /// Custom-color snackbar (e.g. for mood-tinted feedback).
  static void showCustom(
    BuildContext context, {
    required String message,
    required Color accentColor,
    IconData? icon,
  }) {
    _showThemedSnackBar(
      context,
      message: message,
      icon: icon,
      accentColor: accentColor,
    );
  }

  static void _showThemedSnackBar(
    BuildContext context, {
    required String message,
    required Color accentColor,
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Themed surface: slight tint of the accent over the card background
    final bgColor = isDark
        ? Color.alphaBlend(accentColor.withValues(alpha: 0.12), AppColors.backgroundCard)
        : Color.alphaBlend(accentColor.withValues(alpha: 0.08), Colors.white);

    final textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final borderColor = accentColor.withValues(alpha: isDark ? 0.3 : 0.25);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: borderColor, width: 1),
        ),
        elevation: isDark ? 8 : 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─── AlertDialogs ─────────────────────────────────────────────────

  /// Themed confirmation dialog (e.g. logout, delete).
  /// Returns `true` if confirmed, `false` / `null` if cancelled.
  static Future<bool?> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String cancelLabel = 'Cancel',
    String confirmLabel = 'Confirm',
    Color? confirmColor,
    bool isDanger = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundCard : Colors.white;
    final titleColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final contentColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final cancelColor = isDark ? AppColors.textTertiary : AppColors.textTertiaryLight;
    final actionColor = confirmColor ?? (isDanger ? AppColors.error : AppColors.primary);

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: isDark
                ? AppColors.backgroundElevated
                : AppColors.lightBorder,
            width: 1,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: titleColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            color: contentColor,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: cancelColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              cancelLabel,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: actionColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              confirmLabel,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  /// Themed input dialog (e.g. custom mood, custom location).
  /// Returns the entered text, or `null` if cancelled.
  static Future<String?> showInput(
    BuildContext context, {
    required String title,
    String? hintText,
    String? initialValue,
    String cancelLabel = 'Cancel',
    String confirmLabel = 'Save',
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundCard : Colors.white;
    final titleColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final hintColor = isDark ? AppColors.textTertiary : AppColors.textTertiaryLight;
    final cancelColor = isDark ? AppColors.textTertiary : AppColors.textTertiaryLight;
    final inputBg = isDark ? AppColors.backgroundSecondary : AppColors.lightElevated;

    final controller = TextEditingController(text: initialValue ?? '');

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: isDark
                ? AppColors.backgroundElevated
                : AppColors.lightBorder,
            width: 1,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: titleColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.plusJakartaSans(color: textColor, fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.plusJakartaSans(color: hintColor, fontSize: 14),
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: cancelColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              cancelLabel,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              confirmLabel,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
