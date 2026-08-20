import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Null until the user picks a role on the first step.
  String? _selectedRole;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate registration network call
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        // Expert and Extension users redirect to pending approval view
        Navigator.pushReplacementNamed(
          context,
          '/auth/pending-approval',
          arguments: _selectedRole,
        );
      });
    }
  }

  void _selectRole(String role) {
    setState(() => _selectedRole = role);
  }

  void _backToRolePicker() {
    setState(() => _selectedRole = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: Text(_selectedRole == null ? '' : 'Register'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_selectedRole == null) {
              Navigator.pop(context);
            } else {
              _backToRolePicker();
            }
          },
        ),
      ),
      body: SafeArea(
        child: _selectedRole == null
            ? _buildRolePicker(theme)
            : _buildRegistrationForm(theme),
      ),
    ));
  }

  Widget _buildRolePicker(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.p20),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(AppSizes.r16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your role',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.p8),
                Text(
                  "Select how you'd like to contribute",
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.p20),
          _buildRoleCard(
            theme: theme,
            role: 'Extension',
            icon: Icons.support_agent_rounded,
            title: 'Extension Worker',
            description: 'Field visits, farmer support, crop monitoring',
            buttonLabel: 'Continue as Extension Worker',
          ),
          const SizedBox(height: AppSizes.p16),
          _buildRoleCard(
            theme: theme,
            role: 'Expert',
            icon: Icons.psychology_alt_rounded,
            title: 'Agricultural Expert',
            description: 'Diagnosis, advisory review, technical guidance',
            buttonLabel: 'Continue as Expert',
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required ThemeData theme,
    required String role,
    required IconData icon,
    required String title,
    required String description,
    required String buttonLabel,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final tintBg = isDark ? AppColors.tintGreenBgDark : AppColors.tintGreenBg;
    final tintFg = isDark ? AppColors.tintGreenFgDark : AppColors.tintGreenFg;

    return Container(
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tintBg,
              borderRadius: BorderRadius.circular(AppSizes.r12),
            ),
            child: Icon(icon, color: tintFg, size: 24),
          ),
          const SizedBox(height: AppSizes.p16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.p4),
          Text(
            description,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSizes.p16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _selectRole(role),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.primaryColor,
                side: BorderSide(color: theme.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: AppSizes.p12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm(ThemeData theme) {
    final roleLabel = _selectedRole == 'Extension' ? 'Extension Worker' : 'Agricultural Expert';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Account',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: AppSizes.p8),
              Text(
                'Registering as $roleLabel',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSizes.p24),

              AppTextField(
                label: 'Full Name',
                controller: _nameController,
                prefixIcon: Icons.badge_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: AppSizes.p16),

              AppTextField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Please enter phone number' : null,
              ),
              const SizedBox(height: AppSizes.p16),

              AppTextField(
                label: 'Password',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline_rounded,
                validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: AppSizes.p16),

              AppTextField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline_rounded,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please confirm your password';
                  if (val != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.p16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
                child: Text(
                  'Note: Newly registered Extension Workers and Experts must wait for Admin approval before logging in.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p24),

              AppButton(
                label: 'Register',
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
    );
  }
}