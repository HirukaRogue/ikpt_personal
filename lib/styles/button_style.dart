import 'package:flutter/material.dart';

class MainMenuButtonStyle {
  ButtonStyle getStyle() {
    return FilledButton.styleFrom(
        backgroundColor: Colors.lightBlueAccent,
        fixedSize: const Size(200, 90),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        )
    );
  }
}