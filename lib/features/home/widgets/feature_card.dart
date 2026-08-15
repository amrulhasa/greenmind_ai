import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class FeatureCard extends StatelessWidget {
  const FeatureCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _FeatureItem(
            title: 'Identify Plant',
            subtitle: 'Scan any plant with AI',
            icon: Icons.eco_rounded,
            color: AppColors.primary,
            route: '/identify',
          ),
        ),

        SizedBox(
          width: AppSpacing.md,
        ),

        Expanded(
          child: _FeatureItem(
            title: 'Disease Detection',
            subtitle: 'Detect plant diseases',
            icon: Icons.health_and_safety_rounded,
            color: AppColors.error,
            route: '/disease',
          ),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });

  void _openFeature(
    BuildContext context,
  ) {
    context.go(route);
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(
        AppRadius.card,
      ),
      onTap: () {
        _openFeature(context);
      },
      child: Container(
        height: 180,
        padding:
            const EdgeInsets.all(14),
        decoration:
            BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(
            AppRadius.card,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // ICON
            // ==================================================

            CircleAvatar(
              radius: 22,
              backgroundColor:
                  color.withValues(
                alpha: 0.12,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            // ==================================================
            // TITLE
            // ==================================================

            Text(
              title,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  AppTextStyles.heading3,
            ),

            const SizedBox(
              height: 3,
            ),

            // ==================================================
            // SUBTITLE
            // ==================================================

            Expanded(
              child: Align(
                alignment:
                    Alignment.topLeft,
                child: Text(
                  subtitle,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      AppTextStyles.body,
                ),
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            // ==================================================
            // GET STARTED
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: () {
                  _openFeature(
                    context,
                  );
                },
                child: const Text(
                  'Get Started',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}