import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../main.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/screen_backdrop.dart';
import '../../../services/api_client.dart';
import '../../../services/auth_service.dart';
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
  bool _isLoading = false;
  bool _rememberMe = false;
  final AuthService _authService = AuthService(apiClient: ApiClient());

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await _authService.login(
        _identifierController.text,
        _passwordController.text,
        rememberMe: _rememberMe,
      );
      if (!mounted) return;
      final route = switch (_authService.currentUser!.role) {
        'ADMIN' => '/admin/home',
        'EXPERT' => '/expert/home',
        'EXTENSION_WORKER' => '/extension/home',
        _ => '/farmer/home',
      };
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScreenBackdrop(
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
                    AppButton.text(
                      label: 'Admin login',
                      onPressed: () {
                        _identifierController.text = _adminUsername;
                        _passwordController.text = _adminPassword;
                        _handleLogin();
                      },
                    ),
                    const SizedBox(height: AppSizes.p8),

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
    );
  }
}
