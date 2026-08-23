import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/api_client.dart';
import '../../../../models/crop_model.dart';
import '../../../../services/farmer_service.dart';

class CropRecordingScreen extends StatefulWidget {
  const CropRecordingScreen({super.key});

  @override
  State<CropRecordingScreen> createState() => _CropRecordingScreenState();
}

class _CropRecordingScreenState extends State<CropRecordingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plantingDateController = TextEditingController(text: '12/10/2023');
  final _areaController = TextEditingController(text: '4.5');
  String _selectedCrop = 'Wheat';
  List<CropModel> _availableCrops = [];
  bool _loadingCrops = true;
  String _selectedStage = 'Vegetative';
  bool _isSaving = false;
  final String _idempotencyKey = 'crop-record-${DateTime.now().microsecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    try {
      final crops = await FarmerService(apiClient: ApiClient()).getCrops();
      if (!mounted) return;
      final uniqueCrops = <String, CropModel>{
        for (final crop in crops)
          if (crop.name.trim().isNotEmpty) crop.name: crop,
      }.values.toList();
      setState(() {
        _availableCrops = uniqueCrops;
        if (uniqueCrops.isNotEmpty) _selectedCrop = uniqueCrops.first.name;
        _loadingCrops = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingCrops = false);
    }
  }

  @override
  void dispose() {
    _plantingDateController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  String? _validatePlantingDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Planting date is required.';
    final datePattern = RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$');
    if (!datePattern.hasMatch(value.trim())) return 'Use MM/DD/YYYY format.';
    return null;
  }

  String? _validateArea(String? value) {
    if (value == null || value.trim().isEmpty) return 'Planted area is required.';
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid number.';
    if (parsed <= 0) return 'Area must be greater than 0.';
    return null;
  }

  Future<void> _saveRecord() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await ApiClient().post('/field/crop-records', {
        'crop': _selectedCrop,
        'plantingDate': _plantingDateController.text.trim(),
        'areaHectares': double.parse(_areaController.text.trim()),
        'growthStage': _selectedStage,
        'idempotencyKey': _idempotencyKey,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Crop performance record saved.')));
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      appBar: AppBar(title: const Text('Crop Recording')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Log details for the current growing season to track field performance.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSizes.p24),

              DropdownButtonFormField<String>(
                initialValue: _loadingCrops || _availableCrops.isEmpty
                    ? null
                    : _availableCrops.any((crop) => crop.name == _selectedCrop)
                        ? _selectedCrop
                        : null,
                decoration: const InputDecoration(
                  labelText: 'Crop Type *',
                  prefixIcon: Icon(Icons.eco_outlined),
                ),
                items: (_loadingCrops || _availableCrops.isEmpty
                        ? [CropModel(id: '', name: 'No crops available', description: '', active: false)]
                        : _availableCrops)
                    .map((crop) => DropdownMenuItem(value: crop.name, child: Text(crop.name)))
                    .toList(),
                onChanged: _loadingCrops ? null : (val) {
                  if (val != null) setState(() => _selectedCrop = val);
                },
              ),
              const SizedBox(height: AppSizes.p16),

              AppTextField(
                label: 'Planting Date * (MM/DD/YYYY)',
                controller: _plantingDateController,
                prefixIcon: Icons.calendar_today_outlined,
                validator: _validatePlantingDate,
              ),
              const SizedBox(height: AppSizes.p16),

              AppTextField(
                label: 'Planted Area (Hectares) *',
                controller: _areaController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.square_foot_rounded,
                validator: _validateArea,
              ),
              const SizedBox(height: AppSizes.p16),

              DropdownButtonFormField<String>(
                initialValue: _selectedStage,
                decoration: const InputDecoration(
                  labelText: 'Current Growth Stage *',
                  prefixIcon: Icon(Icons.show_chart_rounded),
                ),
                items: ['Germination', 'Vegetative', 'Flowering', 'Harvesting'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStage = val);
                },
              ),
              const SizedBox(height: AppSizes.p32),

              AppButton(
                label: 'Save Record',
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _saveRecord,
              ),
              const SizedBox(height: AppSizes.p12),
              AppButton.outlined(
                label: 'Cancel',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    ));
  }
}