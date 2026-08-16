import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Home Provider
///
/// Handles all business logic for the Home module.
/// Future updates:
/// - Load recent plants
/// - Fetch user profile
/// - Weather API
/// - Plant care reminders
/// - Dashboard statistics

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(),
);

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());

  void changeTab(int index) {
    state = state.copyWith(selectedIndex: index);
  }
}

class HomeState {
  final int selectedIndex;

  const HomeState({this.selectedIndex = 0});

  HomeState copyWith({int? selectedIndex}) {
    return HomeState(selectedIndex: selectedIndex ?? this.selectedIndex);
  }
}
