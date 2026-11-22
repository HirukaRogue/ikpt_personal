import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../backend/places.dart';
import '../backend/score.dart';
import '../backend/gallery_manager.dart';
import '../backend/settings_manager.dart';
import 'place_detail.dart';

class Gallery extends StatefulWidget {
  final SettingsManager settings;
  
  const Gallery({
    super.key,
    required this.settings
  });

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List<Place> _unlockedPlaces = [];
  Map<String, String> _countryFlags1x1 = {};
  bool _isLoading = true;
  Score? _score;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final score = await Score.load();
      final language = widget.settings.language;

      // 1. Load localized places from JSON
      final String placesRes = await rootBundle.loadString('assets/data/places/places_$language.json');
      final List<dynamic> placesData = json.decode(placesRes);
      
      final List<Place> allPlaces = placesData.map((json) {
        Place p = Place.fromJson(json);
        // Changed from assets/gallery to assets/animations as per file structure
        String imagePath = 'assets/animations/${p.name.replaceAll(" ", "_")}.png';
        p.assetPath = imagePath;
        return p;
      }).toList();

      // 2. Load flags from country.json (using the localized version if available, otherwise English)
      String countryRes;
      try {
        countryRes = await rootBundle.loadString('assets/data/countries/countries_$language.json');
      } catch (e) {
        countryRes = await rootBundle.loadString('assets/data/countries/countries_English.json');
      }
      final List<dynamic> countryData = json.decode(countryRes);
      
      final flagsMap = {
        for (var item in countryData) 
          (item['name'] as String): (item['flag_1x1'] as String? ?? item['flag_4x3'] as String? ?? item['flag'] as String)
      };

      // 3. Get the names of unlocked places (correct answers)
      final List<String> unlockedNames = await GalleryManager().getUnlockedPlaceNames();

      if (mounted) {
        setState(() {
          _score = score;
          _countryFlags1x1 = flagsMap;
          _unlockedPlaces = allPlaces.where((p) => unlockedNames.contains(p.name)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading gallery data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 110), // Space for pill header
              
              Text(
                widget.settings.t('collection'),
                style: const TextStyle(
                  fontSize: 14, 
                  color: Color(0xFF1DE9B6), 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                widget.settings.t('gallery'),
                style: const TextStyle(
                  fontSize: 36, 
                  color: Color(0xFF002333), 
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 80,
                height: 4,
                color: const Color(0xFFFFD166), // Yellow/Orange line
              ),
              const SizedBox(height: 20),
              Text(
                widget.settings.t('gallery_subtitle'),
                style: const TextStyle(
                  fontSize: 16, 
                  color: Color(0xFF366173), 
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 30),
              
              if (_unlockedPlaces.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _unlockedPlaces.length,
                  itemBuilder: (context, index) => _buildPlaceCard(_unlockedPlaces[index]),
                ),

              const SizedBox(height: 20),
              _buildScoreCard(),
              const SizedBox(height: 20),
              _buildBadgesCard(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Icon(Icons.photo_library_outlined, size: 60, color: Color(0xFF366173)),
          const SizedBox(height: 16),
          Text(
            widget.settings.t('empty_gallery'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Color(0xFF002333), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.settings.t('empty_gallery_desc'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF366173)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(Place place) {
    return GestureDetector(
      onTap: () {
        final flagUrl = _countryFlags1x1[place.country] ?? "";
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetail(place: place, flagUrl: flagUrl, settings: widget.settings,),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        height: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                place.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, color: Colors.white, size: 50),
                ),
              ),
              // "DISCOVERED" Badge
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD166),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, size: 16, color: Color(0xFF002333)),
                      const SizedBox(width: 4),
                      Text(
                        widget.settings.t('discovered'),
                        style: const TextStyle(color: Color(0xFF002333), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              // Gradient overlay for texts
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              // Texts and Progress Bar
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.country.toUpperCase(),
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                    ),
                    Text(
                      place.name,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: const LinearProgressIndicator(
                              value: 1.0,
                              backgroundColor: Colors.white24,
                              color: Color(0xFF1DE9B6),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text("100%", style: TextStyle(color: Color(0xFF1DE9B6), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.settings.t('total_score'),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF366173).withOpacity(0.8), letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _score?.score.toString() ?? "0",
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF002333)),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.star_rounded, color: Colors.amber[400], size: 36),
                    ],
                  ),
                ],
              ),
            ),
            Container(height: 6, width: double.infinity, color: const Color(0xFF1DE9B6)),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.settings.t('badges'),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF366173).withOpacity(0.8), letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _BadgeIcon(icon: Icons.explore, color: Colors.blue, label: "Explorer"),
                      _BadgeIcon(icon: Icons.history_edu, color: Colors.orange, label: "Historian"),
                      _BadgeIcon(icon: Icons.public, color: Colors.green, label: "Globetrotter"),
                    ],
                  ),
                ],
              ),
            ),
            Container(height: 6, width: double.infinity, color: const Color(0xFFFFD166)),
          ],
        ),
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _BadgeIcon({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF366173))),
      ],
    );
  }
}
