import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final gp = context.read<GameProvider>();
    _urlController.text = gp.serverUrl;
  }

  void _showServerConfig() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Server URL',
                  style: TextStyle(
                      color: AppTheme.textMain,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: _urlController,
                style: const TextStyle(color: AppTheme.textMain),
                decoration: const InputDecoration(
                  hintText: 'http://192.168.1.100:8080',
                  prefixIcon: Icon(Icons.dns, color: AppTheme.textSub),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: 'Yadda saxla',
                onTap: () {
                  context.read<GameProvider>().updateServerUrl(
                      _urlController.text.trim());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Server URL yeniləndi'),
                        backgroundColor: AppTheme.accent),
                  );
                },
                icon: Icons.save,
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Logo area
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.primary.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5)
                        ],
                      ),
                      child: const Icon(Icons.visibility,
                          color: Colors.white, size: 50),
                    )
                        .animate()
                        .scale(
                            begin: const Offset(0, 0),
                            duration: 600.ms,
                            curve: Curves.elasticOut)
                        .fadeIn(),
                    const SizedBox(height: 20),
                    Text(
                      'SPY GAME',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5,
                        shadows: [
                          Shadow(
                              color: AppTheme.primary.withOpacity(0.5),
                              blurRadius: 16)
                        ],
                      ),
                    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                    const SizedBox(height: 6),
                    const Text(
                      'Otaqda casusları tap!',
                      style: TextStyle(color: AppTheme.textSub, fontSize: 14),
                    ).animate(delay: 300.ms).fadeIn(),
                  ],
                ),
                const Spacer(flex: 3),
                // Buttons
                GradientButton(
                  label: 'Oyun Yarat',
                  onTap: () => Navigator.pushNamed(context, '/create'),
                  gradient: AppTheme.primaryGradient,
                  icon: Icons.add_circle_outline,
                ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3),
                const SizedBox(height: 16),
                GradientButton(
                  label: 'Oyuna Qoşul',
                  onTap: () => Navigator.pushNamed(context, '/join'),
                  gradient: LinearGradient(colors: [
                    AppTheme.secondary,
                    AppTheme.secondary.withOpacity(0.7)
                  ]),
                  icon: Icons.qr_code_scanner,
                ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.3),
                const Spacer(flex: 2),
                // Settings icon
                IconButton(
                  onPressed: _showServerConfig,
                  icon: const Icon(Icons.settings, color: AppTheme.textSub),
                ).animate(delay: 700.ms).fadeIn(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
