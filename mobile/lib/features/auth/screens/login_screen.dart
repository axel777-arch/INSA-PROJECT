import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

      // Simulate authentication request
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        // Routing based on selected role
        switch (_selectedRole) {
          case 'Farmer':
            Navigator.pushReplacementNamed(context, '/farmer/home');
            break;
          case 'Extension':
            Navigator.pushReplacementNamed(context, '/extension/home');
            break;
          case 'Expert':
            Navigator.pushReplacementNamed(context, '/expert/home');
            break;
          case 'Admin':
            Navigator.pushReplacementNamed(context, '/admin/home');
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(AppSizes.r12),
                      color: theme.cardTheme.color,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        isExpanded: true,
                        items: ['Farmer', 'Extension', 'Expert', 'Admin'].map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text('Simulate Login as: $role'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedRole = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
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
    );
  }
}
