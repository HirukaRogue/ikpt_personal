import 'package:flutter/material.dart';

class OtherButtons extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const OtherButtons({
    super.key,
    this.onTap,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
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
                // Ícone posicionado no topo esquerdo dentro de uma caixinha colorida
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 28,
                      color: iconColor,
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60), // Ajustado para dar espaço à caixinha do ícone
                    Text(
                        title,
                        style: const TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 28,
                            fontWeight: FontWeight.bold
                        )
                    ),
                    const SizedBox(height: 4),
                    Text(
                        subtitle,
                        style: TextStyle(
                            color: Colors.blueGrey.withOpacity(0.8),
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
