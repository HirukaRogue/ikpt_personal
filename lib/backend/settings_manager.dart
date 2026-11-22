import 'package:flutter/foundation.dart';
import 'package:iknowthisplace/backend/language_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager extends ChangeNotifier {
  static final SettingsManager _instance = SettingsManager._internal();
  
  bool musicEnabled = true;
  bool soundEnabled = true;
  bool isPlaying = false; // Controla se o usuário está em uma tela de jogo
  
  late LanguageLoader lang;

  String get language => lang.selectedLanguage;

  factory SettingsManager() {
    return _instance;
  }

  SettingsManager._internal();

  // Atalho para facilitar as traduções
  String t(String key) => lang.translate(key);

  Future<void> loadSettings() async {
    lang = await LanguageLoader.load();

    final prefs = await SharedPreferences.getInstance();
    musicEnabled = prefs.getBool('musicEnabled') ?? true;
    soundEnabled = prefs.getBool('soundEnabled') ?? true;
    notifyListeners();
  }

  void setPlaying(bool value) {
    if (isPlaying != value) {
      isPlaying = value;
      notifyListeners();
    }
  }

  Future<void> setMusicEnabled(bool value) async {
    musicEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicEnabled', value);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    await lang.setLanguage(value);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    notifyListeners(); // Notifica o main.dart para atualizar o app todo
  }

  static const List<String> supportedLanguages = [
    'English',
    'Portuguese',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Japanese',
    'Korean',
    'Russian',
    'Hindi',
    'Bengali',
    'Arabic',
    'Mandarin_Chinese'
  ];
}
