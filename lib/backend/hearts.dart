import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'billing_manager.dart';

class Hearts extends ChangeNotifier {
  static final Hearts _instance = Hearts._();
  factory Hearts() => _instance;
  Hearts._();

  int _hearts = 3;
  bool _isUnlimited = false;
  DateTime _lastUpdate = DateTime.now();

  int get hearts => _isUnlimited ? 3 : _hearts;
  bool get isUnlimited => _isUnlimited;

  static Future<Hearts> load() async {
    final instance = Hearts();

    // Sincroniza com o status da loja ao carregar
    instance._isUnlimited = await BillingManager().checkUnlimitedStatus();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final saveFile = File('${directory.path}/hearts_save.json');

      if (await saveFile.exists()) {
        final content = await saveFile.readAsString();
        final data = jsonDecode(content);
        
        instance._hearts = (data['hearts'] as int).clamp(0, 3);
        instance._lastUpdate = DateTime.parse(data['last_update'] ?? DateTime.now().toIso8601String());

        if (!instance._isUnlimited && instance._hearts < 3) {
          final now = DateTime.now();
          final difference = now.difference(instance._lastUpdate);
          
          if (difference.inHours >= 24) {
            instance._hearts = 3;
            instance._lastUpdate = now;
            await instance.save();
          }
        }
      } else {
        instance._hearts = 3;
        instance._lastUpdate = DateTime.now();
        await instance.save();
      }
    } catch (e) {
      debugPrint("Error loading hearts: $e");
      instance._hearts = 3;
    }
    
    return instance;
  }

  Future<void> save() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final saveFile = File('${directory.path}/hearts_save.json');
      
      final data = {
        'hearts': _hearts,
        'last_update': _lastUpdate.toIso8601String(),
      };
      await saveFile.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint("Error saving hearts: $e");
    }
  }

  void addHeart() {
    if (_isUnlimited) return;
    if (_hearts < 3) {
      _hearts++;
      if (_hearts == 3) {
        _lastUpdate = DateTime.now();
      }
      save();
      notifyListeners();
    }
  }

  void removeHeart() {
    if (_isUnlimited) return;
    if (_hearts > 0) {
      _hearts--;
      save();
      notifyListeners();
    }
  }

  void setHearts(int newHearts) {
    if (_isUnlimited) return;
    _hearts = newHearts.clamp(0, 3);
    if (_hearts == 3) {
      _lastUpdate = DateTime.now();
    }
    save();
    notifyListeners();
  }

  void setUnlimited(bool value) {
    if (_isUnlimited != value) {
      _isUnlimited = value;
      notifyListeners();
    }
  }
}
