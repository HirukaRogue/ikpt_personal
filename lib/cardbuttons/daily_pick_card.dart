import 'package:flutter/material.dart';
import 'package:iknowthisplace/backend/settings_manager.dart';

class DailyPickCard extends StatelessWidget {
  final String title;
  final String description;
  final String assetPath;
  final SettingsManager settings;

  const DailyPickCard({
    super.key,
    required this.title,
    required this.description,
    required this.assetPath,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    const Color cardBg = Color(0xFFE0F7FA); // Ciano bem claro
    const Color primaryTeal = Color(0xFF006D4E); // Verde escuro da imagem

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem no topo com bordas arredondadas
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: assetPath.isNotEmpty 
              ? Image.asset(
                  assetPath,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
          ),
          const SizedBox(height: 20),
          
          // Row com Ícone e "DAILY PICK"
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined, size: 18, color: primaryTeal.withOpacity(0.8)),
              const SizedBox(width: 8),
              Text(
                settings.t("daily_pick"),
                style: TextStyle(
                  color: primaryTeal.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Título
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF00332E), // Teal ainda mais escuro
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Descrição
          Text(
            description,
            style: TextStyle(
              color: const Color(0xFF00332E).withOpacity(0.7),
              fontSize: 15,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          
          // Botão Discover Now
          ElevatedButton(
            onPressed: () {}, // Sem função por enquanto
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              settings.t("discover_now"),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
