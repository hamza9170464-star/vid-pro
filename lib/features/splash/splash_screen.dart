import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_option.dart';
import '../../screens/main_hub.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainHub(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black, // Sleek true black base during boot
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Cyberpunk background grid elements or subtle ambient glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.darkRedPrimary.withOpacity(0.15),
                blurRadius: 100,
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing pulsating emblem
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.02),
                    border: Border.all(
                      color: AppTheme.darkRedPrimary.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.darkRedPrimary.withOpacity(0.25),
                        blurRadius: 32,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_circle_filled_rounded,
                    size: 84,
                    color: AppTheme.darkRedPrimary,
                  ),
                )
                    .animate()
                    .scale(duration: 1000.ms, curve: Curves.easeOutBack)
                    .then()
                    .shake(duration: 500.ms, hz: 4)
                    .then()
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .custom(
                      duration: 1500.ms,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 1.0 + (value * 0.05),
                          child: child,
                        );
                      },
                    ),
                
                const SizedBox(height: 32),
                
                // Cyberbrand typography
                Text(
                  'VID-PRO',
                  style: GoogleFonts.outfit(
                    fontSize: 40,
                    fontWeight: FontWeight.black,
                    letterSpacing: 6,
                    color: Colors.white,
                    shadows: [
                      const Shadow(
                        color: AppTheme.darkRedPrimary,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
                
                const SizedBox(height: 8),
                
                Text(
                  'PREMIUM DOWNLOAD ENGINE',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                    color: Colors.white.withOpacity(0.4),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 600.ms),
              ],
            ),
          ),
          
          // Subtle loading progress tracker at bottom
          Positioned(
            bottom: 60,
            child: SizedBox(
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  color: AppTheme.darkRedPrimary,
                  backgroundColor: Colors.white10,
                  minHeight: 3,
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 1000.ms, duration: 400.ms),
        ],
      ),
    );
  }
}
