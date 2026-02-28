import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
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
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      final gp = context.read<GameProvider>();
      if (gp.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/menu');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGrad),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 130, height: 130,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.primaryGrad,
                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.6), blurRadius: 50, spreadRadius: 15)]),
              child: const Icon(Icons.visibility, color: Colors.white, size: 70),
            ).animate().scale(begin: const Offset(0.3,0.3), duration: 800.ms, curve: Curves.elasticOut).fadeIn(),
            const SizedBox(height: 32),
            Text('SPY GAME', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 8,
              shadows: [Shadow(color: AppTheme.primary.withOpacity(0.7), blurRadius: 25)]))
              .animate(delay: 400.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 8),
            Text('Kim şpiondur?', style: TextStyle(color: AppTheme.textSub.withOpacity(0.8), fontSize: 16, letterSpacing: 3))
              .animate(delay: 600.ms).fadeIn(),
            const SizedBox(height: 60),
            Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) =>
              Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: 8, height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary.withOpacity(0.6)))
                .animate(delay: (900+i*200).ms, onPlay: (c) => c.repeat()).fadeIn(duration: 400.ms).then().fadeOut(duration: 400.ms))),
          ]),
        ),
      ),
    );
  }
}
