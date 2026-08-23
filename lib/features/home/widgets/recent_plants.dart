import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/recent_plant.dart';
import '../providers/recent_plants_provider.dart';
import 'recent_plant_details_screen.dart';

class RecentPlants extends ConsumerWidget {
  const RecentPlants({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(recentPlantsProvider);

    // ==========================================================
    // LOADING
    // ==========================================================

    if (state.isLoading) {
      return _LoadingCard();
    }

    // ==========================================================
    // ERROR
    // ==========================================================

    if (state.errorMessage != null &&
        state.plants.isEmpty) {
      return _ErrorCard(
        message: state.errorMessage!,
      );
    }

    // ==========================================================
    // EMPTY
    // ==========================================================

    if (state.plants.isEmpty) {
      return const SizedBox.shrink();
    }

    // ==========================================================
    // RECENT SCANS
    // ==========================================================

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5EC),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 20,
                color: Color(0xFF2E7D32),
              ),
            ),

            const SizedBox(width: 11),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Scans',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: Color(0xFF182019),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Your latest plant discoveries',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7A857C),
                    ),
                  ),
                ],
              ),
            ),

            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _showClearConfirmation(
                    context,
                    ref,
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.plants.length,
          separatorBuilder: (_, _) {
            return const SizedBox(height: 10);
          },
          itemBuilder: (context, index) {
            final plant = state.plants[index];

            return _RecentPlantCard(
              plant: plant,
            );
          },
        ),
      ],
    );
  }

  Future<void> _showClearConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          titlePadding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            8,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            24,
            0,
            24,
            8,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16,
          ),
          title: const Row(
            children: [
              Icon(
                Icons.delete_sweep_outlined,
                color: Color(0xFFD94B43),
                size: 25,
              ),
              SizedBox(width: 10),
              Text(
                'Clear Recent Scans?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1D261F),
                ),
              ),
            ],
          ),
          content: const Text(
            'All recent plant scans will be removed. '
            'This action cannot be undone.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Color(0xFF68736A),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF667269),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD94B43),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Clear Scans',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) {
      return;
    }

    await ref
        .read(recentPlantsProvider.notifier)
        .clearAll();
  }
}

// ============================================================================
// RECENT PLANT CARD
// ============================================================================

class _RecentPlantCard extends StatelessWidget {
  const _RecentPlantCard({
    required this.plant,
  });

  final RecentPlant plant;

  @override
  Widget build(BuildContext context) {
    final confidence = plant.confidence
        .clamp(0.0, 100.0)
        .toDouble();

    final isDisease = plant.isDiseaseDetection;

    final title = isDisease
        ? (
            plant.diseaseName.trim().isEmpty
                ? 'Plant Health Scan'
                : plant.diseaseName.trim()
          )
        : (
            plant.plantName.trim().isEmpty
                ? 'Unknown Plant'
                : plant.plantName.trim()
          );

    final statusColor = plant.isHealthy
        ? const Color(0xFF2E7D32)
        : const Color(0xFFE67E22);

    final statusBackground = plant.isHealthy
        ? const Color(0xFFEAF5EC)
        : const Color(0xFFFFF2E5);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RecentPlantDetailsScreen(
                plant: plant,
              ),
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE1E9E2),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF18351C)
                    .withValues(alpha: 0.035),
                blurRadius: 19,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ========================================================
              // IMAGE
              // ========================================================

              _PlantImage(
                imageBase64: plant.imageBase64,
              ),

              const SizedBox(width: 13),

              // ========================================================
              // CONTENT
              // ========================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1D261F),
                            ),
                          ),
                        ),

                        const SizedBox(width: 7),

                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: statusBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            plant.isHealthy
                                ? Icons.check_circle_rounded
                                : Icons.warning_amber_rounded,
                            size: 16,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDisease
                            ? const Color(0xFFFFF0EF)
                            : const Color(0xFFEAF5EC),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        isDisease
                            ? 'Disease Detection'
                            : 'Plant Identification',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: isDisease
                              ? const Color(0xFFD94B43)
                              : const Color(0xFF2E7D32),
                        ),
                      ),
                    ),

                    if (!isDisease &&
                        plant.scientificName
                            .trim()
                            .isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        plant.scientificName.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF7C877F),
                        ),
                      ),
                    ],

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: Color(0xFF4F9D55),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${confidence.toStringAsFixed(0)}% confidence',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF707B72),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 9),

              // ========================================================
              // ARROW
              // ========================================================

              Container(
                width: 31,
                height: 31,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F8F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 19,
                  color: Color(0xFF7A857C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PLANT IMAGE
// ============================================================================

class _PlantImage extends StatelessWidget {
  const _PlantImage({
    required this.imageBase64,
  });

  final String? imageBase64;

  @override
  Widget build(BuildContext context) {
    final value = imageBase64?.trim();

    if (value == null || value.isEmpty) {
      return _placeholder();
    }

    try {
      var decodedValue = value;

      if (decodedValue.contains(',')) {
        decodedValue = decodedValue.split(',').last;
      }

      final bytes = base64Decode(decodedValue);

      if (bytes.isEmpty) {
        return _placeholder();
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Image.memory(
          bytes,
          width: 76,
          height: 76,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return _placeholder();
          },
        ),
      );
    } catch (_) {
      return _placeholder();
    }
  }

  Widget _placeholder() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F4EA),
            Color(0xFFF5F9F5),
          ],
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFDDEADE),
        ),
      ),
      child: const Icon(
        Icons.local_florist_rounded,
        color: Color(0xFF2E7D32),
        size: 31,
      ),
    );
  }
}

// ============================================================================
// LOADING CARD
// ============================================================================

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE2EAE3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF18351C)
                .withValues(alpha: 0.025),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Center(
        child: SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFF2E7D32),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ERROR CARD
// ============================================================================

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF1D9D5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8E6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFD94B43),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF7C4C48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}