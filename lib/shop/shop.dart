import 'package:flutter/material.dart';
import 'package:iknowthisplace/backend/settings_manager.dart';
import 'package:iknowthisplace/styles/main_screen_background.dart';
import '../backend/billing_manager.dart';
import '../backend/hearts.dart';
import '../below_menu/menu_nav.dart';

class Shop extends StatefulWidget {
  final Hearts hearts;
  final SettingsManager settings;

  const Shop({
    super.key,
    required this.hearts,
    required this.settings
  });

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MainScreenBackground().getBackground(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 120),
              Text(
                widget.settings.t("shop_title"),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004D60),
                    fontSize: 42),
              ),
              Text(
                widget.settings.t("shop_subtitle"),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF366173),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              
              // Premium Pass Card reativo
              ListenableBuilder(
                listenable: Hearts(),
                builder: (context, child) {
                  final hearts = Hearts();
                  final isPurchased = hearts.isUnlimited;

                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 10)),
                        ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBD1540),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFBD1540).withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5)
                                    )
                                  ]
                                ),
                                child: Icon(
                                  isPurchased ? Icons.all_inclusive : Icons.favorite, 
                                  color: Colors.white, 
                                  size: 24
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                      widget.settings.t("premium_pass"),
                                      style: const TextStyle(
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 1.2,
                                      )
                                  ),
                                  Text(
                                    isPurchased ? widget.settings.t("activated") : "\$1.99",
                                    style: const TextStyle(
                                        color: Color(0xFF003343),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32,
                                    ),
                                  ),
                                ],
                              )
                            ]
                        ),
                        const SizedBox(height: 24),
                        Text(
                          isPurchased ? widget.settings.t("unlimited_mode_title") : widget.settings.t("unlimited_hearts"),
                          style: const TextStyle(
                            color: Color(0xFF003343),
                            fontWeight: FontWeight.bold,
                            fontSize: 24
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isPurchased 
                            ? widget.settings.t("unlimited_hearts_congrats")
                            : widget.settings.t("unlimited_hearts_desc"),
                          style: TextStyle(
                            color: Colors.blueGrey.shade700,
                            fontSize: 15,
                            height: 1.4,
                          )
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                              onPressed: isPurchased ? null : () {
                                BillingManager().buyUnlimited();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isPurchased ? Colors.grey : const Color(0xFFBD1540),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: isPurchased ? 0 : 8,
                                shadowColor: const Color(0xFFBD1540).withOpacity(0.5),
                              ), 
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isPurchased ? widget.settings.t("purchased") : widget.settings.t("unlock_forever"),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(isPurchased ? Icons.check_circle : Icons.bolt, size: 24),
                                ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),
              
              const SizedBox(height: 40),
              Text(
                widget.settings.t("other_curiosities"),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  _buildSmallCard(widget.settings.t("hint_pack"), "\$0.99", Icons.auto_awesome),
                  const SizedBox(width: 16),
                  _buildSmallCard(widget.settings.t("global_map"), "\$4.99", Icons.public_outlined),
                ],
              ),
              
              const SizedBox(height: 48),
              Center(
                child: Text(
                  widget.settings.t("secured_vault"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined, color: Colors.grey.shade500, size: 20),
                  const SizedBox(width: 16),
                  Icon(Icons.lock_outline, color: Colors.grey.shade500, size: 20),
                  const SizedBox(width: 16),
                  Icon(Icons.payments_outlined, color: Colors.grey.shade500, size: 20),
                ]
              ),
              const SizedBox(height: 120),
            ],
          ),
        )
      ),
    );
  }

  Widget _buildSmallCard(String title, String price, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5)
              )
            ]
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF004D60), size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF003343),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(
                color: Color(0xFF004D60),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
