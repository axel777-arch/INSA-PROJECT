import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
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
  String _selectedRole = 'Extension'; // Extensions and Experts require admin approval
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.transparent,
        foregroundColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: Center(
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
                    'Join the Agri-Insight Beacon network',
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
                  
                  // Role Selector
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
                        items: ['Extension', 'Expert'].map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role == 'Extension' 
                                ? 'Register as: Extension Worker' 
                                : 'Register as: Agricultural Expert'),
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
                  const SizedBox(height: AppSizes.p8),
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
        ),
      ),
    ));
  }
}
