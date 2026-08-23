import 'package:flutter/material.dart';

import 'package:greenmind_ai/features/plant_report/models/plant_care_report.dart';

class SymptomsSection extends StatelessWidget {
  final PlantCareReport report;

  const SymptomsSection({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final symptoms = report.symptoms;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3EAE4),
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
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFEAF5EB),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.visibility_rounded,
                  color:
                      Color(0xFF2E7D32),
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visible Observations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'What the analysis suggests',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            Color(0xFF78827A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (symptoms.isEmpty)
            const _EmptySymptoms()
          else
            Column(
              children: [
                for (
                  int index = 0;
                  index < symptoms.length;
                  index++
                )
                  Padding(
                    padding:
                        EdgeInsets.only(
                      bottom:
                          index ==
                                  symptoms.length - 1
                              ? 0
                              : 10,
                    ),
                    child: _SymptomItem(
                      text: symptoms[index],
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
// SYMPTOM ITEM
// ================================================================

class _SymptomItem
    extends StatelessWidget {
  final String text;

  const _SymptomItem({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF7FAF7),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 19,
            color:
                Color(0xFF43A047),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color:
                    Color(0xFF4E5951),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// EMPTY
// ================================================================

class _EmptySymptoms
    extends StatelessWidget {
  const _EmptySymptoms();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF7FAF7),
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color:
                Color(0xFF6F7B72),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No specific observations were recorded.',
              style: TextStyle(
                fontSize: 12,
                color:
                    Color(0xFF68736B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}