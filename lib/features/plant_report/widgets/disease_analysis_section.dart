import 'package:flutter/material.dart';

import 'package:greenmind_ai/features/plant_report/models/plant_care_report.dart';

class DiseaseAnalysisSection
    extends StatelessWidget {
  final PlantCareReport report;

  const DiseaseAnalysisSection({
    super.key,
    required this.report,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final healthScore =
        report.normalizedHealthScore;

    final needsAttention =
        healthScore < 75 ||
        report.healthStatus
                .toLowerCase() !=
            'healthy';

    final Color accentColor =
        healthScore >= 75
            ? const Color(0xFF2E7D32)
            : healthScore >= 50
                ? const Color(0xFFEF6C00)
                : const Color(0xFFC62828);

    final Color backgroundColor =
        healthScore >= 75
            ? const Color(0xFFF0F8F1)
            : healthScore >= 50
                ? const Color(0xFFFFF8E1)
                : const Color(0xFFFFF4F4);

    final String title =
        !needsAttention
            ? 'Plant Appears Healthy'
            : healthScore >= 50
                ? 'Some Attention Recommended'
                : 'Health Attention Required';

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(
            alpha: 0.14,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color:
                      accentColor.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
                child: Icon(
                  !needsAttention
                      ? Icons
                          .verified_rounded
                      : Icons
                          .warning_amber_rounded,
                  color:
                      accentColor,
                  size: 23,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'AI Health Analysis',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      title,
                      style: TextStyle(
                        color:
                            accentColor,
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            report.overview,
            style:
                const TextStyle(
              fontSize: 13,
              height: 1.55,
              color:
                  Color(0xFF5F6962),
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon:
                      Icons.favorite_rounded,
                  label:
                      'Health Status',
                  value:
                      report.healthStatus,
                  color:
                      accentColor,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: _InfoItem(
                  icon:
                      Icons.analytics_rounded,
                  label:
                      'Health Score',
                  value:
                      '${report.normalizedHealthScore}%',
                  color:
                      accentColor,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon:
                      Icons.local_florist_rounded,
                  label:
                      'AI Identification',
                  value:
                      report.confidenceText,
                  color:
                      accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================================================================
// INFO ITEM
// ================================================================

class _InfoItem
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(13),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withValues(
          alpha: 0.72,
        ),
        borderRadius:
            BorderRadius.circular(
          15,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      const TextStyle(
                    fontSize: 10,
                    color:
                        Color(0xFF7A847D),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF202820),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}