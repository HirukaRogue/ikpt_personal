import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:iknowthisplace/below_menu/menu_nav.dart';
import 'package:iknowthisplace/backend/settings_manager.dart';

class Gameover extends StatefulWidget {
  final SettingsManager settings;

  const Gameover({
    super.key,
    required this.settings
  });

  @override
  State<Gameover> createState() => _GameoverState();
}

class _GameoverState extends State<Gameover> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playGameOverSound();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playGameOverSound() async {
    // Check if sound is enabled
    if (!SettingsManager().soundEnabled) return;

    try {
      await _audioPlayer.play(AssetSource('sound/game_over.mp3'));
    } catch (e) {
      debugPrint("Error playing game over sound: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Game Over", style: TextStyle(
              fontSize: 55,
              color: Colors.white,
              fontWeight: FontWeight.bold
            )),
            const Text("You lost all your hearts", style: TextStyle(
              fontSize: 20,
              color: Colors.white
            )),
            const SizedBox(height: 230),
            ElevatedButton(onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuNav(settings: widget.settings)
                  )
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Back to home")
            ),
            const SizedBox(height: 200),
          ],
        )
      ),
    );
  }
}
