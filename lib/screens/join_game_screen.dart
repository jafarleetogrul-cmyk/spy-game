import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../l10n/strings.dart';

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});
  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  bool _showScanner = false;
  bool _scanned = false;
  String? _scannedRoomId, _scannedJoinToken, _scannedRoomCode;

  final _nameController = TextEditingController();
  final _roomCodeController = TextEditingController();
  final _joinTokenController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _roomCodeController.dispose();
    _joinTokenController.dispose();
    super.dispose();
  }

  void _onQrScanned(String raw) {
    if (_scanned) return;
    setState(() => _scanned = true);
    try {
      final uri = Uri.parse(raw);
      final roomId = uri.queryParameters['room_id'];
      final token = uri.queryParameters['join_token'];
      final roomCode = uri.queryParameters['room_code'];
      if (roomId != null && token != null) {
        setState(() {
          _scannedRoomId = roomId;
          _scannedJoinToken = token;
          _scannedRoomCode = roomCode;
          _showScanner = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L.t('qr_scanned')), backgroundColor: AppTheme.accent),
        );
      } else {
        setState(() => _scanned = false);
      }
    } catch (_) { setState(() => _scanned = false); }
  }

  Future<void> _join() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final roomId = _scannedRoomId;
    final roomCode = _scannedRoomCode ?? _roomCodeController.text.trim().toUpperCase();
    final joinToken = _scannedJoinToken ?? _joinTokenController.text.trim();

    if (roomId == null && roomCode.isEmpty) return;
    if (joinToken.isEmpty) return;

    final gp = context.read<GameProvider>();
    try {
      await gp.joinGame(
        roomId: roomId,
        roomCode: roomCode.isEmpty ? null : roomCode,
        joinToken: joinToken, playerName: name,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/lobby');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_showScanner) return _buildScanner();
    final gp = context.watch<GameProvider>();
    final hasScanned = _scannedRoomId != null;

    return LoadingOverlay(
      isLoading: gp.isLoading,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
          child: SafeArea(
            child: CustomScrollView(slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
                title: Text(L.t('join_game')),
                floating: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  ErrorBanner(error: gp.lastError, onDismiss: gp.clearError),
                  if (!hasScanned)
                    GradientButton(
                      label: L.t('scan_qr'), icon: Icons.qr_code_scanner,
                      gradient: LinearGradient(colors: [AppTheme.secondary, AppTheme.secondary.withOpacity(0.7)]),
                      onTap: () => setState(() { _showScanner = true; _scanned = false; }),
                    ).animate().fadeIn(delay: 100.ms),
                  if (hasScanned)
                    GlassCard(
                      borderColor: AppTheme.accent.withOpacity(0.4),
                      child: Row(children: [
                        const Icon(Icons.check_circle, color: AppTheme.accent),
                        const SizedBox(width: 10),
                        Expanded(child: Text('${L.t('qr_scanned')} Otaq: $_scannedRoomCode',
                          style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w600))),
                        TextButton(
                          onPressed: () => setState(() { _scannedRoomId = null; _scannedJoinToken = null; _scannedRoomCode = null; }),
                          child: const Text('Sil', style: TextStyle(color: AppTheme.secondary)),
                        ),
                      ]),
                    ).animate().fadeIn(),
                  const SizedBox(height: 16),
                  if (!hasScanned) ...[
                    Row(children: [
                      const Expanded(child: Divider(color: Colors.white12)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(L.t('or'), style: const TextStyle(color: AppTheme.textSub, fontSize: 12)),
                      ),
                      const Expanded(child: Divider(color: Colors.white12)),
                    ]),
                    const SizedBox(height: 16),
                    GlassCard(
                      child: TextField(
                        controller: _roomCodeController,
                        style: const TextStyle(color: AppTheme.textMain, fontSize: 16),
                        decoration: InputDecoration(
                          labelText: L.t('room_code'),
                          prefixIcon: const Icon(Icons.meeting_room, color: AppTheme.primary),
                          border: InputBorder.none, filled: false,
                        ),
                        textCapitalization: TextCapitalization.characters, maxLength: 6,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 10),
                    GlassCard(
                      child: TextField(
                        controller: _joinTokenController,
                        style: const TextStyle(color: AppTheme.textMain, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: L.t('join_token'),
                          prefixIcon: const Icon(Icons.key, color: AppTheme.primary),
                          border: InputBorder.none, filled: false,
                        ),
                      ),
                    ).animate().fadeIn(delay: 260.ms),
                    const SizedBox(height: 12),
                  ],
                  GlassCard(
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(color: AppTheme.textMain, fontSize: 16),
                      decoration: InputDecoration(
                        labelText: L.t('your_name'),
                        prefixIcon: const Icon(Icons.person, color: AppTheme.primary),
                        border: InputBorder.none, filled: false,
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ).animate().fadeIn(delay: 320.ms),
                  const SizedBox(height: 24),
                  GradientButton(label: L.t('join'), onTap: _join, icon: Icons.login)
                      .animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 24),
                ])),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildScanner() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(L.t('scan_qr')),
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _showScanner = false)),
      ),
      body: Stack(children: [
        MobileScanner(onDetect: (capture) {
          final barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final raw = barcodes.first.rawValue ?? '';
            if (raw.isNotEmpty) _onQrScanned(raw);
          }
        }),
        Center(child: Container(
          width: 260, height: 260,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primary, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
        )),
        Positioned(bottom: 60, left: 0, right: 0,
          child: Text('QR kodu çərçivəyə salın', textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14))),
      ]),
    );
  }
}
