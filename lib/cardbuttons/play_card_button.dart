import 'package:flutter/material.dart';
import 'package:iknowthisplace/backend/settings_manager.dart';

class PlayCardButton extends StatelessWidget {
  final VoidCallback? onTap;
  final SettingsManager settings;
  
  const PlayCardButton({super.key, this.onTap, required this.settings});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF004D40),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8)
            )
          ]
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 60,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF40C4FF),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Text(
                    settings.t("adventure_awaits"),
                    style: const TextStyle(
                      color: Color(0xFF64FFDA),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1
                    )
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  settings.t("play"),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold
                  )
                ),
                Text(
                  settings.t("play_subtitle"),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.4
                  )
                )
              ],
            )
          ],
        )
      )
    );
  }
}
