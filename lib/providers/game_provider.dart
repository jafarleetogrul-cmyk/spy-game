import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../l10n/strings.dart';

class GameProvider extends ChangeNotifier {
  String serverUrl = 'http://10.0.2.2:8080';
  late ApiService _api;

  GameProvider() {
    _api = ApiService(serverUrl);
    _loadSettings();
  }

  // ── Settings ────────────────────────────────────────────
  String language = 'az';
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  int defaultRoundTime = 5;

  Future<void> _loadSettings() async {
    final s = await StorageService.getSettings();
    language = s['language'] ?? 'az';
    soundEnabled = s['sound'] ?? true;
    vibrationEnabled = s['vibration'] ?? true;
    serverUrl = s['server_url'] ?? 'http://10.0.2.2:8080';
    defaultRoundTime = s['round_time'] ?? 5;
    L.setLang(language);
    SoundService.soundEnabled = soundEnabled;
    SoundService.vibrationEnabled = vibrationEnabled;
    _api = ApiService(serverUrl);
    notifyListeners();
  }

  Future<void> saveSettings({
    required String lang,
    required bool sound,
    required bool vibration,
    required String url,
    required int roundTime,
  }) async {
    language = lang;
    soundEnabled = sound;
    vibrationEnabled = vibration;
    serverUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    defaultRoundTime = roundTime;
    L.setLang(lang);
    SoundService.soundEnabled = sound;
    SoundService.vibrationEnabled = vibration;
    _api = ApiService(serverUrl);
    await StorageService.saveSettings({
      'language': lang, 'sound': sound, 'vibration': vibration,
      'server_url': serverUrl, 'round_time': roundTime,
    });
    notifyListeners();
  }

  // ── Session ─────────────────────────────────────────────
  LocalSession? session;
  RoomState? roomState;
  MyCard? myCard;
  List<ScoreEntry> scoreboard = [];
  bool get isHost => session?.isHost ?? false;

  // ── UI State ─────────────────────────────────────────────
  bool _isLoading = false;
  String? _lastError;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void clearError() { _lastError = null; notifyListeners(); }

  // ── Polling ─────────────────────────────────────────────
  Timer? _pollTimer;
  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _refreshRoomState());
  }
  void stopPolling() { _pollTimer?.cancel(); _pollTimer = null; }

  Future<void> _refreshRoomState() async {
    if (session == null) return;
    try {
      roomState = await _api.getRoomState(session!.roomId);
      _lastError = null;
      notifyListeners();
    } catch (_) {
      _lastError = L.t('connection_error');
      notifyListeners();
    }
  }

  // ── Countdown Timer ──────────────────────────────────────
  Timer? _countdownTimer;
  int countdownSeconds = 0;
  bool timerRunning = false;
  bool timerWarned = false;

  void startCountdown(int minutes) {
    _countdownTimer?.cancel();
    countdownSeconds = minutes * 60;
    timerRunning = true;
    timerWarned = false;
    notifyListeners();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdownSeconds <= 0) {
        t.cancel();
        timerRunning = false;
        SoundService.timerWarning();
        notifyListeners();
      } else {
        countdownSeconds--;
        // 30 second warning
        if (countdownSeconds == 30 && !timerWarned) {
          timerWarned = true;
          SoundService.timerWarning();
        }
        // Tick every 10s
        if (countdownSeconds % 10 == 0 && countdownSeconds > 0) {
          SoundService.timerTick();
        }
        notifyListeners();
      }
    });
  }

  void stopCountdown() {
    _countdownTimer?.cancel();
    timerRunning = false;
    countdownSeconds = 0;
    notifyListeners();
  }

  String get countdownDisplay {
    final m = countdownSeconds ~/ 60;
    final s = countdownSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get timerExpired => timerRunning == false && countdownSeconds == 0;

  // ── Game actions ─────────────────────────────────────────
  Future<void> createGame({
    required String creatorName, required int maxPlayers,
    required int spiesCount, required int roundsCount, required int roundTimeMinutes,
  }) async {
    _setLoading(true);
    try {
      final j = await _api.createRoom(
        creatorName: creatorName, maxPlayers: maxPlayers,
        spiesCount: spiesCount, roundsCount: roundsCount,
        roundTimeMinutes: roundTimeMinutes,
      );
      session = LocalSession(
        roomId: j['room_id'], roomCode: j['room_code'],
        playerId: j['player_id'], playerToken: j['player_token'],
        hostToken: j['host_token'], joinToken: j['join_token'],
      );
      _lastError = null;
      await _refreshRoomState();
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally { _setLoading(false); }
  }

  Future<void> joinGame({
    String? roomId, String? roomCode,
    required String joinToken, required String playerName,
  }) async {
    _setLoading(true);
    try {
      final j = await _api.joinRoom(
        roomId: roomId, roomCode: roomCode,
        joinToken: joinToken, playerName: playerName,
      );
      session = LocalSession(
        roomId: j['room_id'], roomCode: j['room_code'],
        playerId: j['player_id'], playerToken: j['player_token'],
        joinToken: joinToken,
      );
      _lastError = null;
      await _refreshRoomState();
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally { _setLoading(false); }
  }

  Future<void> startGame() async {
    if (session?.hostToken == null) return;
    _setLoading(true);
    try {
      await _api.startGame(roomId: session!.roomId, hostToken: session!.hostToken!);
      await _refreshRoomState();
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally { _setLoading(false); }
  }

  Future<void> fetchMyCard() async {
    if (session == null) return;
    try {
      myCard = await _api.getMyCard(roomId: session!.roomId, playerToken: session!.playerToken);
      notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
    }
  }

  Future<bool> endRound(String winner) async {
    if (session?.hostToken == null) return false;
    _setLoading(true);
    stopCountdown();
    try {
      final j = await _api.endRound(
        roomId: session!.roomId, hostToken: session!.hostToken!, winner: winner,
      );
      await _refreshRoomState();
      await SoundService.roundEnd();
      return j['game_finished'] == true;
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally { _setLoading(false); }
  }

  Future<void> fetchScoreboard() async {
    if (session == null) return;
    try {
      scoreboard = await _api.getScoreboard(session!.roomId);
      notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> saveGameToHistory() async {
    if (scoreboard.isEmpty) return;
    final players = scoreboard.map((s) => {
      'name': s.name,
      'stats': {
        'spy_wins': s.stats.spyWins,
        'civil_wins': s.stats.civilWins,
        'total_points': s.stats.totalPoints,
      }
    }).toList();

    final entry = GameHistoryEntry(
      date: DateTime.now().toString().substring(0, 16),
      roundsPlayed: roomState?.roundsCount ?? 0,
      winnerName: scoreboard.first.name,
      winnerPoints: scoreboard.first.stats.totalPoints,
      players: players,
    );

    await StorageService.addHistory(entry);
    await StorageService.updateLeaderboard(players);
  }

  String buildJoinQrData() {
    if (session == null) return '';
    return 'spygame://join?room_id=${session!.roomId}'
        '&join_token=${session!.joinToken}&room_code=${session!.roomCode}';
  }

  void resetGame() {
    stopPolling();
    stopCountdown();
    session = null;
    roomState = null;
    myCard = null;
    scoreboard = [];
    _lastError = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    stopCountdown();
    super.dispose();
  }
}
