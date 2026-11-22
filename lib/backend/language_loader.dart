import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class LanguageLoader {
  String _selectedLanguage = 'English';
  Map<String, dynamic> _translation = {};

  String get selectedLanguage => _selectedLanguage;
  Map<String, dynamic> get translation => _translation;

  LanguageLoader._();

  static Future<LanguageLoader> load() async {
    final instance = LanguageLoader._();
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final saveFile = File('${directory.path}/language_save.json');

      if (await saveFile.exists()) {
        final content = await saveFile.readAsString();
        final data = jsonDecode(content);
        
        instance._selectedLanguage = data['language'] ?? 'English';
      } else {
        instance._selectedLanguage = 'English';
        await instance.save();
      }
    } catch (e) {
      print("Error loading language: $e");
      instance._selectedLanguage = 'English';
    }

    await instance._loadTranslations();
    
    return instance;
  }

  Future<void> _loadTranslations() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/lang/$_selectedLanguage.json');
      _translation = jsonDecode(jsonString);
    } catch (e) {
      print("Error loading translation asset: $e");
      try {
        final String jsonString = await rootBundle.loadString('assets/data/lang/English.json');
        _translation = jsonDecode(jsonString);
      } catch (_) {}
    }
  }

  String translate(String key) {
    return _translation[key] ?? key;
  }

  Future<void> save() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final saveFile = File('${directory.path}/language_save.json');
      
      final data = {
        'language': _selectedLanguage,
      };
      await saveFile.writeAsString(jsonEncode(data));
    } catch (e) {
      print("Error saving language: $e");
    }
  }

  Future<void> setLanguage(String newLanguage) async {
    _selectedLanguage = newLanguage;
    await save();
    await _loadTranslations();
  }
}
