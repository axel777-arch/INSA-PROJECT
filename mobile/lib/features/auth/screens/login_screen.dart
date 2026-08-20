import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../main.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/screen_backdrop.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static String get _adminUsername => dotenv.env['ADMIN_USERNAME'] ?? '';
  static String get _adminPassword => dotenv.env['ADMIN_PASSWORD'] ?? '';

  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Farmer'; // Temporary selector for mock testing
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final identifier = _identifierController.text.trim();
      final password = _passwordController.text;
      final isAdminLogin = identifier == _adminUsername && password == _adminPassword;

      // Simulate authentication request
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        if (isAdminLogin) {
          Navigator.pushReplacementNamed(context, '/admin/home');
        } else {
          Navigator.pushReplacementNamed(
            context,
            '/auth/onboarding',
            arguments: _selectedRole,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () {
              MyApp.themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          const SizedBox(width: AppSizes.p8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.eco_rounded,
                    size: 80,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Text(
                    'Agri-Insight Beacon',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  Text(
                    'Expert Agricultural Advisory System',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSizes.p32),
                  
                  AppTextField(
                    label: 'Phone or Email',
                    controller: _identifierController,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (val) => val == null || val.isEmpty
                        ? 'Please enter phone or email'
                        : null,
                  ),
                  const SizedBox(height: AppSizes.p16),
                  AppTextField(
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline_rounded,
                    validator: (val) => val == null || val.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: AppSizes.p16),
                  
                  // Role Selector for Mocking/Testing Flow
                  _buildRoleSelector(theme),
                  const SizedBox(height: AppSizes.p24),
                  
                  AppButton(
                    label: 'Login',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: AppSizes.p16),
                  
                  AppButton.text(
                    label: "Don't have an account? Register",
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildRoleSelector(ThemeData theme) {
    const roles = [
      {'label': 'Farmer', 'icon': Icons.agriculture_rounded},
      {'label': 'Extension', 'icon': Icons.support_agent_rounded},
      {'label': 'Expert', 'icon': Icons.psychology_alt_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am signing in as',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSizes.p12),
        Wrap(
          spacing: AppSizes.p12,
          runSpacing: AppSizes.p12,
          children: roles.map((role) {
            final label = role['label'] as String;
            final icon = role['icon'] as IconData;
            final isSelected = _selectedRole == label;

            return GestureDetector(
              onTap: () => setState(() => _selectedRole = label),
              child: AnimatedContainer(
                duration: AppSizes.dShort,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p12),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryColor : theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? theme.primaryColor : theme.dividerColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                    ),
                    const SizedBox(width: AppSizes.p8),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSizes.p8),
        Text(
          'Simulated for testing — real accounts verify role automatically.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}