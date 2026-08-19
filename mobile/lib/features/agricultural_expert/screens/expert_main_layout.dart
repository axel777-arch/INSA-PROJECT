import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.rate_review_rounded), label: 'Review'),
          BottomNavigationBarItem(icon: Icon(Icons.biotech_rounded), label: 'Cases'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Analytics'),
        ],
      ),
    );
  }
}
