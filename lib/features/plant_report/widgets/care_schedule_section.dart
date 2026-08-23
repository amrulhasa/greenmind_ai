import 'package:flutter/material.dart';

import '../models/plant_care_report.dart';

class CareScheduleSection extends StatelessWidget {
  final PlantCareReport report;

  const CareScheduleSection({
    super.key,
    required this.report,
  });

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'water':
        return Icons.water_drop_rounded;
      case 'sun':
        return Icons.wb_sunny_rounded;
      case 'leaf':
        return Icons.eco_rounded;
      case 'fertilizer':
        return Icons.science_rounded;
      default:
        return Icons.eco_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (report.careSchedule.isEmpty) {
      return const SizedBox.shrink();
    }

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
                  color: const Color(0xFFE8F5E9),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Care Schedule',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Your recommended routine',
                      style: TextStyle(
                        fontSize: 10.5,
                        color:
                            Color(0xFF7A827B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ...report.careSchedule
              .asMap()
              .entries
              .map(
            (entry) {
              final index = entry.key;
              final task = entry.value;
              final isLast =
                  index ==
                      report.careSchedule.length -
                          1;

              return Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 42,
                    child: Column(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFF2E7D32,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(12),
                          ),
                          child: Icon(
                            _getIcon(task.icon),
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 60,
                            margin:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 3,
                            ),
                            color:
                                const Color(
                              0xFFDCE8DE,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Container(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      padding:
                          const EdgeInsets.all(14),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF7FAF7,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(17),
                        border: Border.all(
                          color:
                              const Color(
                            0xFFE8EEE9,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment:
                                WrapAlignment
                                    .spaceBetween,
                            crossAxisAlignment:
                                WrapCrossAlignment
                                    .center,
                            spacing: 8,
                            runSpacing: 7,
                            children: [
                              Text(
                                task.title,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                  fontSize: 14,
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                    0xFFE7F4E9,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    20,
                                  ),
                                ),
                                child: Text(
                                  task.frequency,
                                  style:
                                      const TextStyle(
                                    color:
                                        Color(
                                      0xFF2E7D32,
                                    ),
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight
                                            .w800,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Text(
                            task.description,
                            style:
                                const TextStyle(
                              color:
                                  Color(0xFF68736B),
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}