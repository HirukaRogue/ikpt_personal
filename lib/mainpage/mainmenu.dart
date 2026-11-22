import 'package:flutter/material.dart';
import 'package:iknowthisplace/backend/gallery_manager.dart';
import 'package:iknowthisplace/backend/settings_manager.dart';
import 'package:iknowthisplace/cardbuttons/daily_pick_card.dart';
import 'package:iknowthisplace/cardbuttons/other_buttons.dart';
import 'package:iknowthisplace/cardbuttons/play_card_button.dart';
import 'package:iknowthisplace/cardbuttons/zen_card_button.dart';

class MainMenu extends StatefulWidget {
  final VoidCallback? onPlayPressed;
  final VoidCallback onZenPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onStorePressed;
  final VoidCallback onSettingsPressed;
  final SettingsManager settings;

  const MainMenu({
    super.key,
    required this.onPlayPressed,
    required this.onZenPressed,
    required this.onGalleryPressed,
    required this.onStorePressed,
    required this.onSettingsPressed,
    required this.settings
  });

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _unlockedLocations = 0;

  @override
  void initState() {
    super.initState();
    _loadUnlockedLocations();
  }

  Future<void> _loadUnlockedLocations() async {
    try {
      final unlockedNames = await GalleryManager().getUnlockedPlaceNames();
      if (mounted) {
        setState(() {
          _unlockedLocations = unlockedNames.length;
        });
      }
    } catch (e) {
      debugPrint("Error loading unlocked locations: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.settings.t("welcome"),
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.settings.t("explore"),
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: 48),

            PlayCardButton(onTap: widget.onPlayPressed, settings: widget.settings),
            const SizedBox(height: 16),
            
            ZenCardButton(onTap: widget.onZenPressed, settings: widget.settings,),
            const SizedBox(height: 16),
            
            OtherButtons(
              onTap: widget.onGalleryPressed,
              icon: Icons.photo_library_outlined,
              iconColor: const Color(0xFF197492),
              title: widget.settings.t("gallery"),
              subtitle: "$_unlockedLocations ${widget.settings.t("locations_found")}",
            ),
            const SizedBox(height: 16),
            
            OtherButtons(
              onTap: widget.onStorePressed,
              icon: Icons.shopping_bag_outlined,
              iconColor: const Color(0xFFB31446),
              title: widget.settings.t("store"),
              subtitle: widget.settings.t("hints_available"),
            ),
            const SizedBox(height: 16),
            
            OtherButtons(
              onTap: widget.onSettingsPressed,
              icon: Icons.settings_outlined,
              iconColor: const Color(0xFF366173),
              title: widget.settings.t("settings"),
              subtitle: widget.settings.t("music_profile"),
            ),
            const SizedBox(height: 32),
            
            DailyPickCard(
              title: "The Emerald Valley",
              description: "Hidden deep in the northern ranges, this valley holds secrets only the keenest eyes can find.",
              assetPath: "assets/animations/Matterhorn.png",
              settings: widget.settings,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
