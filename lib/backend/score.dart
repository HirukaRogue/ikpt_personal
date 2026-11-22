import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Score {
  int _score = 0;

  int get score => _score;
  
  Score._();
  
  static Future<Score> load() async {
    final instance = Score._();
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final saveFile = File('${directory.path}/score_save.json');
      
      if (await saveFile.exists()) {
        final content = await saveFile.readAsString();
        final data = jsonDecode(content);
        
        instance._score = (data['score'] as int? ?? 0);
      } else {
        instance._score = 0;
        await instance.save();
      }
    } catch (e) {
      print("Error loading score: $e");
      instance._score = 0;
    }
    return instance;
  }
  
  Future<void> save() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final saveFile = File('${directory.path}/score_save.json');
      
      final data = {
        'score': _score,
      };
      await saveFile.writeAsString(jsonEncode(data));
    } catch (e) {
      print("Error saving score: $e");
    }
  }
  
  void addScore(int points) {
    _score += points;
    save();
  }
  
  void subtractScore(int points) {
    _score -= points;
    if (_score < 0) _score = 0;
    save();
  }
  
  void resetScore() {
    _score = 0;
    save();
  }
}
