import 'package:flutter/material.dart';

import '../models/plant_care_report.dart';

class PlantOverviewSection extends StatelessWidget {
  final PlantCareReport report;

  const PlantOverviewSection({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Care Requirements',
      subtitle: 'Recommended growing conditions',
      icon: Icons.spa_outlined,
      child: Column(
        children: [
          _Requirement(
            icon: Icons.wb_sunny_outlined,
            title: 'Sunlight',
            value: report.sunlight,
          ),
          _Requirement(
            icon: Icons.water_drop_outlined,
            title: 'Watering',
            value: report.watering,
          ),
          _Requirement(
            icon: Icons.grass_outlined,
            title: 'Soil',
            value: report.soil,
          ),
          _Requirement(
            icon: Icons.thermostat_outlined,
            title: 'Temperature',
            value: report.temperature,
          ),
          _Requirement(
            icon: Icons.opacity_outlined,
            title: 'Humidity',
            value: report.humidity,
          ),
          _Requirement(
            icon: Icons.science_outlined,
            title: 'Fertilizer',
            value: report.fertilizer,
          ),
        ],
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _Requirement({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF7),
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE9EFEA),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF2E7D32),
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
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: Color(0xFF202820),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF68736B),
                    fontSize: 12,
                    height: 1.5,
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

class _Card extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _Card({
    required this.title,
    required this.subtitle,
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
                  color: const Color(0xFFE8F5E9),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2E7D32),
                  size: 22,
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
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10.5,
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

          child,
        ],
      ),
    );
  }
}