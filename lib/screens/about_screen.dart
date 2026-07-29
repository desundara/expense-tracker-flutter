import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/app_notifier.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _snack(BuildContext context, String label) {
    AppNotifier.info(context, '$label — coming next');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: colors.textBody),
                  ),
                  Text('About', style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // ---- FT monogram badge (same style as AuthHeader / Splash) ----
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.mauveMagic, AppColors.royalViolet],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mauveMagic.withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'FT',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -2.6,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('FinTrack',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text('Version 1.0.0',
                        style: TextStyle(color: colors.textMuted, fontSize: 12.5)),
                    const SizedBox(height: 18),
                    Text(
                      'A calm, premium way to track everyday spending and stay '
                      'on top of your money. Built as part of the Advanced Mobile '
                      'Development module coursework.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.textBody, fontSize: 13.5, height: 1.5),
                    ),
                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _iconButton(context, Icons.mail_outline_rounded,
                            () => _snack(context, 'Contact email')),
                        const SizedBox(width: 14),
                        _iconButton(context, Icons.language_rounded,
                            () => _snack(context, 'Website')),
                        const SizedBox(width: 14),
                        _iconButton(context, Icons.shield_outlined,
                            () => _snack(context, 'Privacy policy')),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _snack(context, 'Rate the app'),
                        icon: const Icon(Icons.star_border_rounded, color: AppColors.mauveMagic),
                        label: Text('Rate the app',
                            style: TextStyle(color: colors.textBody)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: colors.inputBorder),
                          shape:
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(BuildContext context, IconData icon, VoidCallback onTap) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colors.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.inputBorder),
        ),
        child: Icon(icon, size: 18, color: AppColors.mauveMagic),
      ),
    );
  }
}