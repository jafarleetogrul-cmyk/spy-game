import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class GameProvider extends ChangeNotifier {
  // ── Server URL ─────────────────────────────
  String serverUrl = 'http://10.0.2.2:8080'; // Android emulator default

  late ApiService _api;

  GameProvider() {
    _api = ApiService(serverUrl);
  }

  void updateServerUrl(String url) {
    serverUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    _api = ApiService(serverUrl);
    notifyListeners();
  }

  // ── Session ────────────────────────────────
  LocalSession? session;
  RoomState? roomState;
  MyCard? myCard;
  List<ScoreEntry> scoreboard = [];

  bool get isHost => session?.isHost ?? false;
  bool get hasSession => session != null;

  // ── Polling ────────────────────────────────
  Timer? _pollTimer;
  String? _lastError;
  bool _isLoading = false;

  String? get lastError => _lastError;
  bool get isLoading => _isLoading;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  // ── Create game ────────────────────────────
  Future<void> createGame({
    required String creatorName,
    required int maxPlayers,
    required int spiesCount,
    required int roundsCount,
  }) async {
    _setLoading(true);
    try {
      final j = await _api.createRoom(
        creatorName: creatorName,
        maxPlayers: maxPlayers,
        spiesCount: spiesCount,
        roundsCount: roundsCount,
      );
      session = LocalSession(
        roomId: j['room_id'],
        roomCode: j['room_code'],
        playerId: j['player_id'],
        playerToken: j['player_token'],
        hostToken: j['host_token'],
        joinToken: j['join_token'],
      );
      _lastError = null;
      await _refreshRoomState();
    } catch (e) {
      _lastError = e.toString().replaceFirst('ApiException(400): ', '');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ── Join game ──────────────────────────────
  Future<void> joinGame({
    String? roomId,
    String? roomCode,
    required String joinToken,
    required String playerName,
  }) async {
    _setLoading(true);
    try {
      final j = await _api.joinRoom(
        roomId: roomId,
        roomCode: roomCode,
        joinToken: joinToken,
        playerName: playerName,
      );
      session = LocalSession(
        roomId: j['room_id'],
        roomCode: j['room_code'],
        playerId: j['player_id'],
        playerToken: j['player_token'],
        joinToken: joinToken,
      );
      _lastError = null;
      await _refreshRoomState();
    } catch (e) {
      _lastError = e.toString().replaceFirst(RegExp(r'ApiException\(\d+\): '), '');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ── Start game ─────────────────────────────
  Future<void> startGame() async {
    if (session == null || session!.hostToken == null) return;
    _setLoading(true);
    try {
      await _api.startGame(
        roomId: session!.roomId,
        hostToken: session!.hostToken!,
      );
      await _refreshRoomState();
    } catch (e) {
      _lastError = _stripError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ── Fetch card ─────────────────────────────
  Future<void> fetchMyCard() async {
    if (session == null) return;
    try {
      myCard = await _api.getMyCard(
        roomId: session!.roomId,
        playerToken: session!.playerToken,
      );
      notifyListeners();
    } catch (e) {
      _lastError = _stripError(e);
      notifyListeners();
    }
  }

  // ── End round ──────────────────────────────
  Future<bool> endRound(String winner) async {
    if (session?.hostToken == null) return false;
    _setLoading(true);
    try {
      final j = await _api.endRound(
        roomId: session!.roomId,
        hostToken: session!.hostToken!,
        winner: winner,
      );
      await _refreshRoomState();
      return j['game_finished'] == true;
    } catch (e) {
      _lastError = _stripError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ── Scoreboard ─────────────────────────────
  Future<void> fetchScoreboard() async {
    if (session == null) return;
    try {
      scoreboard = await _api.getScoreboard(session!.roomId);
      notifyListeners();
    } catch (e) {
      _lastError = _stripError(e);
      notifyListeners();
    }
  }

  // ── Polling ────────────────────────────────
  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _refreshRoomState();
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _refreshRoomState() async {
    if (session == null) return;
    try {
      roomState = await _api.getRoomState(session!.roomId);
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _lastError = 'Bağlantı xətası';
      notifyListeners();
    }
  }

  // ── Reset / leave ──────────────────────────
  void resetGame() {
    stopPolling();
    session = null;
    roomState = null;
    myCard = null;
    scoreboard = [];
    _lastError = null;
    _isLoading = false;
    notifyListeners();
  }

  // ── Build join QR data ─────────────────────
  String buildJoinQrData() {
    if (session == null) return '';
    return 'spygame://join?room_id=${session!.roomId}'
        '&join_token=${session!.joinToken}'
        '&room_code=${session!.roomCode}';
  }

  // ── Helpers ────────────────────────────────
  String _stripError(Object e) =>
      e.toString().replaceAll(RegExp(r'ApiException\(\d+\): '), '');

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
