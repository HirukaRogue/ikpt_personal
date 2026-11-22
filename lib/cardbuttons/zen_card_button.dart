import 'package:flutter/material.dart';
import 'package:iknowthisplace/backend/settings_manager.dart';

class ZenCardButton extends StatelessWidget {
  final VoidCallback? onTap;
  final SettingsManager settings;

  const ZenCardButton({super.key, this.onTap, required this.settings});

  @override
  Widget build(BuildContext context) {
    // Definindo as cores baseadas na imagem
    const Color cardBackground = Color(0xFF8AD6FF); // Azul claro
    const Color darkTeal = Color(0xFF004B63);      // Azul/Verde escuro da fonte e ícone

    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4)
                  )
                ]
            ),
            child: Stack(
              children: [
                // Ícone posicionado no topo direito sem o círculo de fundo
                Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(
                    Icons.energy_savings_leaf,
                    size: 32, // Tamanho ajustado para parecer um ícone de canto
                    color: darkTeal,
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40), // Espaço para não bater no ícone
                    Text(
                        settings.t("zen_mode"),
                        style: const TextStyle(
                            color: darkTeal,
                            fontSize: 28,
                            fontWeight: FontWeight.bold
                        )
                    ),
                    const SizedBox(height: 4),
                    Text(
                        settings.t("zen_mode_desc"),
                        style: TextStyle(
                            color: darkTeal.withOpacity(0.8),
                            fontSize: 16,
                            height: 1.2
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