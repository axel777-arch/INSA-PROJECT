import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/language_service.dart';
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
      final identifier = _identifierController.text.trim().replaceAll(RegExp(r'\s+'), '');
      final password = _passwordController.text;

      final success = await _authService.login(
        identifier,
        password,
        rememberMe: _rememberMe,
      );
      if (!mounted) return;
      if (!success || _authService.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authService.lastError ?? 'Invalid credentials or unregistered account'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final route = switch (_authService.currentUser!.role) {
        'ADMIN' => '/admin/home',
        'EXPERT' => '/expert/home',
        'EXTENSION_WORKER' => '/extension/home',
        _ => '/farmer/home',
      };
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    } catch (error) {
      if (mounted) {
        final message = error is ApiException ? error.message : error.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
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
              icon: const Icon(Icons.language_rounded),
              tooltip: 'Language',
              onPressed: () async {
                await Navigator.pushNamed(context, '/choose-language');
                if (mounted) setState(() {});
              },
            ),
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
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? const Color(0xFFC2C9BD) : const Color(0xFF43493E),
                      ),
                    ),
                    const SizedBox(height: AppSizes.p32),

                    AppTextField(
                      label: LanguageService.tr('phone_or_email'),
                      controller: _identifierController,
                      prefixIcon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        final value = val?.trim() ?? '';
                        if (value.isEmpty) {
                          return 'Please enter phone or email';
                        }
                        final cleaned = value.replaceAll(RegExp(r'\s+'), '');
                        final validPhone = RegExp(
                          r'^(09\d{8}|\+251\d{9}|9\d{8})$',
                        ).hasMatch(cleaned);
                        final validEmail = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(cleaned);
                        final isAlpha = RegExp(
                          r'^[a-zA-Z0-9_\-\.]{3,}$',
                        ).hasMatch(cleaned);
                        return validPhone || validEmail || isAlpha
                            ? null
                            : 'Use a valid email or Ethiopian phone number';
                      },
                    ),
                    const SizedBox(height: AppSizes.p16),
                    AppTextField(
                      label: LanguageService.tr('password'),
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
                      title: Text(
                        LanguageService.tr('remember_me'),
                        style: TextStyle(
                          color: isDark ? const Color(0xFFE1E5DC) : const Color(0xFF191E18),
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: AppSizes.p8),

                    AppButton(
                      label: LanguageService.tr('login'),
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: AppSizes.p16),

                    AppButton.text(
                      label: LanguageService.tr('no_account'),
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
