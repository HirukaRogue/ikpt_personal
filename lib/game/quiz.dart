import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iknowthisplace/backend/hearts.dart';
import 'package:iknowthisplace/backend/places.dart';
import 'package:iknowthisplace/backend/video_and_image.dart';
import 'package:iknowthisplace/backend/settings_manager.dart';
import 'package:iknowthisplace/backend/gallery_manager.dart';
import 'package:iknowthisplace/below_menu/menu_nav.dart';

import '../backend/country.dart';
import '../backend/quiz_option_cache.dart';
import '../backend/score.dart';

class Quiz extends StatefulWidget {
  final Place place;
  final Hearts hearts;
  final Function(bool) onResult;
  final SettingsManager settings;
  final VoidCallback onExit;
  final bool isActive;

  const Quiz({
    super.key,
    required this.place,
    required this.hearts,
    required this.onResult,
    required this.settings,
    required this.onExit,
    this.isActive = true,
  });

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late List<Country> _options;
  bool _isLoadingOptions = true;
  bool error = false;

  bool _answered = false;
  bool _lastAnswerCorrect = false;
  String? _selectedCountryName;

  Score? _score;

  late AnimationController _rgbController;
  late Animation<Color?> _rgbAnimation;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Lógica da animação RGB para corações ilimitados
    _rgbController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rgbAnimation = _rgbController.drive(
      ColorTweenSequence([
        ColorTween(begin: Colors.red, end: Colors.green),
        ColorTween(begin: Colors.green, end: Colors.blue),
        ColorTween(begin: Colors.blue, end: Colors.red),
      ]),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _rgbController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      _score = await Score.load();
      final options = await QuizOptionsCache.getShuffledOptions(widget.place);
      if (!mounted) return;
      setState(() {
        _options = options;
        _isLoadingOptions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingOptions = false;
        error = true;
      });
    }
  }

  Future<void> _playSound(String fileName) async {
    if (!widget.settings.soundEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sound/$fileName'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  void _handleAnswer(String selectedName) {
    if (_answered) return;

    final isCorrect = selectedName == widget.place.country;

    setState(() {
      _answered = true;
      _lastAnswerCorrect = isCorrect;
      _selectedCountryName = selectedName;

      if (isCorrect) {
        _playSound('correct_answer.mp3');
        GalleryManager().unlockPlace(widget.place.name);
        _score?.addScore(10);
        MenuNav.refreshUI();
      } else {
        _playSound('wrong_answer.mp3');
        widget.hearts.removeHeart();
        _score?.subtractScore(5);
        MenuNav.refreshUI();
      }
    });
  }

  void _handleContinue() {
    if (!_lastAnswerCorrect) {
      QuizOptionsCache.clear();
    }
    widget.onResult(_lastAnswerCorrect);
  }

  Widget _buildOptionButton(int index) {
    final country = _options[index];
    final isSelected = _selectedCountryName == country.countryName;
    final isCorrect = country.countryName == widget.place.country;

    Color borderColor = Colors.transparent;
    if (_answered && isSelected) {
      if (isCorrect) {
        borderColor = Colors.green;
      } else {
        borderColor = Colors.red;
      }
    }

    return GestureDetector(
      onTap: _answered ? null : () => _handleAnswer(country.countryName),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SvgPicture.asset(
                    country.flag4x3 ?? country.countryFlag,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                country.countryName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF002333)),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingOptions) return const Center(child: CircularProgressIndicator());

    return Stack(
      children: [
        VideoOrImageBackground(
          path: widget.place.assetPath,
          isActive: widget.isActive,
        ),
        
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FBFF).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.settings.t("app_name_top"),
                                style: const TextStyle(color: Color(0xFF002333), fontSize: 18, fontWeight: FontWeight.w900, height: 1.1)
                              ),
                              Text(
                                widget.settings.t("app_name_bottom"),
                                style: const TextStyle(color: Color(0xFF002333), fontSize: 18, fontWeight: FontWeight.w900, height: 1.1)
                              ),
                            ],
                          ),
                        ),
                        _buildHeartsIndicator(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Botão de Sair (X) para sair do jogo
                GestureDetector(
                  onTap: widget.onExit,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ),

        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 110), // Espaço para a Top Bar
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Text(
                      widget.settings.t("quiz_question"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF002333)),
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) => _buildOptionButton(index),
                  ),
                ),

                if (_answered)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006D4E),
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: Text(widget.settings.t("quiz_continue"), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeartsIndicator() {
    bool isUnlimited = widget.hearts.isUnlimited;
    int currentHearts = widget.hearts.hearts;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isUnlimited ? "∞" : "$currentHearts",
          style: const TextStyle(
            color: Color(0xFF002333),
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 6),
        if (isUnlimited)
          AnimatedBuilder(
            animation: _rgbAnimation,
            builder: (context, child) {
              return Icon(
                Icons.favorite,
                color: _rgbAnimation.value,
                size: 28,
              );
            },
          )
        else
          const Icon(
            Icons.favorite,
            color: Color(0xFFE91E63),
            size: 24,
          ),
      ],
    );
  }
}

class ColorTweenSequence extends Animatable<Color?> {
  final List<ColorTween> tweens;
  ColorTweenSequence(this.tweens);

  @override
  Color? transform(double t) {
    final int count = tweens.length;
    final int index = (t * count).floor().clamp(0, count - 1);
    final double localT = (t * count) - index;
    return tweens[index].transform(localT);
  }
}
