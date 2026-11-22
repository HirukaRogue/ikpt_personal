import 'package:flutter/material.dart';
import 'package:iknowthisplace/backend/music_manager.dart';
import 'package:iknowthisplace/backend/settings_manager.dart';
import 'package:iknowthisplace/below_menu/menu_nav.dart';

class Settings extends StatefulWidget {
  final SettingsManager settings;

  const Settings({
    super.key,
    required this.settings
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Column(
            children: [
              Text(
                widget.settings.t("settings_title"),
                style: TextStyle(fontSize: 40, color: Colors.blueGrey.withOpacity(0.9), fontWeight: FontWeight.bold),
              ),
              Text(
                widget.settings.t("settings_subtitle"),
                style: TextStyle(fontSize: 18, color: Colors.blueGrey.withOpacity(0.7), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),

              _buildLanguageSelector(),

              const SizedBox(height: 30),
              Text(
                widget.settings.t("audio_prefs"),
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              _buildTileContainer(
                child: Row(
                  children: [
                    _buildIconCircle(Icons.volume_up_outlined, Colors.green),
                    const SizedBox(width: 15),
                    Expanded(child: _buildLabelText(widget.settings.t("sound_effects"), widget.settings.t("sound_desc"))),
                    Switch(
                      value: widget.settings.soundEnabled,
                      activeColor: Colors.greenAccent,
                      onChanged: (bool value) async {
                        await widget.settings.setSoundEnabled(value);
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildTileContainer(
                child: Row(
                  children: [
                    _buildIconCircle(Icons.music_note, Colors.orange),
                    const SizedBox(width: 15),
                    Expanded(child: _buildLabelText(widget.settings.t("music"), widget.settings.t("music_desc"))),
                    Switch(
                      value: widget.settings.musicEnabled,
                      activeColor: Colors.orangeAccent,
                      onChanged: (bool value) async {
                        await widget.settings.setMusicEnabled(value);
                        await MusicManager().toggleMusic(value);
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.yellow, Colors.orange], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.settings.t("quote"),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey.withOpacity(0.8), fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ),

              const SizedBox(height: 20),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return GestureDetector(
      onTap: () => _showLanguagePicker(),
      child: _buildTileContainer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIconCircle(Icons.language_outlined, Colors.blue),
            _buildLabelText(widget.settings.t("language"), widget.settings.language),
            const Icon(Icons.arrow_forward_ios, color: Colors.blueGrey, size: 20),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text(widget.settings.t("language"), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: SettingsManager.supportedLanguages.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.05)),
                  itemBuilder: (context, index) {
                    final language = SettingsManager.supportedLanguages[index];
                    final isSelected = widget.settings.language == language;
                    return ListTile(
                      title: Text(language, style: TextStyle(color: isSelected ? Colors.blue : Colors.blueGrey, fontSize: 18)),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
                      onTap: () async {
                        await widget.settings.setLanguage(language);
                        if (mounted) {
                          setState(() {});
                          MenuNav.refreshUI();
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTileContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
      child: child,
    );
  }

  Widget _buildIconCircle(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
      child: Icon(icon, color: color.withOpacity(0.9)),
    );
  }

  Widget _buildLabelText(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.blueGrey, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(subtitle, style: TextStyle(color: Colors.blueGrey.withOpacity(0.5), fontSize: 12)),
      ],
    );
  }
}
