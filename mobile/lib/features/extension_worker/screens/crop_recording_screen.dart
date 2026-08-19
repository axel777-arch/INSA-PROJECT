import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

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
  String _selectedStage = 'Vegetative';

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

  void _saveRecord() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crop performance record logged!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
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
                initialValue: _selectedCrop,
                decoration: const InputDecoration(
                  labelText: 'Crop Type *',
                  prefixIcon: Icon(Icons.eco_outlined),
                ),
                items: ['Wheat', 'Maize', 'Soybeans', 'Teff'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
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
                onPressed: _saveRecord,
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
    );
  }
}