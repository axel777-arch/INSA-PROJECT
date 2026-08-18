import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class RoleOnboardingScreen extends StatefulWidget {
  final String role; // 'Farmer', 'Expert', 'Extension'

  const RoleOnboardingScreen({
    super.key,
    required this.role,
  });

  @override
  State<RoleOnboardingScreen> createState() => _RoleOnboardingScreenState();
}

class _RoleOnboardingScreenState extends State<RoleOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding text content for all 9 screens (3 per role)
  List<Map<String, dynamic>> _getPagesContent() {
    switch (widget.role.toLowerCase()) {
      case 'farmer':
        return [
          {
            'title': 'Rooted in Nature',
            'subtitle': 'Connect with certified agronomists and receive expert guidance matching your exact farm conditions.',
            'image': 'assets/images/farmer_onboarding_1.png',
            'icon': Icons.spa_rounded,
          },
          {
            'title': 'Instant Advisory Bulletins',
            'subtitle': 'Learn optimal crop sowing schedules, fertilization volumes, and sustainable watering methods.',
            'image': 'assets/images/farmer_onboarding_2.png',
            'icon': Icons.menu_book_rounded,
          },
          {
            'title': 'Real-time Bulletins',
            'subtitle': 'Get immediate storm warnings, frost alerts, and pest outbreak reports directly to your phone.',
            'buttonText': 'Enter My Farm',
            'image': 'assets/images/farmer_onboarding_3.png',
            'icon': Icons.notifications_active_rounded,
          },
        ];
      case 'expert':
        return [
          {
            'title': 'Review Bulletins Submissions',
            'subtitle': 'Evaluate draft articles written in the field and technical advisories before they are dispatched.',
            'image': 'assets/images/expert_onboarding_1.png',
            'icon': Icons.rate_review_rounded,
          },
          {
            'title': 'Diagnose Plant Pathology',
            'subtitle': 'Inspect high-resolution pest images submitted by field workers, diagnose leaves, and submit solutions.',
            'image': 'assets/images/expert_onboarding_2.png',
            'icon': Icons.biotech_rounded,
          },
          {
            'title': 'Track Regional Dynamics',
            'subtitle': 'Audit publication logs and advisory performance maps to optimize crop coverage strategies.',
            'buttonText': 'Open Expert Portal',
            'image': 'assets/images/expert_onboarding_3.png',
            'icon': Icons.analytics_rounded,
          },
        ];
      case 'extension':
      case 'extension worker':
      default:
        return [
          {
            'title': 'Field Registrations Stepper',
            'subtitle': 'Easily register local farmers directly in the field with a fully validated 4-step wizard.',
            'image': 'assets/images/extension_onboarding_1.png',
            'icon': Icons.group_add_rounded,
          },
          {
            'title': 'Record Crops Progress',
            'subtitle': 'Log sown crops, soil conditions, area measurements, and plant growth phases in your workspace.',
            'image': 'assets/images/extension_onboarding_2.png',
            'icon': Icons.grass_rounded,
          },
          {
            'title': 'Report Pest & Crop Diseases',
            'subtitle': 'Capture pictures of suspected crop diseases and escalate reports instantly to Experts for diagnosis.',
            'buttonText': 'Launch Workspace',
            'image': 'assets/images/extension_onboarding_3.png',
            'icon': Icons.add_photo_alternate_rounded,
          },
        ];
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = _getPagesContent();
    final isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background, // Elegant Light Sage background
      body: SafeArea(
        child: Column(
          children: [
            // Top Skip / Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p8),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => _finishOnboarding(),
                  child: Text(
                    isLastPage ? 'Close' : 'Skip',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Sliding Image / Fallback Icon Area
            Expanded(
              flex: 5,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSizes.p24),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Image.asset(
                              page['image']!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Transparent green leaf fallback container for missing assets
                                return Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSizes.p32),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        )
                                      ],
                                    ),
                                    child: Icon(
                                      page['icon'] as IconData,
                                      size: 100,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom White Text Card Container (Sage Theme Layout)
            Container(
              margin: const EdgeInsets.all(AppSizes.p24),
              padding: const EdgeInsets.all(AppSizes.p24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.r24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    pages[_currentPage]['title']!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),

                  // Subtitle
                  Text(
                    pages[_currentPage]['subtitle']!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p24),

                  // Dots Indicators & Actions Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots Indicator
                      Row(
                        children: List.generate(
                          pages.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.primary
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),

                      // Navigation Button
                      isLastPage
                          ? SizedBox(
                              width: 160,
                              child: AppButton(
                                label: pages[_currentPage]['buttonText'] ?? 'Enter',
                                onPressed: () => _finishOnboarding(),
                              ),
                            )
                          : FloatingActionButton.small(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: AppSizes.dMedium,
                                  curve: Curves.easeInOut,
                                );
                              },
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              child: const Icon(Icons.arrow_forward_rounded),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _finishOnboarding() {
    // Clear onboarding stack and push to main dashboard layouts
    final routeName = widget.role.toLowerCase() == 'farmer'
        ? '/farmer/home'
        : widget.role.toLowerCase() == 'expert'
            ? '/expert/home'
            : '/extension/home';
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
    );
  }
}
