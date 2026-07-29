import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'auth/login_screen.dart';

/// First screen shown when the app launches. Always renders in the
/// dark brand colours regardless of the user's light/dark preference
/// — a fixed splash identity is a deliberate, common choice, so its
/// colours are hardcoded rather than pulled from the theme.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkAmethyst,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---- FT monogram badge (same style as AuthHeader) ----
            Container(
              width: 72,
              height: 72,
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
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  'FT',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -3,
                    height: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'FinTrack',
              style: GoogleFonts.fraunces(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: AppColors.petalFrost,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'PERSONAL FINANCE',
              style: TextStyle(
                fontSize: 12.5,
                letterSpacing: 2,
                color: AppColors.periwinkle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}