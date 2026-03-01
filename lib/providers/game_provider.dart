import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../l10n/strings.dart';

class GameProvider extends ChangeNotifier {
  // ── Server URL – sabit, dəyişdirilmir ────────────────────
  static const String serverUrl = 'https://spygameserver.pythonanywhere.com';
  late ApiService _api;

  // ── Settings ─────────────────────────────────────────────
  String language = 'az';
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  int defaultRoundTime = 5;

  // ── Auth ─────────────────────────────────────────────────
  AuthUser? currentUser;
  bool get isLoggedIn => currentUser != null;

  // ── Game session ─────────────────────────────────────────
  LocalSession? session;
  RoomState? roomState;
  MyCard? myCard;
  List<ScoreEntry> scoreboard = [];
  List<RoundResult> roundResults = [];
  bool get isHost => session?.isHost ?? false;

  // ── Timer ─────────────────────────────────────────────────
  Timer? _countdown;
  int countdownSeconds = 0;
  bool timerRunning = false;
  bool timerWarned = false;
  String get countdownDisplay {
    final m = countdownSeconds ~/ 60;
    final s = countdownSeconds % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }
  bool get timerExpired => !timerRunning && countdownSeconds == 0;

  // ── UI ────────────────────────────────────────────────────
  bool _loading = false;
  String? _error;
  bool get isLoading => _loading;
  String? get lastError => _error;
  void clearError() { _error = null; notifyListeners(); }
  void _setLoading(bool v) { _loading = v; notifyListeners(); }

  GameProvider() {
    _api = ApiService(serverUrl);
    _init();
  }

  Future<void> _init() async {
    final s = await StorageService.getSettings();
    language         = s['language'] ?? 'az';
    soundEnabled     = s['sound'] ?? true;
    vibrationEnabled = s['vibration'] ?? true;
    defaultRoundTime = s['round_time'] ?? 5;
    L.setLang(language);
    SoundService.soundEnabled = soundEnabled;
    SoundService.vibrationEnabled = vibrationEnabled;
    _api = ApiService(serverUrl);

    // Auto-login
    final auth = await StorageService.getAuth();
    if (auth['token'] != null) {
      _api.setToken(auth['token']);
      try {
        currentUser = await _api.getMe();
      } catch (_) {
        await StorageService.clearAuth();
        _api.setToken(null);
      }
    }
    notifyListeners();
  }

  // ── Auth ──────────────────────────────────────────────────
  Future<void> register(String username, String password) async {
    _setLoading(true);
    try {
      final user = await _api.register(username, password);
      _api.setToken(user.token);
      await StorageService.saveAuth(token: user.token, username: user.username, userId: user.userId);
      currentUser = user;
      _error = null;
    } catch (e) { _error = e.toString(); rethrow; }
    finally { _setLoading(false); }
  }

  Future<void> login(String username, String password) async {
    _setLoading(true);
    try {
      final user = await _api.login(username, password);
      _api.setToken(user.token);
      await StorageService.saveAuth(token: user.token, username: user.username, userId: user.userId);
      currentUser = user;
      _error = null;
    } catch (e) { _error = e.toString(); rethrow; }
    finally { _setLoading(false); }
  }

  Future<void> logout() async {
    await _api.logout();
    await StorageService.clearAuth();
    currentUser = null;
    resetGame();
    notifyListeners();
  }

  // ── Settings (URL yoxdur artıq) ───────────────────────────
  Future<void> saveSettings({required String lang, required bool sound,
      required bool vibration, required int roundTime}) async {
    language = lang; soundEnabled = sound;
    vibrationEnabled = vibration; defaultRoundTime = roundTime;
    L.setLang(lang);
    SoundService.soundEnabled = sound;
    SoundService.vibrationEnabled = vibration;
    await StorageService.saveSettings({
      'language': lang, 'sound': sound, 'vibration': vibration, 'round_time': roundTime,
    });
    notifyListeners();
  }

