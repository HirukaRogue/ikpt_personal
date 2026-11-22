import 'package:flutter/material.dart';
import 'package:iknowthisplace/backend/settings_manager.dart';
import '../backend/places.dart';

class PlaceDetail extends StatelessWidget {
  final Place place;
  final String flagUrl;
  final SettingsManager settings;

  const PlaceDetail({
    super.key,
    required this.place,
    required this.flagUrl,
    required this.settings
  });

  @override
  Widget build(BuildContext context) {
    // Definition of the color palette based on the image
    const Color darkTeal = Color(0xFF002333);
    const Color primaryGreen = Color(0xFF006D4E);
    const Color factBoxBg = Color(0xFFE3F2FD); // Very light blue
    const Color badgeBg = Color(0xFFB3E5FC);   // Light blue for the badge

    return Scaffold(
      backgroundColor: const Color(0xFFF0FBFF),
      body: Column(
        children: [
          // Pill header (Simulating the top to maintain the design style)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    const Icon(Icons.map_outlined, color: primaryGreen, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "I Know This Place",
                        style: TextStyle(
                          color: darkTeal,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    // Decorative hearts
                    Row(
                      children: List.generate(3, (index) => const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.favorite, color: Color(0xFFE91E63), size: 18),
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Card with Overlays
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.asset(
                          place.assetPath,
                          height: 380,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Location Chip (Top Left)
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: primaryGreen),
                              const SizedBox(width: 4),
                              Text(
                                place.country.toUpperCase(),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: darkTeal),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Close Button (Top Right)
                      Positioned(
                        top: 20,
                        right: 20,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Title and Specialty Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: darkTeal,
                            ),
                          ),
                          Row(
                            children: [
                              Container(width: 24, height: 2, color: primaryGreen),
                              const SizedBox(width: 8),
                              Text(
                                place.country,
                                style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // "WORLD WONDER" Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.stars, color: primaryGreen, size: 20),
                            Text(
                              "WORLD WONDER",
                              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: darkTeal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // "INTERESTING FACT" Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: factBoxBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline, size: 18, color: primaryGreen),
                                SizedBox(width: 8),
                                Text(
                                  "INTERESTING FACT",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: primaryGreen,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.menu_book_outlined, size: 24, color: Colors.blueGrey),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          place.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: darkTeal,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Start Quiz",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share_outlined, color: darkTeal),
                          label: const Text(
                            "Share",
                            style: TextStyle(color: darkTeal, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: badgeBg,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Pagination Indicators (Dots)
                  const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(radius: 4, backgroundColor: primaryGreen),
                        SizedBox(width: 8),
                        CircleAvatar(radius: 4, backgroundColor: Color(0xFF1DE9B6)),
                        SizedBox(width: 8),
                        CircleAvatar(radius: 4, backgroundColor: Color(0xFF1DE9B6)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
