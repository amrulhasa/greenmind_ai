import 'package:flutter/material.dart';

import '../models/plant_care_report.dart';

class CareSummarySection extends StatelessWidget {
  final PlantCareReport report;

  const CareSummarySection({
    super.key,
    required this.report,
  });

  String _shortValue(String value) {
    final text = value.trim();

    if (text.isEmpty) {
      return 'Not available';
    }

    return text;
  }

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
          // ========================================================
          // HEADER
          // ========================================================

          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFE8F5E9),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.spa_rounded,
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
                      'Care Summary',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Color(0xFF182019),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Quick overview of your plant care plan',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            Color(0xFF7A847B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ========================================================
          // OVERVIEW
          // ========================================================

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  const Color(0xFFF6FAF6),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Text(
              report.overview,
              style: const TextStyle(
                color: Color(0xFF59645B),
                fontSize: 13,
                height: 1.55,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ========================================================
          // CARE STATS
          // ========================================================

          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon:
                      Icons.water_drop_outlined,
                  title: 'Watering',
                  value:
                      _shortValue(
                    report.watering,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  icon:
                      Icons.wb_sunny_outlined,
                  title: 'Sunlight',
                  value:
                      _shortValue(
                    report.sunlight,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon:
                      Icons.thermostat_outlined,
                  title: 'Temperature',
                  value:
                      _shortValue(
                    report.temperature,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  icon:
                      Icons.opacity_outlined,
                  title: 'Humidity',
                  value:
                      _shortValue(
                    report.humidity,
                  ),
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
// MINI STAT
// ================================================================

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MiniStat({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          const BoxConstraints(
        minHeight: 82,
      ),
      padding:
          const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFFE7EDE8),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color:
                const Color(0xFF2E7D32),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 10,
                    color:
                        Color(0xFF7A847B),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  maxLines: 3,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 11.5,
                    color:
                        Color(0xFF263129),
                    fontWeight:
                        FontWeight.w700,
                    height: 1.3,
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