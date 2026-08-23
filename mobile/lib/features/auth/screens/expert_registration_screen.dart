import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/api_client.dart';
import '../../../../services/auth_service.dart';

class ExpertRegistrationScreen extends StatefulWidget {
  const ExpertRegistrationScreen({super.key});

  @override
  State<ExpertRegistrationScreen> createState() =>
      _ExpertRegistrationScreenState();
}

class _ExpertRegistrationScreenState extends State<ExpertRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService(apiClient: ApiClient());

  String _selectedSpecialization = 'Agronomy';
  String _selectedRegion = 'Arid Southwest';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await _authService.register(
        fullName: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: 'EXPERT',
        preferredLanguage: 'en',
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth/account-under-review');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text('Expert Registration'),
          backgroundColor: Colors.transparent,
          foregroundColor: theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.p24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Join as Expert',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  const Text(
                    'Provide credentials to validate agricultural content.',
                  ),
                  const SizedBox(height: AppSizes.p24),

                  AppTextField(
                    label: 'Full Name',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: AppSizes.p16),

                  AppTextField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: (val) =>
                        val == null ||
                            !RegExp(
                              r'^(09\d{8}|\+251\d{9})$',
                            ).hasMatch(val.trim())
                        ? 'Use 09 plus 8 digits or +251 plus 9 digits'
                        : null,
                  ),
                  const SizedBox(height: AppSizes.p16),

                  AppTextField(
                    label: 'Email Address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (val) =>
                        val == null ||
                            !RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(val.trim())
                        ? 'Enter a valid email address'
                        : null,
                  ),
                  const SizedBox(height: AppSizes.p16),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedSpecialization,
                    decoration: const InputDecoration(
                      labelText: 'Area of Expertise',
                      prefixIcon: Icon(Icons.psychology_outlined),
                    ),
                    items:
                        [
                          'Agronomy',
                          'Pest Control',
                          'Soil Health',
                          'Irrigation',
                        ].map((spec) {
                          return DropdownMenuItem(
                            value: spec,
                            child: Text(spec),
                          );
                        }).toList(),
                    onChanged: (val) {
                      if (val != null)
                        setState(() => _selectedSpecialization = val);
                    },
                  ),
                  const SizedBox(height: AppSizes.p16),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedRegion,
                    decoration: const InputDecoration(
                      labelText: 'Operating Region',
                      prefixIcon: Icon(Icons.travel_explore_rounded),
                    ),
                    items: ['Arid Southwest', 'Northern Zone', 'Valley Basin']
                        .map((reg) {
                          return DropdownMenuItem(value: reg, child: Text(reg));
                        })
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRegion = val);
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
                  const SizedBox(height: AppSizes.p24),

                  AppButton(
                    label: 'Register as Expert',
                    onPressed: _handleRegister,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: AppSizes.p16),

                  AppButton.text(
                    label: 'Already have an account? Login',
                    onPressed: () {
                      Navigator.pop(context);
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
