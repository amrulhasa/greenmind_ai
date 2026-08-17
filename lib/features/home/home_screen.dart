import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../nursery/screens/nearby_nursery_screen.dart';

import 'widgets/bottom_nav.dart';
import 'widgets/feature_card.dart';
import 'widgets/home_header.dart';
import 'widgets/recent_plants.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Scaffold(
      bottomNavigationBar: const BottomNav(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // HEADER
              // ==================================================

              const HomeHeader(),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // IDENTIFY + DISEASE DETECTION
              // ==================================================

              const FeatureCard(),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // NEARBY NURSERIES
              // ==================================================

              _NearbyNurseryCard(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const NearbyNurseryScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 32,
              ),

              // ==================================================
              // RECENT PLANTS
              // ==================================================

              const RecentPlants(),

              const SizedBox(
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// NEARBY NURSERY CARD
// ================================================================

class _NearbyNurseryCard extends StatelessWidget {
  const _NearbyNurseryCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(
              0,
              6,
            ),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ======================================================
          // TITLE ROW
          // ======================================================

          Row(
            children: [
              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  color:
                      const Color(0xFFE8F5E9),

                  borderRadius:
                      BorderRadius.circular(16),
                ),

                child: const Icon(
                  Icons.location_on_rounded,
                  color:
                      Color(0xFF2E7D32),
                  size: 28,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Nearby Nurseries',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(0xFF1F1F1F),
                      ),
                    ),

                    SizedBox(
                      height: 4,
                    ),

                    Text(
                      'Find plant nurseries near you',

                      style: TextStyle(
                        fontSize: 14,
                        color:
                            Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          // ======================================================
          // EXPLORE BUTTON
          // ======================================================

          SizedBox(
            width: double.infinity,
            height: 48,

            child: ElevatedButton.icon(
              onPressed: onTap,

              icon: const Icon(
                Icons.map_rounded,
                size: 20,
              ),

              label: const Text(
                'Explore Nearby',

                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2E7D32),

                foregroundColor:
                    Colors.white,

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}