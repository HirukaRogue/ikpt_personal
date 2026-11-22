import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import 'package:iknowthisplace/backend/settings_manager.dart';
import 'package:iknowthisplace/backend/video_and_image.dart';
import 'package:iknowthisplace/game/quiz.dart';
import 'package:iknowthisplace/below_menu/menu_nav.dart';
import '../backend/gallery_manager.dart';
import '../backend/hearts.dart';
import '../backend/places.dart';

class AssetShow extends StatefulWidget {
  final Hearts hearts;
  final SettingsManager settings;
  final VoidCallback onExit;
  final bool isActive;

  const AssetShow({
    super.key,
    required this.hearts,
    required this.settings,
    required this.onExit,
    this.isActive = true,
  });

  @override
  State<AssetShow> createState() => _AssetShowState();
}

class _AssetShowState extends State<AssetShow> {
  List<Place> _places = [];
  Place? _currentPlace;
  bool _isLoading = true;
  bool _showQuiz = false;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  @override
  void dispose() {
    MenuNav.setAssetShowQuizMode(false);
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    try {
      final language = widget.settings.language;
      String jsonString;
      try {
        jsonString = await rootBundle.loadString('assets/data/places/places_$language.json');
      } catch (_) {
        jsonString = await rootBundle.loadString('assets/data/places/places_English.json');
      }
      
      final List<dynamic> data = json.decode(jsonString);
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();

      List<Place> loadedPlaces = [];
      for (var item in data) {
        Place p = Place.fromJson(item);
        
        String name = p.name.replaceAll(" ", "_");
        String firstName = name.split(' ').first;
        
        String mp4Path = 'assets/animations/$name.mp4';
        String pngPath = 'assets/animations/$name.png';

        bool hasVideo = allAssets.any((a) => a.toLowerCase() == mp4Path.toLowerCase());
        bool hasImage = allAssets.any((a) => a.toLowerCase() == pngPath.toLowerCase());
        
        if (!hasVideo && !hasImage) {
          mp4Path = 'assets/animations/$firstName.mp4';
          pngPath = 'assets/animations/$firstName.png';
          hasVideo = allAssets.any((a) => a.toLowerCase() == mp4Path.toLowerCase());
          hasImage = allAssets.any((a) => a.toLowerCase() == pngPath.toLowerCase());
        }

        if (hasVideo) {
          p.videoPath = mp4Path;
        } else if (hasImage) {
          p.videoPath = pngPath;
        } else {
          p.videoPath = 'assets/animations/Placeholder.mp4';
        }

        p.assetPath = hasImage ? pngPath : p.videoPath.replaceAll('.mp4', '.png');
        
        loadedPlaces.add(p);
      }

      setState(() {
        _places = loadedPlaces;
        _isLoading = false;
      });
      await _pickRandomPlace();
    } catch (e) {
      debugPrint('Error! Failed to load places: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickRandomPlace() async {
    if (_places.isEmpty) return;

    final unlockedNames = await GalleryManager().getUnlockedPlaceNames();

    List<Place> availablePlaces = _places.where((p) => !unlockedNames.contains(p.name)).toList();

    Place nextPlace;
    if (availablePlaces.isEmpty) {
      availablePlaces = List.from(_places);
    }

    if (availablePlaces.length > 1 && _currentPlace != null) {
      final otherPlaces = availablePlaces.where((p) => p.name != _currentPlace!.name).toList();
      otherPlaces.shuffle();
      nextPlace = otherPlaces.first;
    } else {
      availablePlaces.shuffle();
      nextPlace = availablePlaces.first;
    }

    setState(() {
      _currentPlace = nextPlace;
      _showQuiz = false;
      MenuNav.setAssetShowQuizMode(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_currentPlace == null) return const Center(child: Text('No places found.'));

    if (_showQuiz) {
      return Quiz(
        place: _currentPlace!,
        hearts: widget.hearts,
        isActive: widget.isActive,
        onResult: (correct) {
          if (correct) {
            _pickRandomPlace();
          } else {
            setState(() {
              _showQuiz = false;
              MenuNav.setAssetShowQuizMode(false);
            });
          }
        }, 
        settings: widget.settings,
        onExit: widget.onExit,
      );
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showQuiz = true;
              MenuNav.setAssetShowQuizMode(true);
            });
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: VideoOrImageBackground(
              key: ValueKey(_currentPlace!.videoPath),
              path: _currentPlace!.videoPath,
              isActive: widget.isActive,
            ),
          ),
        ),
        // Botão de Sair (X)
        Positioned(
          top: 40,
          right: 20,
          child: SafeArea(
            child: GestureDetector(
              onTap: widget.onExit,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
