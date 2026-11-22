import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:iknowthisplace/backend/settings_manager.dart';

class MusicManager {
  static final MusicManager _instance = MusicManager._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentMusicPath;
  List<String> _zenPlaylist = [];
  int _currentIndex = -1;
  final Random _random = Random();

  factory MusicManager() {
    return _instance;
  }

  MusicManager._internal() {
    _audioPlayer.setReleaseMode(ReleaseMode.stop); 
    _configureAudioContext();
    
    _audioPlayer.onPlayerComplete.listen((event) {
      if (_zenPlaylist.isNotEmpty) {
        _playNextZenMusic();
      }
    });
  }

  void _configureAudioContext() {
    AudioPlayer.global.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        usageType: AndroidUsageType.game,
        contentType: AndroidContentType.music,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
      ),
    ));
  }

  /// Desabilitado conforme solicitação: Não toca música no fundo geral
  Future<void> startBackgroundMusic() async {
    await stopBackgroundMusic();
  }

  /// Inicia a playlist do Modo Zen
  Future<void> startZenMusic() async {
    if (!SettingsManager().musicEnabled) return;
    if (_zenPlaylist.isNotEmpty && _isPlaying) return; // Já está tocando no Zen

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();
      
      _zenPlaylist = allAssets
          .where((path) => 
            path.startsWith('assets/music/') && 
            (path.endsWith('.mp3') || path.endsWith('.wav') || path.endsWith('.m4a')))
          .toList();

      if (_zenPlaylist.isNotEmpty) {
        _zenPlaylist.shuffle(_random);
        _currentIndex = -1;
        await _playNextZenMusic();
      }
    } catch (e) {
      debugPrint("Error loading Zen playlist: $e");
    }
  }

  Future<void> _playNextZenMusic() async {
    if (_zenPlaylist.isEmpty) return;
    
    _currentIndex++;
    if (_currentIndex >= _zenPlaylist.length) {
      _zenPlaylist.shuffle(_random);
      _currentIndex = 0;
    }
    
    final nextMusic = _zenPlaylist[_currentIndex];
    
    try {
      await _audioPlayer.stop();
      String relativePath = nextMusic.replaceFirst('assets/', '');
      await _audioPlayer.play(AssetSource(relativePath));
      _isPlaying = true;
      _currentMusicPath = nextMusic;
    } catch (e) {
      debugPrint("Error playing music $nextMusic: $e");
      // Tenta a próxima se houver erro
      if (_zenPlaylist.length > 1) _playNextZenMusic();
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _currentMusicPath = null;
    _zenPlaylist = [];
    _currentIndex = -1;
  }

  Future<void> pauseBackgroundMusic() async {
    if (!_isPlaying) return;
    await _audioPlayer.pause();
    _isPlaying = false;
  }

  Future<void> resumeBackgroundMusic() async {
    // Só resume se houver algo carregado (que seria do modo Zen)
    if (_isPlaying || !SettingsManager().musicEnabled || _currentMusicPath == null) return;
    await _audioPlayer.resume();
    _isPlaying = true;
  }

  Future<void> handleTabChange(int index) async {
    // 5: ZenMode
    if (index == 5) {
      await startZenMusic();
    } else {
      await stopBackgroundMusic();
    }
  }

  Future<void> toggleMusic(bool enabled) async {
    await SettingsManager().setMusicEnabled(enabled);
    if (!enabled) {
      await stopBackgroundMusic();
    }
  }
}
