import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../backend/music_manager.dart';
import '../backend/places.dart';
import '../backend/video_and_image.dart';
import '../backend/gallery_manager.dart';
import '../backend/settings_manager.dart';

class ZenMode extends StatefulWidget {
  final VoidCallback? onExit;
  final bool isActive; // Adicionado para controlar quando o modo está visível

  const ZenMode({super.key, this.onExit, this.isActive = false});

  @override
  State<ZenMode> createState() => _ZenModeState();
}

class _ZenModeState extends State<ZenMode> {
  List<Place> _places = [];
  bool _isLoading = true;
  Timer? _timer;
  final PageController _pageController = PageController();
  final settings = SettingsManager();

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      WakelockPlus.enable();
    }
    _loadData();
    _startTimer();
  }

  @override
  void didUpdateWidget(ZenMode oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ativa ou desativa o wakelock conforme a visibilidade muda no IndexedStack
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_pageController.hasClients && _places.isNotEmpty) {
        int nextPage = (_pageController.page?.round() ?? 0) + 1;
        if (nextPage >= _places.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadData() async {
    try {
      await MusicManager().startZenMusic();
      
      final unlockedNames = await GalleryManager().getUnlockedPlaceNames();
      
      final language = settings.language;
      String jsonPath;
      try {
        jsonPath = 'assets/data/places/places_$language.json';
        await rootBundle.loadString(jsonPath);
      } catch (_) {
        jsonPath = 'assets/data/places/places_English.json';
      }
      
      final String response = await rootBundle.loadString(jsonPath);
      final List<dynamic> data = json.decode(response);
      
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();

      List<Place> filteredPlaces = [];
      
      for (var item in data) {
        Place p = Place.fromJson(item);
        if (unlockedNames.contains(p.name)) {
          // Procure por algo assim e mude para:
          String fileName = p.name.replaceAll(' ', '_');
          String videoPath = 'assets/animations/$fileName.mp4';
          // Verifica se o vídeo existe, senão usa a imagem
          if (allAssets.contains(videoPath)) {
            p.videoPath = videoPath;
          } else {
            p.videoPath = 'assets/animations/${p.name}.png';
          }
          filteredPlaces.add(p);
        }
      }

      if (mounted) {
        setState(() {
          if (filteredPlaces.isEmpty) {
            _places = [
              Place(
                name: "Placeholder",
                country: "",
                description: "",
                videoPath: 'assets/animations/Placeholder.mp4',
              )
            ];
          } else {
            _places = filteredPlaces;
            _places.shuffle();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading Zen Mode: $e");
      if (mounted) {
        setState(() {
          _places = [
            Place(
              name: "Placeholder",
              country: "",
              description: "",
              videoPath: 'assets/animations/Placeholder.mp4',
            )
          ];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: widget.onExit,
        child: PageView.builder(
          controller: _pageController,
          itemCount: _places.length,
          itemBuilder: (context, index) {
            final place = _places[index];
            return SizedBox.expand(
              child: VideoOrImageBackground(
                path: place.videoPath,
              ),
            );
          },
        ),
      ),
    );
  }
}
