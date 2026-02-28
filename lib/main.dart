import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'services/sound_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/create_game_screen.dart';
import 'screens/join_game_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/role_card_screen.dart';
import 'screens/round_control_screen.dart';
import 'screens/game_stats_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SoundService.init();
  runApp(const SpyGameApp());
}

class SpyGameApp extends StatelessWidget {
  const SpyGameApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: 'Spy Game',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: '/splash',
        routes: {
          '/splash':        (_) => const SplashScreen(),
          '/login':         (_) => const LoginScreen(),
          '/menu':          (_) => const MainMenuScreen(),
          '/create':        (_) => const CreateGameScreen(),
          '/join':          (_) => const JoinGameScreen(),
          '/lobby':         (_) => const LobbyScreen(),
          '/role_card':     (_) => const RoleCardScreen(),
          '/round_control': (_) => const RoundControlScreen(),
          '/game_stats':    (_) => const GameStatsScreen(),
          '/leaderboard':   (_) => const LeaderboardScreen(),
          '/settings':      (_) => const SettingsScreen(),
        },
      ),
    );
  }
}
