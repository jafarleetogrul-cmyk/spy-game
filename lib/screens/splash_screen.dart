import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/menu');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Eye / spy icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    )
                  ],
                ),
                child: const Icon(Icons.visibility,
                    color: Colors.white, size: 60),
              )
                  .animate()
                  .scale(begin: const Offset(0.4, 0.4), duration: 700.ms,
                      curve: Curves.elasticOut)
                  .fadeIn(duration: 500.ms),
              const SizedBox(height: 28),
              Text(
                'SPY GAME',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  shadows: [
                    Shadow(
                        color: AppTheme.primary.withOpacity(0.6),
                        blurRadius: 20)
                  ],
                ),
              )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'Kim şpiondur?',
                style: TextStyle(
                    color: AppTheme.textSub.withOpacity(0.8),
                    fontSize: 16,
                    letterSpacing: 2),
              ).animate(delay: 500.ms).fadeIn(duration: 600.ms),
              const SizedBox(height: 48),
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: AppTheme.primary.withOpacity(0.6),
                  strokeWidth: 2,
                ),
              ).animate(delay: 900.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
