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
  bool _showScanner = false, _scanned = false;
  String? _roomId, _joinToken, _roomCode;
  final _codeCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();

  @override
  void dispose() { _codeCtrl.dispose(); _tokenCtrl.dispose(); super.dispose(); }

  void _onQr(String raw) {
    if (_scanned) return;
    setState(() => _scanned = true);
    try {
      final uri = Uri.parse(raw);
      final rid = uri.queryParameters['room_id'];
      final tok = uri.queryParameters['join_token'];
      final rc  = uri.queryParameters['room_code'];
      if (rid != null && tok != null) {
        setState(() { _roomId = rid; _joinToken = tok; _roomCode = rc; _showScanner = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(L.t('qr_scanned')), backgroundColor: AppTheme.accent));
      } else setState(() => _scanned = false);
    } catch (_) { setState(() => _scanned = false); }
  }

  Future<void> _join() async {
    final roomCode  = _roomCode ?? _codeCtrl.text.trim().toUpperCase();
    final joinToken = _joinToken ?? _tokenCtrl.text.trim();
    if (roomCode.isEmpty && _roomId == null) return;
    if (joinToken.isEmpty) return;

    final gp = context.read<GameProvider>();
    try {
      await gp.joinGame(roomId: _roomId, roomCode: roomCode.isEmpty ? null : roomCode, joinToken: joinToken);
      if (mounted) Navigator.pushReplacementNamed(context, '/lobby');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_showScanner) return _scanner();
    final gp = context.watch<GameProvider>();
    final hasQr = _roomId != null;

    return LoadingOverlay(
      isLoading: gp.isLoading,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.bgGrad),
          child: SafeArea(child: CustomScrollView(slivers: [
            SliverAppBar(backgroundColor: Colors.transparent, floating: true,
              leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
              title: Text(L.t('join_game'))),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                ErrorBanner(error: gp.lastError, onDismiss: gp.clearError),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(children: [
                    CircleAvatar(radius: 18, backgroundColor: AppTheme.primary,
                      child: Text((gp.currentUser?.username ?? '?')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 10),
                    Text(gp.currentUser?.username ?? '', style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w600)),
                  ]),
                ).animate().fadeIn(delay: 80.ms),
                const SizedBox(height: 14),
                if (!hasQr)
                  GradientButton(label: L.t('scan_qr'), icon: Icons.qr_code_scanner,
                    gradient: LinearGradient(colors: [AppTheme.secondary, AppTheme.secondary.withOpacity(0.7)]),
                    onTap: () => setState(() { _showScanner = true; _scanned = false; }))
                    .animate().fadeIn(delay: 150.ms)
                else
                  GlassCard(
                    borderColor: AppTheme.accent.withOpacity(0.4),
                    child: Row(children: [
                      const Icon(Icons.check_circle, color: AppTheme.accent),
                      const SizedBox(width: 10),
                      Expanded(child: Text('QR oxundu  •  $_roomCode', style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w600))),
                      TextButton(onPressed: () => setState(() { _roomId=null; _joinToken=null; _roomCode=null; }),
                        child: const Text('Sil', style: TextStyle(color: AppTheme.secondary))),
                    ]),
                  ).animate().fadeIn(),
                if (!hasQr) ...[
                  const SizedBox(height: 14),
                  Row(children: [const Expanded(child: Divider(color: Colors.white12)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(L.t('or'), style: const TextStyle(color: AppTheme.textSub, fontSize: 12))),
                    const Expanded(child: Divider(color: Colors.white12))]),
                  const SizedBox(height: 14),
                  GlassCard(child: TextField(controller: _codeCtrl, style: const TextStyle(color: AppTheme.textMain),
                    decoration: InputDecoration(labelText: L.t('room_code'), prefixIcon: const Icon(Icons.meeting_room, color: AppTheme.primary), border: InputBorder.none, filled: false),
                    textCapitalization: TextCapitalization.characters, maxLength: 6)).animate().fadeIn(delay: 220.ms),
                  const SizedBox(height: 10),
                  GlassCard(child: TextField(controller: _tokenCtrl, style: const TextStyle(color: AppTheme.textMain, fontSize: 13),
                    decoration: InputDecoration(labelText: L.t('join_token'), prefixIcon: const Icon(Icons.key, color: AppTheme.primary), border: InputBorder.none, filled: false)))
                    .animate().fadeIn(delay: 280.ms),
                ],
                const SizedBox(height: 24),
                GradientButton(label: L.t('join'), icon: Icons.login, onTap: _join).animate().fadeIn(delay: 350.ms),
                const SizedBox(height: 24),
              ])),
            ),
          ])),
        ),
      ),
    );
  }

  Widget _scanner() => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(backgroundColor: Colors.black, title: Text(L.t('scan_qr')),
      leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _showScanner = false))),
    body: Stack(children: [
      MobileScanner(onDetect: (c) { if (c.barcodes.isNotEmpty) { final v = c.barcodes.first.rawValue ?? ''; if (v.isNotEmpty) _onQr(v); } }),
      Center(child: Container(width: 260, height: 260, decoration: BoxDecoration(border: Border.all(color: AppTheme.primary, width: 3), borderRadius: BorderRadius.circular(20)))),
      const Positioned(bottom: 60, left: 0, right: 0, child: Text('QR kodu çərçivəyə salın', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70))),
    ]),
  );
}
