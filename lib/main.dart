import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iknowthisplace/backend/settings_manager.dart';
import 'package:iknowthisplace/backend/music_manager.dart';
import 'package:iknowthisplace/onboarding/onboarding_screen.dart';
import 'package:iknowthisplace/below_menu/menu_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backend/billing_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Manter o app em tela cheia (Immersive Mode)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Inicia o sistema de cobrança
  BillingManager().initialize();

  // Load Settings
  final settings = SettingsManager();
  await settings.loadSettings();

  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(MyApp(showOnboarding: !onboardingCompleted));
}

class MyApp extends StatefulWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final settings = SettingsManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      MusicManager().pauseBackgroundMusic();
    } else if (state == AppLifecycleState.resumed) {
      MusicManager().resumeBackgroundMusic();
      // Garante que volte para tela cheia ao retomar o app
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'I Know This Place',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: widget.showOnboarding ? OnboardingScreen(settings: settings) : MenuNav(settings: settings),
        );
      },
    );
  }
}
