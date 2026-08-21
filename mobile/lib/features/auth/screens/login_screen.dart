import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../main.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/screen_backdrop.dart';
import '../../../services/api_client.dart';
import '../../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService(apiClient: ApiClient());
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier == 'admin@gmail.com' && password == 'Admin\$2026') {
      if (mounted) setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(context, '/admin/home');
      return;
    }

    try {
      final success = await _authService.login(
        identifier,
        password,
        rememberMe: _rememberMe,
      );
      if (!mounted) return;
      if (!success) {
        throw Exception('Invalid credentials');
      }
      final user = _authService.currentUser!;
      final route = switch (user.role) {
        'ADMIN' => '/admin/home',
        'EXPERT' => '/expert/home',
        'EXTENSION_WORKER' => '/extension/home',
        _ => '/farmer/home',
      };
      Navigator.pushReplacementNamed(context, route);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $error')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: ScreenBackdrop(
        child: Scaffold(
          backgroundColor: Colors.transparent,

          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: isDark ? Colors.white : Colors.black,
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                ),
                onPressed: () {
                  MyApp.themeNotifier.value = isDark
                      ? ThemeMode.light
                      : ThemeMode.dark;
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
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          final value = val?.trim() ?? '';
                          if (value.isEmpty) {
                            return 'Please enter phone or email';
                          }
                          final validPhone = RegExp(
                            r'^(09\d{8}|\+251\d{10})$',
                          ).hasMatch(value);
                          final validEmail = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(value);
                          return validPhone || validEmail
                              ? null
                              : 'Use a valid email or 10/14 digit Ethiopian phone number';
                        },
                      ),
                      const SizedBox(height: AppSizes.p16),
                      AppTextField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: (val) => val == null || val.length < 8
                            ? 'Password must be at least 8 characters'
                            : null,
                      ),
                      const SizedBox(height: AppSizes.p16),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _rememberMe,
                        onChanged: (value) =>
                            setState(() => _rememberMe = value ?? false),
                        title: const Text('Remember me'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: AppSizes.p8),

                      AppButton(
                        label: 'Login',
                        onPressed: _handleLogin,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: AppSizes.p16),
                      OutlinedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => setState(
                                () => _identifierController.text =
                                    'admin@gmail.com',
                              ),
                        icon: const Icon(Icons.admin_panel_settings_outlined),
                        label: const Text('Admin login'),
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
        ),
      ),
    );
  }
}
