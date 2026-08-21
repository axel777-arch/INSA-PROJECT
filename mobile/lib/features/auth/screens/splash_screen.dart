import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../services/api_client.dart';
import '../../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService(apiClient: ApiClient());

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 1));
    await _authService.initialize();
    
    if (!mounted) return;

    if (_authService.isAuthenticated) {
      final user = _authService.currentUser!;
      final route = switch (user.role) {
        'ADMIN' => '/admin/home',
        'EXPERT' => '/expert/home',
        'EXTENSION_WORKER' => '/extension/home',
        _ => '/farmer/home',
      };
      Navigator.pushReplacementNamed(context, route);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('is_first_time') ?? true;
      if (isFirstTime) {
        await prefs.setBool('is_first_time', false);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/slideshow'); // Assuming a slideshow route exists
      } else {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.eco_rounded,
                size: 96,
                color: theme.primaryColor,
              ),
              const SizedBox(height: AppSizes.p24),
              Text(
                'Agri-Insight Beacon',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: AppSizes.p12),
              Text(
                'Precision agriculture, grounded in data.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
