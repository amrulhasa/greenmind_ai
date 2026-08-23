import 'package:flutter/material.dart';

import '../models/plant_care_report.dart';

class HealthSection extends StatelessWidget {
  final PlantCareReport report;

  const HealthSection({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final score =
        report.healthScore.clamp(0, 100);

    return _SectionCard(
      title: 'Plant Health',
      subtitle: 'Current health assessment',
      icon: Icons.favorite_outline_rounded,
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 9,
                        backgroundColor:
                            const Color(0xFFE7F1E8),
                        valueColor:
                            const AlwaysStoppedAnimation(
                          Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          '$score%',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight:
                                FontWeight.w900,
                            color:
                                Color(0xFF1B5E20),
                          ),
                        ),
                        const Text(
                          'Health',
                          style: TextStyle(
                            fontSize: 9,
                            color:
                                Color(0xFF718076),
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.healthStatus,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF182019),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      report.overview,
                      maxLines: 5,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.55,
                        color: Color(0xFF68736B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            height: 1,
            color: const Color(0xFFE8ECE9),
          ),

          const SizedBox(height: 12),

          ...report.symptoms.map(
            (symptom) => Padding(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 7,
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF43A047),
                    size: 19,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      symptom,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: Color(0xFF303832),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE4ECE5),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFEAF5EC),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color:
                      const Color(0xFF2E7D32),
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Color(0xFF182019),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color:
                              Color(0xFF7A847B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}