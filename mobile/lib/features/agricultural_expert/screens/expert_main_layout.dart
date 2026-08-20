import 'package:flutter/material.dart';

import '../../../../core/widgets/app_bottom_nav.dart';
import 'content_review_list_screen.dart';
import 'expert_analytics_screen.dart';
import 'expert_home_screen.dart';
import 'field_case_response_screen.dart';

class ExpertMainLayout extends StatefulWidget {
  const ExpertMainLayout({super.key});

  @override
  State<ExpertMainLayout> createState() => _ExpertMainLayoutState();
}

class _ExpertMainLayoutState extends State<ExpertMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ExpertHomeScreen(),
    ContentReviewListScreen(),
    FieldCaseResponseScreen(),
    ExpertAnalyticsScreen(),
  ];

  static const List<AppNavItem> _items = [
    AppNavItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    AppNavItem(
      icon: Icons.rate_review_outlined,
      selectedIcon: Icons.rate_review_rounded,
      label: 'Review',
    ),
    AppNavItem(
      icon: Icons.biotech_outlined,
      selectedIcon: Icons.biotech_rounded,
      label: 'Cases',
    ),
    AppNavItem(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics_rounded,
      label: 'Analytics',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        items: _items,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
