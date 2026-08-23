import 'package:flutter/material.dart';

import '../models/plant_care_report.dart';

class RecommendationsSection extends StatelessWidget {
  final PlantCareReport report;

  const RecommendationsSection({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    if (report.recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0F8F1),
            Color(0xFFFFFFFF),
          ],
        ),
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFDCEBDD),
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
                  color: const Color(0xFF2E7D32),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Recommendations',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Personalized care suggestions',
                      style: TextStyle(
                        fontSize: 10.5,
                        color:
                            Color(0xFF758077),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ...report.recommendations
              .asMap()
              .entries
              .map(
            (entry) {
              final index = entry.key;
              final recommendation =
                  entry.value;

              return Container(
                margin:
                    const EdgeInsets.only(
                  bottom: 10,
                ),
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(15),
                  border: Border.all(
                    color:
                        const Color(0xFFE5ECE6),
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment:
                          Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            const Color(
                          0xFFE6F3E8,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(8),
                      ),
                      child: Text(
                        '${index + 1}',
                        style:
                            const TextStyle(
                          color:
                              Color(0xFF2E7D32),
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        recommendation,
                        style:
                            const TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color:
                              Color(0xFF303832),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}