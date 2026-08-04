import 'package:flutter/material.dart';

import 'widgets/bottom_nav.dart';
import 'widgets/feature_card.dart';
import 'widgets/home_header.dart';
import 'widgets/recent_plants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNav(),

      body: SafeArea(
        child: SingleChildScrollView(
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