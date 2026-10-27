import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';

import 'package:mobile/core/localization/app_localizations.dart';

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
    if (value == null || value.trim().isEmpty) {
      return appText('Planting date is required.');
    }
    final datePattern = RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$');
    if (!datePattern.hasMatch(value.trim())) {
      return appText('Use MM/DD/YYYY format.');
    }
    return null;
  }

  String? _validateArea(String? value) {
    if (value == null || value.trim().isEmpty) {
      return appText('Planted area is required.');
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return appText('Enter a valid number.');
    if (parsed <= 0) return appText('Area must be greater than 0.');
    return null;
  }

  void _saveRecord() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(appText('Crop performance record logged!'))),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: Text(appText('Crop Recording'))),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  appText(
                    'Log details for the current growing season to track field performance.',
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSizes.p24),

                DropdownButtonFormField<String>(
                  initialValue: _selectedCrop,
                  decoration: InputDecoration(
                    labelText: appText('Crop Type *'),
                    prefixIcon: Icon(Icons.eco_outlined),
                  ),
                  items: ['Wheat', 'Maize', 'Soybeans', 'Teff']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCrop = val);
                  },
                ),
                const SizedBox(height: AppSizes.p16),

                AppTextField(
                  label: appText('Planting Date * (MM/DD/YYYY)'),
                  controller: _plantingDateController,
                  prefixIcon: Icons.calendar_today_outlined,
                  validator: _validatePlantingDate,
                ),
                const SizedBox(height: AppSizes.p16),

                AppTextField(
                  label: appText('Planted Area (Hectares) *'),
                  controller: _areaController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.square_foot_rounded,
                  validator: _validateArea,
                ),
                const SizedBox(height: AppSizes.p16),

                DropdownButtonFormField<String>(
                  initialValue: _selectedStage,
                  decoration: InputDecoration(
                    labelText: appText('Current Growth Stage *'),
                    prefixIcon: Icon(Icons.show_chart_rounded),
                  ),
                  items:
                      ['Germination', 'Vegetative', 'Flowering', 'Harvesting']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStage = val);
                  },
                ),
                const SizedBox(height: AppSizes.p32),

                AppButton(
                  label: appText('Save Record'),
                  onPressed: _saveRecord,
                ),
                const SizedBox(height: AppSizes.p12),
                AppButton.outlined(
                  label: appText('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
