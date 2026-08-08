import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_provider.dart';
import '../profile/screens/profile_screen.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/feature_card.dart';
import 'widgets/home_header.dart';
import 'widgets/recent_plants.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return Scaffold(
      bottomNavigationBar: const BottomNav(),
      body: SafeArea(
        child: state.selectedIndex == 3
            ? const ProfileScreen()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    HomeHeader(),

                    SizedBox(height: 24),

                    FeatureCard(),

                    SizedBox(height: 24),

                    RecentPlants(),
                  ],
                ),
              ),
      ),
    );
  }
}