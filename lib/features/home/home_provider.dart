import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ============================================================
/// HOME PROVIDER
/// ============================================================
///
/// Handles Home module state.
///
/// Currently prepared for future dashboard features such as:
/// - Recent plants
/// - User profile
/// - Plant care reminders
/// - Weather information
/// - Dashboard statistics
///
/// Navigation/tab state is intentionally NOT handled here.
/// GoRouter + BottomNav are responsible for navigation.
///

final homeProvider =
    NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    return const HomeState();
  }

  /// Future Home business logic can be added here.
  ///
  /// Example:
  /// - refreshDashboard()
  /// - loadWeather()
  /// - loadStatistics()
  /// - refreshHomeData()
}


/// ============================================================
/// HOME STATE
/// ============================================================

class HomeState {
  const HomeState();

  HomeState copyWith() {
    return const HomeState();
  }
}