import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 560;

        if (compact) {
          return const Column(
            children: [
              _FeatureItem(
                title: 'Identify Plant',
                subtitle: 'Scan any plant with AI',
                description: 'Discover plant species instantly',
                icon: Icons.eco_rounded,
                color: AppColors.primary,
                route: '/identify',
              ),
              SizedBox(height: 14),
              _FeatureItem(
                title: 'Disease Detection',
                subtitle: 'Detect plant diseases',
                description: 'Check plant health with AI',
                icon: Icons.health_and_safety_rounded,
                color: AppColors.error,
                route: '/disease',
              ),
            ],
          );
        }

        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _FeatureItem(
                title: 'Identify Plant',
                subtitle: 'Scan any plant with AI',
                description: 'Discover plant species instantly',
                icon: Icons.eco_rounded,
                color: AppColors.primary,
                route: '/identify',
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _FeatureItem(
                title: 'Disease Detection',
                subtitle: 'Detect plant diseases',
                description: 'Check plant health with AI',
                icon: Icons.health_and_safety_rounded,
                color: AppColors.error,
                route: '/disease',
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// FEATURE ITEM
// ============================================================================

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push(route);
        },
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: color.withValues(alpha: 0.13),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF18351C).withValues(
                  alpha: 0.055,
                ),
                blurRadius: 30,
                offset: const Offset(0, 13),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================================
              // TOP
              // ==========================================================

              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha: 0.14),
                          color.withValues(alpha: 0.07),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 28,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAF7),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE1E9E2),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      size: 17,
                      color: color,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ==========================================================
              // TITLE
              // ==========================================================

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.45,
                  color: Color(0xFF172018),
                ),
              ),

              const SizedBox(height: 5),

              // ==========================================================
              // SUBTITLE
              // ==========================================================

              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),

              const SizedBox(height: 4),

              // ==========================================================
              // DESCRIPTION
              // ==========================================================

              Text(
                description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF7B867D),
                ),
              ),

              const SizedBox(height: 17),

              // ==========================================================
              // BUTTON
              // ==========================================================

              SizedBox(
                width: double.infinity,
                height: 46,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        color,
                        color.withValues(
                          red: (color.r * 255 + 8)
                              .clamp(0, 255)
                              .round()
                              .toDouble() /
                              255,
                          green: (color.g * 255)
                              .clamp(0, 255)
                              .round()
                              .toDouble() /
                              255,
                          blue: (color.b * 255)
                              .clamp(0, 255)
                              .round()
                              .toDouble() /
                              255,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(
                          alpha: 0.18,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 7),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}