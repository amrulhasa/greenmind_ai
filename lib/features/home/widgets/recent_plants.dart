import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class RecentPlants extends StatelessWidget {
  const RecentPlants({super.key});

  @override
  Widget build(BuildContext context) {
    final List<PlantModel> plants = [
      const PlantModel(
        name: 'Rose',
        status: 'Healthy',
        icon: Icons.local_florist,
        color: AppColors.primary,
      ),
      const PlantModel(
        name: 'Aloe Vera',
        status: 'Needs Water',
        icon: Icons.spa,
        color: Colors.orange,
      ),
      const PlantModel(
        name: 'Money Plant',
        status: 'Healthy',
        icon: Icons.eco,
        color: AppColors.primary,
      ),
      const PlantModel(
        name: 'Tulip',
        status: 'Disease Detected',
        icon: Icons.local_florist,
        color: AppColors.error,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Plants',
          style: AppTextStyles.heading2,
        ),

        const SizedBox(height: AppSpacing.md),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: plants.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final plant = plants[index];

            return Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: plant.color.withValues(alpha: 0.12),
                    child: Icon(
                      plant.icon,
                      color: plant.color,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant.name,
                          style: AppTextStyles.title,
                        ),

                        const SizedBox(height: AppSpacing.xs),

                        Text(
                          plant.status,
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class PlantModel {
  final String name;
  final String status;
  final IconData icon;
  final Color color;

  const PlantModel({
    required this.name,
    required this.status,
    required this.icon,
    required this.color,
  });
}