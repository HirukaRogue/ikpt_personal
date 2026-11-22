import 'package:flutter/material.dart';
import 'package:iknowthisplace/backend/hearts.dart';
import 'package:iknowthisplace/backend/music_manager.dart';
import 'package:iknowthisplace/backend/settings_manager.dart';
import 'package:iknowthisplace/gallery/gallery.dart';
import 'package:iknowthisplace/game/asset_show.dart';
import 'package:iknowthisplace/mainpage/mainmenu.dart';
import 'package:iknowthisplace/settings.dart';
import 'package:iknowthisplace/shop/shop.dart';
import 'package:iknowthisplace/zenmode/zen.dart';

class MenuNav extends StatefulWidget {
  final SettingsManager settings;

  const MenuNav({
    super.key,
    required this.settings
  });

  static void refreshUI() {
    _MenuNavState._instance?.update();
  }

  static void setAssetShowQuizMode(bool isQuiz) {
    _MenuNavState._instance?._updateAssetShowQuizMode(isQuiz);
  }

  @override
  State<MenuNav> createState() => _MenuNavState();
}

class _MenuNavState extends State<MenuNav> {
  static _MenuNavState? _instance;

  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isAssetShowQuiz = false;

  @override
  void initState() {
    super.initState();
    _instance = this;
    _initializeData();
    MusicManager().handleTabChange(0);
  }

  @override
  void dispose() {
    _instance = null;
    super.dispose();
  }

  void update() {
    if (mounted) setState(() {});
  }

  void _updateAssetShowQuizMode(bool isQuiz) {
    if (mounted && _isAssetShowQuiz != isQuiz) {
      setState(() => _isAssetShowQuiz = isQuiz);
    }
  }

  Future<void> _initializeData() async {
    await Hearts.load(); // Carrega a instância singleton
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    MusicManager().handleTabChange(index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, child) {
        return ListenableBuilder(
          listenable: Hearts(), // Escuta a instância global de corações
          builder: (context, child) {
            final hearts = Hearts();
            final hasHearts = hearts.hearts > 0 || hearts.isUnlimited;

            final List<Widget> screens = [
              MainMenu(
                onPlayPressed: hasHearts ? () => _onItemTapped(1) : null,
                onZenPressed: () => _onItemTapped(5),
                onGalleryPressed: () => _onItemTapped(2),
                onStorePressed: () => _onItemTapped(3),
                onSettingsPressed: () => _onItemTapped(4),
                settings: widget.settings,
              ),
              hasHearts 
                  ? AssetShow(
                      hearts: hearts, 
                      settings: widget.settings,
                      onExit: () => _onItemTapped(0),
                      isActive: _selectedIndex == 1,
                    )
                  : Center(
                      child: Text(
                        widget.settings.lang.translate("recharge_hearts"),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
              Gallery(settings: widget.settings,),
              Shop(hearts: hearts, settings: widget.settings,),
              Settings(settings: widget.settings,),
              ZenMode(
                onExit: () => _onItemTapped(0),
                isActive: _selectedIndex == 5,
              ),
            ];

            bool hideMenu = _selectedIndex == 5 || _selectedIndex == 1 || _isAssetShowQuiz;

            return Scaffold(
              body: Stack(
                children: [
                  IndexedStack(
                    index: _selectedIndex,
                    children: screens,
                  )
                ],
              ),
              bottomNavigationBar: hideMenu
                ? null 
                : BottomNavigationBar(
                    currentIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
                    onTap: _onItemTapped,
                    selectedItemColor: Colors.greenAccent,
                    unselectedItemColor: Colors.white70,
                    backgroundColor: Colors.black.withOpacity(0.8),
                    type: BottomNavigationBarType.fixed,
                    items: [
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.home_outlined), 
                        activeIcon: const Icon(Icons.home), 
                        label: widget.settings.t("nav_home")
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.sports_esports_outlined), 
                        activeIcon: const Icon(Icons.sports_esports), 
                        label: widget.settings.t("nav_play")
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.photo_library_outlined), 
                        activeIcon: const Icon(Icons.photo_library), 
                        label: widget.settings.t("nav_gallery")
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.shopping_bag_outlined), 
                        activeIcon: const Icon(Icons.shopping_bag), 
                        label: widget.settings.t("nav_shop")
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.settings_outlined), 
                        activeIcon: const Icon(Icons.settings), 
                        label: widget.settings.t("nav_settings")
                      ),
                    ],
                  ),
            );
          },
        );
      },
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
