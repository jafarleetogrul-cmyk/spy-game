import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  bool _showScanner = false;
  bool _scanned = false;

  // After scanning, we show the name entry form
  String? _scannedRoomId;
  String? _scannedJoinToken;
  String? _scannedRoomCode;

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

    // Parse: spygame://join?room_id=...&join_token=...&room_code=...
    try {
      final uri = Uri.parse(raw);
      final roomId   = uri.queryParameters['room_id'];
      final token    = uri.queryParameters['join_token'];
      final roomCode = uri.queryParameters['room_code'];
      if (roomId != null && token != null) {
        setState(() {
          _scannedRoomId    = roomId;
          _scannedJoinToken = token;
          _scannedRoomCode  = roomCode;
          _showScanner      = false;
        });
      } else {
        _resetScan('QR kod düzgün deyil');
      }
    } catch (_) {
      _resetScan('QR kod oxunmadı');
    }
  }

  void _resetScan(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppTheme.spyRed));
    setState(() => _scanned = false);
  }

  Future<void> _join() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adınızı daxil edin'), backgroundColor: AppTheme.spyRed),
      );
      return;
    }

    // Determine room_id / room_code + join_token
    String? roomId    = _scannedRoomId;
    String? roomCode  = _scannedRoomCode ?? _roomCodeController.text.trim().toUpperCase();
    String? joinToken = _scannedJoinToken ?? _joinTokenController.text.trim();

    if (roomId == null && roomCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Otaq kodu daxil edin'), backgroundColor: AppTheme.spyRed),
      );
      return;
    }
    if (joinToken!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Join token daxil edin'), backgroundColor: AppTheme.spyRed),
      );
      return;
    }

    final gp = context.read<GameProvider>();
    try {
      await gp.joinGame(
        roomId: roomId,
        roomCode: roomCode!.isEmpty ? null : roomCode,
        joinToken: joinToken,
        playerName: name,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/lobby');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_showScanner) return _buildScanner();

    final gp = context.watch<GameProvider>();
    final hasScannedData = _scannedRoomId != null;

    return LoadingOverlay(
      isLoading: gp.isLoading,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: const Text('Oyuna Qoşul'),
                  floating: true,
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      ErrorBanner(error: gp.lastError, onDismiss: gp.clearError),

                      // QR Scan button
                      if (!hasScannedData)
                        GradientButton(
                          label: 'QR Kodu Skan Et',
                          icon: Icons.qr_code_scanner,
                          gradient: LinearGradient(colors: [
                            AppTheme.secondary,
                            AppTheme.secondary.withOpacity(0.7)
                          ]),
                          onTap: () => setState(() {
                            _showScanner = true;
                            _scanned = false;
                          }),
                        ).animate().fadeIn(delay: 100.ms),

                      if (hasScannedData) ...[
                        GlassCard(
                          borderColor: AppTheme.accent.withOpacity(0.4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: AppTheme.accent),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'QR oxundu! Otaq: $_scannedRoomCode',
                                  style: const TextStyle(
                                      color: AppTheme.textMain,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              TextButton(
                                onPressed: () => setState(() {
                                  _scannedRoomId = null;
                                  _scannedJoinToken = null;
                                  _scannedRoomCode = null;
                                }),
                                child: const Text('Sil',
                                    style:
                                        TextStyle(color: AppTheme.secondary)),
                              )
                            ],
                          ),
                        ).animate().fadeIn(),
                      ],

                      const SizedBox(height: 20),

                      if (!hasScannedData) ...[
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white12)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('və ya əl ilə daxil et',
                                  style: TextStyle(
                                      color: AppTheme.textSub, fontSize: 12)),
                            ),
                            Expanded(child: Divider(color: Colors.white12)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GlassCard(
                          child: TextField(
                            controller: _roomCodeController,
                            style: const TextStyle(
                                color: AppTheme.textMain, fontSize: 16),
                            decoration: const InputDecoration(
                              labelText: 'Otaq kodu (6 hərf)',
                              prefixIcon:
                                  Icon(Icons.meeting_room, color: AppTheme.primary),
                              border: InputBorder.none,
                              filled: false,
                            ),
                            textCapitalization: TextCapitalization.characters,
                            maxLength: 6,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 12),
                        GlassCard(
                          child: TextField(
                            controller: _joinTokenController,
                            style: const TextStyle(
                                color: AppTheme.textMain, fontSize: 13),
                            decoration: const InputDecoration(
                              labelText: 'Join Token',
                              prefixIcon:
                                  Icon(Icons.key, color: AppTheme.primary),
                              border: InputBorder.none,
                              filled: false,
                            ),
                          ),
                        ).animate().fadeIn(delay: 260.ms),
                        const SizedBox(height: 16),
                      ],

                      // Name field
                      GlassCard(
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(
                              color: AppTheme.textMain, fontSize: 16),
                          decoration: const InputDecoration(
                            labelText: 'Adınız',
                            prefixIcon:
                                Icon(Icons.person, color: AppTheme.primary),
                            border: InputBorder.none,
                            filled: false,
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ).animate().fadeIn(delay: 320.ms),

                      const SizedBox(height: 24),
                      GradientButton(
                        label: 'Qoşul',
                        onTap: _join,
                        icon: Icons.login,
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
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
        title: const Text('QR Kodu Skan Et'),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => setState(() => _showScanner = false),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final raw = barcodes.first.rawValue ?? '';
                if (raw.isNotEmpty) _onQrScanned(raw);
              }
            },
          ),
          // Overlay frame
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              'QR kodu çərçivəyə salın',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
