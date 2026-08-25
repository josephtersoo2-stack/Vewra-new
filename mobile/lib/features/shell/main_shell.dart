import 'package:flutter/material.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../../core/widgets/layout/app_bottom_nav.dart';
import '../home/screens/home_screen.dart';
import '../tasks/screens/tasks_screen.dart';
import '../rewards/screens/rewards_screen.dart';
import '../wallet/screens/wallet_screen.dart';
import '../profile/screens/profile_screen.dart';

/// Main Application Shell maintaining persistent bottom navigation across 5 core feature tabs.
class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onSwitchToTasks: () => _onTabSelected(1),
            onSwitchToRewards: () => _onTabSelected(2),
            onSwitchToWallet: () => _onTabSelected(3),
          ),
          const TasksScreen(),
          const RewardsScreen(),
          const WalletScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
