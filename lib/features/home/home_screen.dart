import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../nursery/screens/nearby_nursery_screen.dart';
import '../plant_report/screens/plant_report_screen.dart';

import 'widgets/bottom_nav.dart';
import 'widgets/feature_card.dart';
import 'widgets/home_header.dart';
import 'widgets/recent_plants.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const Color _background = Color(0xFFF3F8F3);

  // ==========================================================================
  // APK DOWNLOAD
  // ==========================================================================

  static const String _apkUrl =
      'https://github.com/amrulhasa/greenmind_ai/releases/download/v1.0.0/GreenMind-AI-v1.0.0.apk';

  Future<void> _downloadApk(BuildContext context) async {
    final uri = Uri.parse(_apkUrl);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to open the APK download link.',
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open the APK download link.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Scaffold(
      backgroundColor: _background,
      bottomNavigationBar: const BottomNav(),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            const _HomeBackground(),

            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    18,
                    18,
                    38,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1180,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const HomeHeader(),

                          const SizedBox(height: 26),

                          const FeatureCard(),

                          const SizedBox(height: 22),

                          // ==================================================
                          // DOWNLOAD APK
                          // ==================================================

                          _DownloadApkCard(
                            onTap: () => _downloadApk(context),
                          ),

                          const SizedBox(height: 22),

                          const _QuickActionsCard(),

                          const SizedBox(height: 22),

                          _SecondaryFeatures(
                            isWide: constraints.maxWidth >= 900,
                          ),

                          const SizedBox(height: 30),

                          const RecentPlants(),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DOWNLOAD APK CARD
// ============================================================================

class _DownloadApkCard extends StatelessWidget {
  const _DownloadApkCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F6B2A),
            Color(0xFF2E7D32),
            Color(0xFF3D8D45),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(
              alpha: 0.16,
            ),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.15,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: 0.18,
                    ),
                  ),
                ),
                child: const Icon(
                  Icons.android_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GreenMind AI for Android',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Download and install the mobile app',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFDCEEDF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          const Text(
            'Get the GreenMind AI Android app and take '
            'your intelligent plant care assistant with you.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Color(0xFFE7F4E8),
            ),
          ),

          const SizedBox(height: 15),

          // ================================================================
          // VERSION INFO
          // ================================================================

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DownloadInfoChip(
                icon: Icons.android_rounded,
                label: 'Android',
              ),
              _DownloadInfoChip(
                icon: Icons.download_rounded,
                label: 'v1.0.0',
              ),
              _DownloadInfoChip(
                icon: Icons.storage_rounded,
                label: '68.4 MB',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ================================================================
          // DOWNLOAD BUTTON
          // ================================================================

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(
                Icons.download_rounded,
                size: 20,
              ),
              label: const Text(
                'Download Android APK',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2E7D32),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Center(
            child: Text(
              'Free • Android • Direct APK',
              style: TextStyle(
                fontSize: 10.5,
                color: Color(0xFFDCEEDF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DOWNLOAD INFO CHIP
// ============================================================================

class _DownloadInfoChip extends StatelessWidget {
  const _DownloadInfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.13,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: Colors.white,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SECONDARY FEATURES
// ============================================================================

class _SecondaryFeatures extends StatelessWidget {
  const _SecondaryFeatures({
    required this.isWide,
  });

  final bool isWide;

  void _openPlantReport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PlantReportScreen(),
      ),
    );
  }

  void _openNursery(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NearbyNurseryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _PlantReportCard(
              onTap: () => _openPlantReport(context),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: _NearbyNurseryCard(
              onTap: () => _openNursery(context),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _PlantReportCard(
          onTap: () => _openPlantReport(context),
        ),
        const SizedBox(height: 18),
        _NearbyNurseryCard(
          onTap: () => _openNursery(context),
        ),
      ],
    );
  }
}

// ============================================================================
// PREMIUM BACKGROUND
// ============================================================================

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF8FCF8),
                    Color(0xFFF3F8F3),
                    Color(0xFFEDF5EE),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: -160,
            left: -140,
            child: _GlowCircle(
              size: 390,
              color: const Color(0xFFB9E2BF),
              opacity: 0.24,
            ),
          ),

          Positioned(
            top: -120,
            right: -150,
            child: _GlowCircle(
              size: 370,
              color: const Color(0xFFD8EEDB),
              opacity: 0.42,
            ),
          ),

          Positioned(
            top: 420,
            right: -190,
            child: _GlowCircle(
              size: 410,
              color: const Color(0xFFCBE6CF),
              opacity: 0.17,
            ),
          ),

          Positioned(
            bottom: -190,
            left: -170,
            child: _GlowCircle(
              size: 430,
              color: const Color(0xFFB9DCBE),
              opacity: 0.15,
            ),
          ),

          Positioned(
            top: 125,
            right: 18,
            child: Transform.rotate(
              angle: -0.35,
              child: Icon(
                Icons.eco_rounded,
                size: 80,
                color: const Color(0xFF2E7D32).withValues(
                  alpha: 0.032,
                ),
              ),
            ),
          ),

          Positioned(
            top: 390,
            left: 4,
            child: Transform.rotate(
              angle: 0.4,
              child: Icon(
                Icons.spa_rounded,
                size: 94,
                color: const Color(0xFF2E7D32).withValues(
                  alpha: 0.023,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(
          alpha: opacity,
        ),
      ),
    );
  }
}

// ============================================================================
// QUICK ACTIONS
// ============================================================================

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFDDE9DE),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF18351C).withValues(
              alpha: 0.045,
            ),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.bolt_rounded,
            title: 'Quick Actions',
            subtitle: 'Everything you need, one tap away',
          ),

          const SizedBox(height: 17),

          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;

              if (compact) {
                return const Column(
                  children: [
                    _QuickActionItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Reminders',
                      subtitle: 'Plant care',
                      iconBackground: Color(0xFFE8F5E9),
                      iconColor: Color(0xFF2E7D32),
                      route: '/reminders',
                    ),
                    SizedBox(height: 10),
                    _QuickActionItem(
                      icon: Icons.campaign_outlined,
                      title: 'Announcements',
                      subtitle: 'Latest updates',
                      iconBackground: Color(0xFFFFF3E2),
                      iconColor: Color(0xFFEF6C00),
                      route: '/announcements',
                    ),
                  ],
                );
              }

              return const Row(
                children: [
                  Expanded(
                    child: _QuickActionItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Reminders',
                      subtitle: 'Plant care',
                      iconBackground: Color(0xFFE8F5E9),
                      iconColor: Color(0xFF2E7D32),
                      route: '/reminders',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionItem(
                      icon: Icons.campaign_outlined,
                      title: 'Announcements',
                      subtitle: 'Latest updates',
                      iconBackground: Color(0xFFFFF3E2),
                      iconColor: Color(0xFFEF6C00),
                      route: '/announcements',
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

// ============================================================================
// SECTION HEADER
// ============================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE7F5E9),
                Color(0xFFD8EEDB),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            size: 21,
            color: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF182019),
                  letterSpacing: -0.25,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF7A857C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// QUICK ACTION ITEM
// ============================================================================

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBackground,
    required this.iconColor,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBackground;
  final Color iconColor;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(19),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(19),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FBF8),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: const Color(0xFFE1EAE2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF243026),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7B867D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE0E8E1),
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: iconColor,
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
// PLANT REPORT CARD
// ============================================================================

class _PlantReportCard extends StatelessWidget {
  const _PlantReportCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE4F4E7),
            Color(0xFFF9FCF9),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFD3E7D6),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(
              alpha: 0.055,
            ),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _PremiumIconBox(
                icon: Icons.auto_awesome_rounded,
                background: Colors.white,
                color: Color(0xFF2E7D32),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plant Care Report',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18351C),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'AI-powered personalized care plan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF68786B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const _SmallAiBadge(),
            ],
          ),
          const SizedBox(height: 17),
          const Text(
            'Analyze your plant and receive personalized '
            'recommendations for watering, light, soil and care.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Color(0xFF657468),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _ReportFeature(
                  icon: Icons.water_drop_outlined,
                  title: 'Watering',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _ReportFeature(
                  icon: Icons.wb_sunny_outlined,
                  title: 'Light',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _ReportFeature(
                  icon: Icons.spa_outlined,
                  title: 'Care',
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
              ),
              label: const Text(
                'Create Care Report',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// NEARBY NURSERY CARD
// ============================================================================

class _NearbyNurseryCard extends StatelessWidget {
  const _NearbyNurseryCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE0E9E1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF18351C).withValues(
              alpha: 0.04,
            ),
            blurRadius: 28,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _PremiumIconBox(
                icon: Icons.location_on_rounded,
                background: Color(0xFFEAF5EC),
                color: Color(0xFF2E7D32),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nearby Nurseries',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D261F),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Find plant nurseries near you',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF778078),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8F5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE1E9E2),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: Color(0xFF68736A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE7EEE7),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.near_me_rounded,
                  size: 17,
                  color: Color(0xFF2E7D32),
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Discover trusted plant stores around your location',
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: Color(0xFF69756C),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(
                Icons.map_outlined,
                size: 18,
              ),
              label: const Text(
                'Explore Nearby',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
                side: const BorderSide(
                  color: Color(0xFFBFD8C2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PREMIUM ICON
// ============================================================================

class _PremiumIconBox extends StatelessWidget {
  const _PremiumIconBox({
    required this.icon,
    required this.background,
    required this.color,
  });

  final IconData icon;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 25,
        color: color,
      ),
    );
  }
}

// ============================================================================
// AI BADGE
// ============================================================================

class _SmallAiBadge extends StatelessWidget {
  const _SmallAiBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD8E8DA),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 13,
            color: Color(0xFF2E7D32),
          ),
          SizedBox(width: 4),
          Text(
            'AI',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// REPORT FEATURE
// ============================================================================

class _ReportFeature extends StatelessWidget {
  const _ReportFeature({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 43,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFDDE9DE),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF3F7D45),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF526456),
              ),
            ),
          ),
        ],
      ),
    );
  }
}