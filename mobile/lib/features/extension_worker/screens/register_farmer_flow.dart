import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../models/crop_model.dart';
import '../../../../models/farmer_model.dart';
import '../../../../services/mock_api_client.dart';
import '../../../../services/farmer_service.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class RegisterFarmerFlow extends StatefulWidget {
  const RegisterFarmerFlow({super.key});

  @override
  State<RegisterFarmerFlow> createState() => _RegisterFarmerFlowState();
}

class _RegisterFarmerFlowState extends State<RegisterFarmerFlow> {
  final FarmerService _farmerService = FarmerService(apiClient: ApiClient());

  int _currentStep = 0;
  bool _isSubmitting = false;

  // Step 1: Personal details
  final _step1FormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedGender = 'Male';

  // Step 2: Farm location
  final _step2FormKey = GlobalKey<FormState>();
  final _regionController = TextEditingController();
  final _zoneController = TextEditingController();
  String? _selectedWoreda;
  String? _selectedKebele;

  static const List<String> _woredaOptions = [
    'Adama',
    'Debre Birhan',
    'Hawassa Zuria',
    'Bahir Dar Zuria',
    'Sebeta',
  ];
  static const List<String> _kebeleOptions = ['01', '02', '03', '04', '05'];

  // Step 3: Crops
  List<CropModel> _availableCrops = [];
  bool _loadingCrops = true;
  final Set<String> _selectedCropIds = {};
  String? _step3Error;

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    final crops = await _farmerService.getCrops();
    if (!mounted) return;
    setState(() {
      _availableCrops = crops;
      _loadingCrops = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _regionController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  /// Validates the current step and, if valid, advances to the next one.
  /// Returns false (and shows inline/snackbar errors) if the step is invalid.
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _step1FormKey.currentState?.validate() ?? false;
      case 1:
        final formValid = _step2FormKey.currentState?.validate() ?? false;
        final locationValid =
            _selectedWoreda != null && _selectedKebele != null;
        if (!locationValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select both Woreda and Kebele.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return formValid && locationValid;
      case 2:
        if (_selectedCropIds.isEmpty) {
          setState(() => _step3Error = 'Select at least one crop to continue.');
          return false;
        }
        setState(() => _step3Error = null);
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
    setState(() => _isSubmitting = true);

    final newFarmer = FarmerModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: '',
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: _selectedGender,
      region: _regionController.text.trim(),
      zone: _zoneController.text.trim(),
      woreda: _selectedWoreda!,
      kebele: _selectedKebele!,
      alertEnabled: true,
      active: true,
      cropIds: _selectedCropIds.toList(),
    );

    final saved = await _farmerService.registerFarmer(newFarmer);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${saved.fullName} registered successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text('Register Farmer')),
        body: SafeArea(
          child: Column(
            children: [
              // Horizontal Step Indicators
              Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStepIndicator(
                      '1',
                      'Personal',
                      active: _currentStep >= 0,
                    ),
                    _buildStepIndicator('2', 'Farm', active: _currentStep >= 1),
                    _buildStepIndicator(
                      '3',
                      'Crops',
                      active: _currentStep >= 2,
                    ),
                    _buildStepIndicator(
                      '4',
                      'Review',
                      active: _currentStep >= 3,
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.p20),
                  child: _buildStepContent(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: AppButton.outlined(
                          label: 'Back',
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    _currentStep--;
                                  });
                                },
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: AppButton(
                        label: _currentStep == 3
                            ? 'Register Farmer'
                            : 'Next Step',
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting
                            ? null
                            : _onPrimaryButtonPressed,
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

  Widget _buildStepIndicator(
    String index,
    String label, {
    required bool active,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: active ? theme.primaryColor : theme.dividerColor,
          child: Text(
            index,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? theme.textTheme.bodyLarge?.color : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    final theme = Theme.of(context);
    switch (_currentStep) {
      case 0:
        return Form(
          key: _step1FormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter farmer\'s primary contact and personal information.',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSizes.p20),
              AppTextField(
                label: 'Full Name *',
                controller: _nameController,
                prefixIcon: Icons.person_outline_rounded,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return 'Full name is required.';
                  if (trimmed.length < 3) return 'Enter at least 3 characters.';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.p16),
              AppTextField(
                label: 'Phone Number *',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return 'Phone number is required.';
                  final phoneRegex = RegExp(r'^\+?[0-9]{9,13}$');
                  if (!phoneRegex.hasMatch(trimmed))
                    return 'Enter a valid phone number.';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.p16),
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender *',
                  prefixIcon: Icon(Icons.wc_rounded),
                ),
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedGender = val);
                },
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
              Text('Farm Location details', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSizes.p20),
              AppTextField(
                label: 'Region *',
                controller: _regionController,
                prefixIcon: Icons.map_outlined,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Region is required.'
                    : null,
              ),
              const SizedBox(height: AppSizes.p16),
              AppTextField(
                label: 'Zone *',
                controller: _zoneController,
                prefixIcon: Icons.explore_outlined,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Zone is required.'
                    : null,
              ),
              const SizedBox(height: AppSizes.p16),
              DropdownButtonFormField<String>(
                initialValue: _selectedWoreda,
                decoration: const InputDecoration(
                  labelText: 'Woreda *',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                items: _woredaOptions
                    .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedWoreda = val),
              ),
              const SizedBox(height: AppSizes.p16),
              DropdownButtonFormField<String>(
                initialValue: _selectedKebele,
                decoration: const InputDecoration(
                  labelText: 'Kebele *',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                items: _kebeleOptions
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedKebele = val),
              ),
            ],
          ),
        );
      case 2:
        if (_loadingCrops) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.p32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Crops to register',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.p20),
            ..._availableCrops.map((crop) {
              return CheckboxListTile(
                title: Text(crop.name),
                subtitle: Text(crop.description),
                value: _selectedCropIds.contains(crop.id),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedCropIds.add(crop.id);
                    } else {
                      _selectedCropIds.remove(crop.id);
                    }
                    if (_selectedCropIds.isNotEmpty) _step3Error = null;
                  });
                },
              );
            }),
            if (_step3Error != null) ...[
              const SizedBox(height: AppSizes.p8),
              Text(
                _step3Error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
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
            Text(
              'Verify Registration Details',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.p20),
            ListTile(
              title: const Text('Full Name'),
              subtitle: Text(_nameController.text),
            ),
            ListTile(
              title: const Text('Phone Number'),
              subtitle: Text(_phoneController.text),
            ),
            ListTile(
              title: const Text('Gender'),
              subtitle: Text(_selectedGender),
            ),
            ListTile(
              title: const Text('Farm Location'),
              subtitle: Text(
                '${_regionController.text}, ${_zoneController.text}, '
                '${_selectedWoreda ?? '-'} / ${_selectedKebele ?? '-'}',
              ),
            ),
            ListTile(
              title: const Text('Crops Selected'),
              subtitle: Text(cropNames.isEmpty ? 'None selected' : cropNames),
            ),
          ],
        );
    }
  }
}
