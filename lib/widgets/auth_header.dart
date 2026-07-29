import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Decorative curved header used on the Login and Register screens,
/// with the FinTrack wordmark centred on a purple gradient banner
/// and soft overlapping circles for depth.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(48),
        bottomRight: Radius.circular(48),
      ),
      child: Container(
        height: 190,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.darkAmethyst2, AppColors.royalViolet],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -60,
              right: -50,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mauveMagic.withOpacity(0.25),
                ),
              ),
            ),
            Positioned(
              top: -20,
              right: 10,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lavenderPurple.withOpacity(0.22),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ---- FT monogram badge (letters fused via tight kerning) ----
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'FT',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -2.4,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'FinTrack',
                      style: GoogleFonts.fraunces(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}