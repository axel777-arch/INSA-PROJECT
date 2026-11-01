import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/ethiopian_location_selector.dart';
import '../../../../core/widgets/role_app_bar_actions.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/api_client.dart';
import '../../../../services/auth_service.dart';
import 'pending_approval_screen.dart';

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

  // Documents
  String? _idFileName;
  String? _experienceFileName;
  String? _educationFileName;

  // Extension worker location
  EthiopianLocation? _extensionLocation;

  // Null until the user picks a role on the first step.
  String? _selectedRole;
  bool _isLoading = false;
  final AuthService _authService = AuthService(apiClient: ApiClient());

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        if (type == 'id') _idFileName = result.files.first.name;
        if (type == 'experience') _experienceFileName = result.files.first.name;
        if (type == 'education') _educationFileName = result.files.first.name;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedRole == 'Extension' &&
        (_extensionLocation == null || !_extensionLocation!.isValid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appText('Please select your operating location (Region & Zone).'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Package documents and location into JSON
    final verificationMap = <String, dynamic>{
      'id_file': _idFileName,
      'experience_file': _experienceFileName,
      'education_file': _educationFileName,
      if (_selectedRole == 'Extension' && _extensionLocation != null)
        'location': {
          'region': _extensionLocation!.region,
          'zone': _extensionLocation!.zone,
          'woreda': _extensionLocation!.woreda,
          'kebele': _extensionLocation!.kebele,
        },
    };

    try {
      final registered = await _authService.register(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole! == 'Extension' ? 'EXTENSION_WORKER' : 'EXPERT',
        preferredLanguage: 'en',
        documentUrl: jsonEncode(verificationMap),
      );
      if (!registered) {
        throw ApiException('Registration failed. Please try again.');
      }
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/auth/pending-approval',
          arguments: PendingApprovalArguments(
            role: _selectedRole!,
            identifier: _phoneController.text.trim(),
            password: _passwordController.text,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        final message =
            error is ApiException ? error.message : error.toString();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            _selectedRole == null
                ? ''
                : (_selectedRole == 'Extension'
                    ? appText('Extension Worker')
                    : appText('Agricultural Expert')),
          ),
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
          actions: [
            IconButton(
              icon: const Icon(Icons.language_rounded),
              tooltip: appText('Select Language'),
              onPressed: () => showAppLanguagePicker(context),
            ),
          ],
        ),
        body: SafeArea(
          child: _selectedRole == null
              ? _buildRolePicker(theme)
              : _buildRegistrationForm(theme),
        ),
      ),
    );
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
                Center(
                  child: Text(
                    appText('Choose your role'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.p8),
                Center(
                  child: Text(
                    appText("Select how you'd like to contribute"),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.p20),
          _buildRoleCard(
            theme: theme,
            role: 'Extension',
            icon: Icons.support_agent_rounded,
            title: appText('Extension Worker'),
            description: appText('Field visits, farmer support, crop monitoring'),
            buttonLabel: appText('Continue as Extension Worker'),
          ),
          const SizedBox(height: AppSizes.p16),
          _buildRoleCard(
            theme: theme,
            role: 'Expert',
            icon: Icons.psychology_alt_rounded,
            title: appText('Agricultural Expert'),
            description: appText('Diagnosis, advisory review, technical guidance'),
            buttonLabel: appText('Continue as Expert'),
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
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.p4),
          Text(description, style: theme.textTheme.bodyMedium),
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

  Widget _buildFileAttachmentTile({
    required String title,
    required String? fileName,
    required VoidCallback onPick,
    required VoidCallback onRemove,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p12),
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.r12),
        border: Border.all(
          color: fileName != null
              ? theme.primaryColor.withValues(alpha: 0.5)
              : theme.dividerColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  fileName ?? appText('No document attached'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: fileName != null
                        ? theme.primaryColor
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (fileName != null)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: onRemove,
              tooltip: appText('Remove'),
            )
          else
            TextButton.icon(
              icon: const Icon(Icons.upload_file_rounded, size: 16),
              label: Text(appText('Attach')),
              onPressed: onPick,
            ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm(ThemeData theme) {
    final roleLabel = _selectedRole == 'Extension'
        ? appText('Extension Worker')
        : appText('Agricultural Expert');

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                appText('Create Account'),
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
              const SizedBox(height: AppSizes.p20),

              AppTextField(
                label: appText('Full Name'),
                controller: _nameController,
                prefixIcon: Icons.badge_outlined,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: AppSizes.p16),

              AppTextField(
                label: appText('Phone Number'),
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (val) =>
                    val == null ||
                        !RegExp(r'^(09\d{8}|\+251\d{9})$').hasMatch(val.trim())
                    ? appText('Use 09 plus 8 digits or +251 plus 9 digits')
                    : null,
              ),
              const SizedBox(height: AppSizes.p16),

              AppTextField(
                label: appText('Password'),
                controller: _passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline_rounded,
                validator: (val) => val == null || val.length < 8
                    ? 'Password must be at least 8 characters'
                    : null,
              ),
              const SizedBox(height: AppSizes.p16),

              AppTextField(
                label: appText('Confirm Password'),
                controller: _confirmPasswordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline_rounded,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return appText('Please confirm your password');
                  }
                  if (val != _passwordController.text) {
                    return appText('Passwords do not match');
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.p20),

              // Verification Documents Section
              Text(
                appText('Registration Documents'),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: AppSizes.p8),
              _buildFileAttachmentTile(
                title: appText('ID / Kebele ID Document'),
                fileName: _idFileName,
                icon: Icons.badge_outlined,
                onPick: () => _pickFile('id'),
                onRemove: () => setState(() => _idFileName = null),
              ),
              _buildFileAttachmentTile(
                title: appText('Experience Document / Paper'),
                fileName: _experienceFileName,
                icon: Icons.work_outline_rounded,
                onPick: () => _pickFile('experience'),
                onRemove: () => setState(() => _experienceFileName = null),
              ),
              _buildFileAttachmentTile(
                title: appText('Educational Paper / Degree'),
                fileName: _educationFileName,
                icon: Icons.school_outlined,
                onPick: () => _pickFile('education'),
                onRemove: () => setState(() => _educationFileName = null),
              ),

              // Location for Extension Worker
              if (_selectedRole == 'Extension') ...[
                const SizedBox(height: AppSizes.p16),
                Text(
                  appText('Operating Location (Extension Worker)'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppSizes.p8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.p12),
                    child: EthiopianLocationSelector(
                      showHeader: true,
                      onChanged: (loc) =>
                          setState(() => _extensionLocation = loc),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSizes.p16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
                child: Text(
                  appText(
                    'Note: Newly registered Extension Workers and Experts must wait for Admin approval before logging in.',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p24),

              AppButton(
                label: appText('Register'),
                onPressed: _handleRegister,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppSizes.p16),

              AppButton.text(
                label: appText('Already have an account? Login'),
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
