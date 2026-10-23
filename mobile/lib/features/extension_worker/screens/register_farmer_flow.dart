import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../models/crop_model.dart';
import '../../../../services/api_client.dart';
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
  String? _error;

  // Step 1: Personal details
  final _step1FormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedLanguage = 'amharic';
  bool _createAppAccount = false;

  // Step 2: Farm details
  final _step2FormKey = GlobalKey<FormState>();
  final _regionController = TextEditingController();
  final _zoneController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final _experienceController = TextEditingController();
  String? _selectedWoreda;
  String? _selectedKebele;

  static const List<String> _woredaOptions = [
    'Ada\'a', 'Adama', 'Debre Birhan', 'Hawassa Zuria',
    'Bahir Dar Zuria', 'Sebeta', 'Chuko', 'Bure',
  ];
  static const List<String> _kebeleOptions = ['01', '02', '03', '04', '05'];

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
    _regionController.dispose();
    _zoneController.dispose();
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
        if (!(_step2FormKey.currentState?.validate() ?? false)) return false;
        if (_selectedWoreda == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a woreda.')),
          );
          return false;
        }
        if (_selectedKebele == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a kebele.')),
          );
          return false;
        }
        return true;
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
        region: _regionController.text.trim(),
        zone: _zoneController.text.trim(),
        woreda: _selectedWoreda!,
        kebele: _selectedKebele!,
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
                const SizedBox(height: 8),
                const Text(
                  'The farmer will use their phone number and this temporary password to log in. Please share it with them securely.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameController.text.trim()} registered successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      if (mounted) Navigator.pop(context, true);
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
                    _buildStepDivider(active: _currentStep >= 1),
                    _buildStepIndicator('2', 'Farm', active: _currentStep >= 1),
                    _buildStepDivider(active: _currentStep >= 2),
                    _buildStepIndicator('3', 'Crops', active: _currentStep >= 2),
                    _buildStepDivider(active: _currentStep >= 3),
                    _buildStepIndicator('4', 'Review', active: _currentStep >= 3),
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
                        text: _currentStep == 3 ? 'Confirm & Register' : 'Next',
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
                value: _selectedLanguage,
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
                activeColor: AppColors.primary,
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
              AppTextField(
                label: 'Region *', controller: _regionController, prefixIcon: Icons.map_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Region is required.' : null,
              ),
              const SizedBox(height: AppSizes.p16),
              AppTextField(
                label: 'Zone *', controller: _zoneController, prefixIcon: Icons.explore_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Zone is required.' : null,
              ),
              const SizedBox(height: AppSizes.p16),
              DropdownButtonFormField<String>(
                value: _selectedWoreda,
                decoration: const InputDecoration(labelText: 'Woreda *', prefixIcon: Icon(Icons.location_city_outlined)),
                items: _woredaOptions.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                onChanged: (val) => setState(() => _selectedWoreda = val),
              ),
              const SizedBox(height: AppSizes.p16),
              DropdownButtonFormField<String>(
                value: _selectedKebele,
                decoration: const InputDecoration(labelText: 'Kebele *', prefixIcon: Icon(Icons.home_outlined)),
                items: _kebeleOptions.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                onChanged: (val) => setState(() => _selectedKebele = val),
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
              subtitle: Text('${_regionController.text}, ${_zoneController.text}, ${_selectedWoreda ?? '-'} / Kebele ${_selectedKebele ?? '-'}'),
            ),
            if (_farmSizeController.text.isNotEmpty)
              ListTile(title: const Text('Farm Size'), subtitle: Text('${_farmSizeController.text} Hectares')),
            ListTile(title: const Text('Crops Selected'), subtitle: Text(cropNames.isEmpty ? 'None selected' : cropNames)),
          ],
        );
    }
  }
}
