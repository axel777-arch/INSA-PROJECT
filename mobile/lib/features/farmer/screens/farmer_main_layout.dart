import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../content/screens/content_list_screen.dart';
import 'ask_extension_worker_screen.dart';
import 'farmer_home_screen.dart';
import 'farmer_profile_screen.dart';
import 'market_prices_screen.dart';

class FarmerMainLayout extends StatefulWidget {
  const FarmerMainLayout({super.key});

  @override
  State<FarmerMainLayout> createState() => _FarmerMainLayoutState();
}

class _FarmerMainLayoutState extends State<FarmerMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FarmerHomeScreen(),
    ContentListScreen(),
    MarketPricesScreen(),
    AskExtensionWorkerScreen(),
    FarmerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.current;

    final items = [
      AppNavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: loc.home,
      ),
      AppNavItem(
        icon: Icons.article_outlined,
        selectedIcon: Icons.article_rounded,
        label: loc.information,
      ),
      AppNavItem(
        icon: Icons.storefront_outlined,
        selectedIcon: Icons.storefront_rounded,
        label: loc.market,
      ),
      AppNavItem(
        icon: Icons.support_agent_outlined,
        selectedIcon: Icons.support_agent_rounded,
        label: loc.cases,
      ),
      AppNavItem(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: loc.profile,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        items: items,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