  // ── Polling ───────────────────────────────────────────────
  Timer? _poll;
  void startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 2), (_) => _refreshRoom());
  }
  void stopPolling() { _poll?.cancel(); _poll = null; }

  Future<void> _refreshRoom() async {
    if (session == null) return;
    try {
      roomState = await _api.getRoomState(session!.roomId);
      _error = null; notifyListeners();
    } catch (_) {
      _error = L.t('connection_error'); notifyListeners();
    }
  }

  // ── Countdown ─────────────────────────────────────────────
  void startCountdown(int minutes) {
    _countdown?.cancel();
    countdownSeconds = minutes * 60;
    timerRunning = true; timerWarned = false;
    notifyListeners();
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdownSeconds <= 0) {
        t.cancel(); timerRunning = false; SoundService.timerWarning(); notifyListeners();
      } else {
        countdownSeconds--;
        if (countdownSeconds == 30 && !timerWarned) { timerWarned = true; SoundService.timerWarning(); }
        if (countdownSeconds % 10 == 0 && countdownSeconds > 0) SoundService.timerTick();
        notifyListeners();
      }
    });
  }
  void stopCountdown() { _countdown?.cancel(); timerRunning = false; countdownSeconds = 0; notifyListeners(); }

  // ── Game actions ──────────────────────────────────────────
  Future<void> createGame({required int maxPlayers, required int spiesCount,
      required int roundsCount, required int roundTimeMinutes}) async {
    _setLoading(true);
    try {
      final j = await _api.createRoom(maxPlayers: maxPlayers, spiesCount: spiesCount,
          roundsCount: roundsCount, roundTimeMinutes: roundTimeMinutes, lang: language);
      session = LocalSession(roomId: j['room_id'], roomCode: j['room_code'],
          playerId: j['player_id'], playerToken: j['player_token'],
          hostToken: j['host_token'], joinToken: j['join_token']);
      _error = null;
      await _refreshRoom();
    } catch (e) { _error = e.toString(); rethrow; }
    finally { _setLoading(false); }
  }

  Future<void> joinGame({String? roomId, String? roomCode, required String joinToken}) async {
    _setLoading(true);
    try {
      final j = await _api.joinRoom(roomId: roomId, roomCode: roomCode, joinToken: joinToken);
      session = LocalSession(roomId: j['room_id'], roomCode: j['room_code'],
          playerId: j['player_id'], playerToken: j['player_token'], joinToken: joinToken);
      _error = null;
      await _refreshRoom();
    } catch (e) { _error = e.toString(); rethrow; }
    finally { _setLoading(false); }
  }

  Future<void> startGame() async {
    if (session?.hostToken == null) return;
    _setLoading(true);
    try {
      await _api.startGame(roomId: session!.roomId, hostToken: session!.hostToken!);
      await _refreshRoom();
    } catch (e) { _error = e.toString(); rethrow; }
    finally { _setLoading(false); }
  }

  Future<void> fetchMyCard() async {
    if (session == null) return;
    try {
      myCard = await _api.getMyCard(roomId: session!.roomId, playerToken: session!.playerToken);
      notifyListeners();
    } catch (e) { _error = e.toString(); notifyListeners(); }
  }

  Future<bool> endRound(String winner) async {
    if (session?.hostToken == null) return false;
    _setLoading(true); stopCountdown();
    try {
      final j = await _api.endRound(roomId: session!.roomId, hostToken: session!.hostToken!, winner: winner);
      await _refreshRoom();
      await SoundService.roundEnd();
      return j['game_finished'] == true;
    } catch (e) { _error = e.toString(); rethrow; }
    finally { _setLoading(false); }
  }

  Future<void> fetchScoreboard() async {
    if (session == null) return;
    try {
      final j = await _api.getScoreboardRaw(session!.roomId);
      scoreboard = (j['scoreboard'] as List).map((e) => ScoreEntry.fromJson(e as Map<String,dynamic>)).toList();
      roundResults = (j['rounds'] as List? ?? []).map((e) => RoundResult.fromJson(e as Map<String,dynamic>)).toList();
      if (currentUser != null) {
        try { currentUser = await _api.getMe(); } catch (_) {}
      }
      notifyListeners();
    } catch (e) { _error = e.toString(); notifyListeners(); }
  }

  String buildJoinQrData() {
    if (session == null) return '';
    return 'spygame://join?room_id=${session!.roomId}&join_token=${session!.joinToken}&room_code=${session!.roomCode}';
  }

  void resetGame() {
    stopPolling(); stopCountdown();
    session = null; roomState = null; myCard = null;
    scoreboard = []; roundResults = [];
    _error = null; _loading = false;
    notifyListeners();
  }

  @override
  void dispose() { stopPolling(); stopCountdown(); super.dispose(); }
}
