import 'package:flutter/material.dart';

import '../models/plant_care_report.dart';

class ReportHeader extends StatelessWidget {
  final PlantCareReport report;

  const ReportHeader({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        report.imageBytes != null &&
        report.imageBytes!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF145A1A),
            Color(0xFF2E7D32),
            Color(0xFF43A047),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32)
                .withValues(alpha: 0.18),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ========================================================
          // TOP ROW
          // ========================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              if (hasImage)
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(18),
                  child: Image.memory(
                    report.imageBytes!,
                    width: 78,
                    height: 78,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 31,
                  ),
                ),

              const Spacer(),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(alpha: 0.14),
                  borderRadius:
                      BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white
                        .withValues(alpha: 0.12),
                  ),
                ),
                child: Text(
                  report.generatedFromImage
                      ? 'IMAGE REPORT'
                      : 'AI REPORT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ========================================================
          // TITLE
          // ========================================================

          const Text(
            'Plant Care Report',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            report.plantName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            report.scientificName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 20),

          // ========================================================
          // INFO CHIPS
          // ========================================================

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.category_outlined,
                text: report.category,
              ),

              _InfoChip(
                icon:
                    Icons.verified_outlined,
                text:
                    '${report.confidencePercentage}% AI confidence',
              ),

              _InfoChip(
                icon:
                    Icons.favorite_outline_rounded,
                text:
                    '${report.healthScore}% ${report.healthStatus}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================================================================
// INFO CHIP
// ================================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          const BoxConstraints(
        maxWidth: 230,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white
            .withValues(alpha: 0.14),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}