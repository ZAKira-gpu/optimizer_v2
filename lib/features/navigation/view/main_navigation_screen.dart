import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/navigation_provider.dart';
import '../../home/view/home_screen.dart';
import '../../efficiency/view/efficiency_screen.dart';
import '../../health/view/health_screen.dart';
import '../../ranking/view/ranking_screen.dart';
import '../../profile/view/profile_screen.dart';

/// Main navigation screen with bottom navigation bar
///
/// This screen contains the bottom navigation bar and manages
/// navigation between the main app sections: Home, Efficiency, Fitness, and Ranking.
class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Main content that extends to the bottom
              Positioned.fill(
                child: IndexedStack(
                  index: navigationProvider.currentIndex,
                  children: const [
                    HomeScreen(),
                    EfficiencyScreen(),
                    HealthScreen(),
                    RankingScreen(),
                  ],
                ),
              ),
              // Floating bottom navigation bar
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      navigationBarTheme: NavigationBarThemeData(
                        labelTextStyle: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            );
                          }
                          return TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          );
                        }),
                      ),
                    ),
                    child: NavigationBar(
                      selectedIndex: navigationProvider.currentIndex,
                      onDestinationSelected: navigationProvider.setCurrentIndex,
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      height: 70,
                      indicatorColor: Colors.white.withOpacity(
                        0.4,
                      ), // Bigger white selection effect
                      indicatorShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelBehavior:
                          NavigationDestinationLabelBehavior.alwaysShow,
                      destinations: [
                        NavigationDestination(
                          icon: const Icon(
                            Icons.home_outlined,
                            color: Colors.white,
                          ),
                          selectedIcon: const Icon(
                            Icons.home_rounded,
                            color: Colors.white,
                          ),
                          label: 'Home',
                        ),
                        NavigationDestination(
                          icon: const Icon(
                            Icons.analytics_outlined,
                            color: Colors.white,
                          ),
                          selectedIcon: const Icon(
                            Icons.analytics,
                            color: Colors.white,
                          ),
                          label: 'Efficiency',
                        ),
                        NavigationDestination(
                          icon: const Icon(
                            Icons.favorite_outline,
                            color: Colors.white,
                          ),
                          selectedIcon: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                          ),
                          label: 'Health',
                        ),
                        NavigationDestination(
                          icon: const Icon(
                            Icons.leaderboard_outlined,
                            color: Colors.white,
                          ),
                          selectedIcon: const Icon(
                            Icons.leaderboard_rounded,
                            color: Colors.white,
                          ),
                          label: 'Ranking',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
