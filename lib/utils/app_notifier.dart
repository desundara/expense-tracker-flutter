import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Styled in-app notifications used everywhere instead of the plain
/// default SnackBar — a floating rounded card with an accent icon,
/// colour-coded for success / error / info.
class AppNotifier {
  static void success(BuildContext context, String message) => _show(
        context,
        message,
        icon: Icons.check_circle_rounded,
        accent: context.colors.positive,
      );

  static void error(BuildContext context, String message) => _show(
        context,
        message,
        icon: Icons.error_rounded,
        accent: context.colors.negative,
      );

  static void info(BuildContext context, String message) => _show(
        context,
        message,
        icon: Icons.info_rounded,
        accent: AppColors.mauveMagic,
      );

  static void _show(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color accent,
  }) {
    final colors = context.colors;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.cardBackground,
          elevation: 6,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: accent.withOpacity(0.35)),
          ),
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                      color: colors.textBody, fontSize: 13.5, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
  }
}