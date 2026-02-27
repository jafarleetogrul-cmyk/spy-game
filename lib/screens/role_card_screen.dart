import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class RoleCardScreen extends StatefulWidget {
  const RoleCardScreen({super.key});

  @override
  State<RoleCardScreen> createState() => _RoleCardScreenState();
}

class _RoleCardScreenState extends State<RoleCardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnim;
  bool _isFlipped = false;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _flipAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _done() {
    setState(() => _isDone = true);
    // Navigate to round control (host) or waiting screen
    final gp = context.read<GameProvider>();
    if (gp.isHost) {
      Navigator.pushReplacementNamed(context, '/round_control');
    } else {
      Navigator.pushReplacementNamed(context, '/round_control');
    }
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final card = gp.myCard;

    if (card == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
          child: const Center(
              child: CircularProgressIndicator(color: AppTheme.primary)),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Round indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    'Raund ${card.roundNumber} / ${card.roundsCount}',
                    style: const TextStyle(
                        color: AppTheme.textSub,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ).animate().fadeIn(),

                const Spacer(),

                // Instruction text
                Text(
                  _isFlipped ? 'Kartınızı gizlədin!' : 'Kartınıza baxın',
                  style: TextStyle(
                      color: AppTheme.textSub.withOpacity(0.8),
                      fontSize: 14),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 16),

                // Flip card
                GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _flipAnim,
                    builder: (_, __) {
                      final angle = _flipAnim.value * pi;
                      final isFront = angle < pi / 2;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: isFront
                            ? _buildBack()
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(pi),
                                child: _buildFront(card),
                              ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  _isFlipped
                      ? 'Hazır olduqda "Bitdi" basın'
                      : 'Kartı çevirmək üçün toxunun',
                  style: TextStyle(
                      color: AppTheme.textSub.withOpacity(0.7),
                      fontSize: 13),
                ).animate(key: ValueKey(_isFlipped)).fadeIn(),

                const Spacer(),

                if (_isFlipped)
                  GradientButton(
                    label: 'Bitdi – Kartı Gizlə',
                    onTap: _done,
                    icon: Icons.check,
                  ).animate().fadeIn().slideY(begin: 0.2),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Card back (shows before flip)
  Widget _buildBack() {
    return Container(
      width: 300,
      height: 420,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.5),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.visibility_off,
              color: Colors.white54, size: 80),
          const SizedBox(height: 20),
          const Text(
            'Toxunun\nçevirmək üçün',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white70, fontSize: 18, height: 1.4),
          ),
        ],
      ),
    );
  }

  // Card front (shows after flip)
  Widget _buildFront(MyCard card) {
    final isSpy = card.isSpy;
    return Container(
      width: 300,
      height: 420,
      decoration: BoxDecoration(
        gradient: isSpy ? AppTheme.spyGradient : AppTheme.civilGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isSpy ? AppTheme.spyRed : AppTheme.civilBlue)
                .withOpacity(0.5),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Role icon
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
              child: Icon(
                isSpy ? Icons.person_search : Icons.location_on,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),

            // Role label
            Text(
              isSpy ? 'SƏN ŞPİONSAN' : 'MÜLKI VƏTƏNDAŞ',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),

            // Divider
            Container(height: 1, color: Colors.white24),
            const SizedBox(height: 20),

            if (isSpy)
              Column(
                children: [
                  const Icon(Icons.help_outline,
                      color: Colors.white60, size: 32),
                  const SizedBox(height: 12),
                  const Text(
                    'Məkanı tapmağa çalış\nvə mülki kimi görün!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.4),
                  ),
                ],
              )
            else
              Column(
                children: [
                  const Icon(Icons.place, color: Colors.white60, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'Məkan:',
                    style:
                        TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    card.place ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
