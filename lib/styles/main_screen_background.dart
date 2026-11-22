import 'package:flutter/material.dart';

class MainScreenBackground {
  BoxDecoration getBackground() {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/backgrounds/standard_bg.png'),
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
  }
}