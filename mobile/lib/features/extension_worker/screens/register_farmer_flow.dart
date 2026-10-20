import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../models/crop_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/farmer_service.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../core/widgets/ethiopian_location_selector.dart';

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
  String _selectedGender = 'Male';

  // Step 2: Farm location
  final _step2FormKey = GlobalKey<FormState>();
  EthiopianLocation? _ethiopianLocation;

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
    try {
      final crops = await _farmerService.getCrops();
      if (!mounted) return;
      setState(() {
        _availableCrops = crops;
        _loadingCrops = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCrops = false;
        _error = 'Failed to load crops: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
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
              content: Text('Please select or enter Region, Zone, Woreda, and Kebele.'),
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
    setState(() { _isSubmitting = true; _error = null; });
    try {
      // Step A: Create user account for the farmer
      final apiClient = ApiClient();
      final userResponse = await apiClient.post('/auth/register', {
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _phoneController.text.trim(), // default password = phone number
        'role': 'FARMER',
        'preferredLanguage': 'en',
      });

      final newUserId = userResponse['id'] as String;

      // Step B: Create farmer profile linked to that user
      final farmer = await _farmerService.registerFarmer(
        userId: newUserId,
        region: _ethiopianLocation!.region,
        zone: _ethiopianLocation!.zone,
        woreda: _ethiopianLocation!.woreda,
        kebele: _ethiopianLocation!.kebele,
        alertEnabled: true,
      );
      // Step C: Assign selected crops one by one
      for (final cropId in _selectedCropIds) {
        try {
          await _farmerService.assignCropToFarmer(farmer.id, cropId);
        } catch (e) {
          debugPrint('[RegisterFarmerFlow] Crop assignment failed for $cropId: $e');
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text.trim()} registered successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = e.message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e'), backgroundColor: AppColors.error),
      );
    }
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
              Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStepIndicator('1', 'Personal', active: _currentStep >= 0),
                    _buildStepIndicator('2', 'Farm', active: _currentStep >= 1),
                    _buildStepIndicator('3', 'Crops', active: _currentStep >= 2),
                    _buildStepIndicator('4', 'Review', active: _currentStep >= 3),
                  ],
                ),
              ),
              const Divider(),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                  child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                ),
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
                          onPressed: _isSubmitting ? null : () => setState(() => _currentStep--),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: AppButton(
                        label: _currentStep == 3 ? 'Register Farmer' : 'Next Step',
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _onPrimaryButtonPressed,
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

  Widget _buildStepIndicator(String index, String label, {required bool active}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: active ? theme.primaryColor : theme.dividerColor,
          child: Text(index, style: TextStyle(color: active ? Colors.white : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? theme.textTheme.bodyLarge?.color : Colors.grey, fontSize: 12)),
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
              Text("Enter farmer's contact information.", style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSizes.p20),
              AppTextField(
                label: 'Full Name *',
                controller: _nameController,
                prefixIcon: Icons.person_outline_rounded,
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Full name is required.';
                  if (t.length < 3) return 'Enter at least 3 characters.';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.p16),
              AppTextField(
                label: 'Phone Number *',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Phone number is required.';
                  if (!RegExp(r'^(09\d{8}|\+251\d{9})$').hasMatch(t)) {
                    return 'Use 09+8 digits or +251+9 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.p16),
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender *', prefixIcon: Icon(Icons.wc_rounded)),
                items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) { if (val != null) setState(() => _selectedGender = val); },
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
              Text('Farm Location Details', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSizes.p16),
              EthiopianLocationSelector(
                initialRegion: _ethiopianLocation?.region,
                initialZone: _ethiopianLocation?.zone,
                initialWoreda: _ethiopianLocation?.woreda,
                initialKebele: _ethiopianLocation?.kebele,
                onChanged: (loc) {
                  setState(() => _ethiopianLocation = loc);
                },
              ),
            ],
          ),
        );
      case 2:
        if (_loadingCrops) {
          return const Padding(padding: EdgeInsets.all(AppSizes.p32), child: Center(child: CircularProgressIndicator()));
        }
        if (_availableCrops.isEmpty) {
          return const Center(child: Text('No crops available. Please check your connection.'));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Select Crops to register', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSizes.p20),
            ..._availableCrops.map((crop) => CheckboxListTile(
              title: Text(crop.name),
              subtitle: Text(crop.description),
              value: _selectedCropIds.contains(crop.id),
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
            ListTile(title: const Text('Gender'), subtitle: Text(_selectedGender)),
            ListTile(
              title: const Text('Farm Location'),
              subtitle: Text('${_ethiopianLocation?.region ?? '-'}, ${_ethiopianLocation?.zone ?? '-'}, ${_ethiopianLocation?.woreda ?? '-'} / ${_ethiopianLocation?.kebele ?? '-'}'),
            ),
            ListTile(title: const Text('Crops Selected'), subtitle: Text(cropNames.isEmpty ? 'None selected' : cropNames)),
            const SizedBox(height: AppSizes.p12),
            Container(
              padding: const EdgeInsets.all(AppSizes.p12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Note: The farmer\'s default password will be their phone number. They should change it after first login.',
                style: TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
            ),
          ],
        );
    }
  }
}
