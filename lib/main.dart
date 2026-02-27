import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/game_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/create_game_screen.dart';
import 'screens/join_game_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/role_card_screen.dart';
import 'screens/round_control_screen.dart';
import 'screens/game_over_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
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
          '/splash':       (_) => const SplashScreen(),
          '/menu':         (_) => const MainMenuScreen(),
          '/create':       (_) => const CreateGameScreen(),
          '/join':         (_) => const JoinGameScreen(),
          '/lobby':        (_) => const LobbyScreen(),
          '/role_card':    (_) => const RoleCardScreen(),
          '/round_control':(_) => const RoundControlScreen(),
          '/game_over':    (_) => const GameOverScreen(),
        },
      ),
    );
  }
}
