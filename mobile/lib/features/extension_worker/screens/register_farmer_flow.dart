import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_sizes.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/app_button.dart';
import 'package:mobile/core/widgets/app_text_field.dart';
import 'package:mobile/core/widgets/ethiopian_location_selector.dart';
import 'package:mobile/core/widgets/screen_backdrop.dart';
import 'package:mobile/models/crop_model.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/services/farmer_service.dart';

class RegisterFarmerFlow extends StatefulWidget {
  const RegisterFarmerFlow({super.key});

  @override
  State<RegisterFarmerFlow> createState() => _RegisterFarmerFlowState();
}

class _RegisterFarmerFlowState extends State<RegisterFarmerFlow> {
  final FarmerService _farmerService = FarmerService(apiClient: ApiClient());

  int _currentStep = 0;
  bool _isSubmitting = false;
  String? _error;

  // Step 1: Personal details
  final _step1FormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedLanguage = 'amharic';
  bool _createAppAccount = false;

  // Step 2: Farm location & details
  final _step2FormKey = GlobalKey<FormState>();
  EthiopianLocation? _ethiopianLocation;
  final _farmSizeController = TextEditingController();
  final _experienceController = TextEditingController();

  // Step 3: Crops
  List<CropModel> _availableCrops = [];
  final Set<String> _selectedCropIds = {};
  bool _loadingCrops = false;
  String? _step3Error;

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _farmSizeController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadCrops() async {
    setState(() => _loadingCrops = true);
    try {
      final crops = await _farmerService.getCrops();
      if (mounted) setState(() => _availableCrops = crops);
    } catch (_) {
      // Non-fatal
    } finally {
      if (mounted) setState(() => _loadingCrops = false);
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _step1FormKey.currentState?.validate() ?? false;
      case 1:
        final formValid = _step2FormKey.currentState?.validate() ?? false;
        final locationValid = _ethiopianLocation != null && _ethiopianLocation!.isValid;
        if (!locationValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select Region, Zone, Woreda, and Kebele.'),
              backgroundColor: AppColors.error,
            ),
          );
          return false;
        }
        return formValid && locationValid;
      case 2:
        return true;
      default:
        return true;
    }
  }

  Future<void> _onPrimaryButtonPressed() async {
    if (!_validateCurrentStep()) return;
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      return;
    }
    await _submitRegistration();
  }

  Future<void> _submitRegistration() async {
    setState(() { _isSubmitting = true; _error = null; });
    try {
      final farmSize = double.tryParse(_farmSizeController.text.trim());
      final expYears = double.tryParse(_experienceController.text.trim());

      final farmer = await _farmerService.registerFarmer(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        preferredLanguage: _selectedLanguage,
        createAppAccount: _createAppAccount,
        farmSize: farmSize,
        experienceYears: expYears,
        region: _ethiopianLocation!.region,
        zone: _ethiopianLocation!.zone,
        woreda: _ethiopianLocation!.woreda,
        kebele: _ethiopianLocation!.kebele,
        alertEnabled: true,
        cropIds: _selectedCropIds.toList(),
      );

      if (!mounted) return;

      if (farmer.temporaryPassword != null) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Farmer Account Created'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_nameController.text.trim()} has been registered with app access.'),
                const SizedBox(height: 12),
                const Text('Temporary Password (one-time display):', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                SelectableText(
                  farmer.temporaryPassword!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please share this password securely with the farmer. They must change it upon their first login.',
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(true);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Farmer registered successfully (basic phone user).'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Farmer'),
        elevation: 0,
      ),
      body: ScreenBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p16),
                child: Row(
                  children: [
                    _buildStepIndicator('1', 'Personal', active: _currentStep >= 0),
                    _buildStepDivider(active: _currentStep >= 1),
                    _buildStepIndicator('2', 'Farm', active: _currentStep >= 1),
                    _buildStepDivider(active: _currentStep >= 2),
                    _buildStepIndicator('3', 'Crops', active: _currentStep >= 2),
                    _buildStepDivider(active: _currentStep >= 3),
                    _buildStepIndicator('4', 'Confirm', active: _currentStep >= 3),
                  ],
                ),
              ),
              if (_error != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p8),
                  padding: const EdgeInsets.all(AppSizes.p12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: AppSizes.p8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p8),
                  child: _buildCurrentStepContent(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.p24),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting ? null : () => setState(() => _currentStep--),
                          child: const Text('Back'),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: AppSizes.p16),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: _currentStep == 3 ? 'Confirm & Register' : 'Next',
                        isLoading: _isSubmitting,
                        onPressed: _onPrimaryButtonPressed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String number, String label, {required bool active}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: active ? AppColors.primary : Colors.grey.shade300,
          child: Text(
            number,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? AppColors.primary : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider({required bool active}) {
    return Expanded(
      child: Container(
        height: 2,
        color: active ? AppColors.primary : Colors.grey.shade300,
        margin: const EdgeInsets.only(bottom: 14),
      ),
    );
  }

  Widget _buildCurrentStepContent(BuildContext context) {
    final theme = Theme.of(context);
    switch (_currentStep) {
      case 0:
        return Form(
          key: _step1FormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Personal Information', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSizes.p20),
              AppTextField(
                label: 'Full Name *',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                validator: (v) => (v == null || v.trim().length < 2) ? 'Name must be at least 2 characters.' : null,
              ),
              const SizedBox(height: AppSizes.p16),
              AppTextField(
                label: 'Phone Number *',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (v) => (v == null || v.trim().length < 9) ? 'Enter a valid phone number.' : null,
              ),
              const SizedBox(height: AppSizes.p16),
              DropdownButtonFormField<String>(
                initialValue: _selectedLanguage,
                decoration: const InputDecoration(labelText: 'Preferred Language *', prefixIcon: Icon(Icons.language_rounded)),
                items: const [
                  DropdownMenuItem(value: 'amharic', child: Text('Amharic')),
                  DropdownMenuItem(value: 'oromo', child: Text('Afaan Oromoo')),
                  DropdownMenuItem(value: 'tigrinya', child: Text('Tigrinya')),
                  DropdownMenuItem(value: 'somali', child: Text('Somali')),
                  DropdownMenuItem(value: 'english', child: Text('English')),
                ],
                onChanged: (val) { if (val != null) setState(() => _selectedLanguage = val); },
              ),
              const SizedBox(height: AppSizes.p20),
              SwitchListTile(
                title: const Text('Enable Mobile App Login'),
                subtitle: const Text('Farmer will receive a secure temporary password to log into the mobile app.'),
                value: _createAppAccount,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => setState(() => _createAppAccount = val),
              ),
            ],
          ),
        );
      case 1:
        return Form(
          key: _step2FormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Farm Location & Size', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSizes.p20),
              EthiopianLocationSelector(
                initialRegion: _ethiopianLocation?.region,
                initialZone: _ethiopianLocation?.zone,
                initialWoreda: _ethiopianLocation?.woreda,
                initialKebele: _ethiopianLocation?.kebele,
                onChanged: (loc) {
                  setState(() => _ethiopianLocation = loc);
                },
              ),
              const SizedBox(height: AppSizes.p16),
              AppTextField(
                label: 'Farm Size (Hectares)',
                controller: _farmSizeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.crop_free_outlined,
              ),
              const SizedBox(height: AppSizes.p16),
              AppTextField(
                label: 'Farming Experience (Years)',
                controller: _experienceController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.history_edu_outlined,
              ),
            ],
          ),
        );
      case 2:
        if (_loadingCrops) {
          return const Padding(padding: EdgeInsets.all(AppSizes.p32), child: Center(child: CircularProgressIndicator()));
        }
        if (_availableCrops.isEmpty) {
          return const Center(child: Text('No crops available in catalog.'));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Select Crops Cultivated', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSizes.p20),
            ..._availableCrops.map((crop) => CheckboxListTile(
              title: Text(crop.name),
              subtitle: Text(crop.description),
              value: _selectedCropIds.contains(crop.id),
              activeColor: AppColors.primary,
              onChanged: (checked) {
                setState(() {
                  if (checked == true) { _selectedCropIds.add(crop.id); }
                  else { _selectedCropIds.remove(crop.id); }
                  if (_selectedCropIds.isNotEmpty) _step3Error = null;
                });
              },
            )),
            if (_step3Error != null) ...[
              const SizedBox(height: AppSizes.p8),
              Text(_step3Error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ],
          ],
        );
      default:
        final cropNames = _availableCrops
            .where((c) => _selectedCropIds.contains(c.id))
            .map((c) => c.name)
            .join(', ');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Verify Registration Details', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSizes.p20),
            ListTile(title: const Text('Full Name'), subtitle: Text(_nameController.text)),
            ListTile(title: const Text('Phone Number'), subtitle: Text(_phoneController.text)),
            ListTile(title: const Text('Preferred Language'), subtitle: Text(_selectedLanguage)),
            ListTile(
              title: const Text('App Login Account'),
              subtitle: Text(_createAppAccount ? 'Yes (Temporary password will be generated)' : 'No (Basic phone user)'),
            ),
            ListTile(
              title: const Text('Farm Location'),
              subtitle: Text('${_ethiopianLocation?.region ?? '-'}, ${_ethiopianLocation?.zone ?? '-'}, ${_ethiopianLocation?.woreda ?? '-'} / Kebele ${_ethiopianLocation?.kebele ?? '-'}'),
            ),
            if (_farmSizeController.text.isNotEmpty)
              ListTile(title: const Text('Farm Size'), subtitle: Text('${_farmSizeController.text} Hectares')),
            ListTile(title: const Text('Crops Selected'), subtitle: Text(cropNames.isEmpty ? 'None selected' : cropNames)),
          ],
        );
    }
  }
}
