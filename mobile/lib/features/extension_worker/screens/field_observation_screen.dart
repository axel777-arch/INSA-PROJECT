import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_sizes.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/app_button.dart';
import 'package:mobile/core/widgets/app_text_field.dart';
import 'package:mobile/core/widgets/role_app_bar_actions.dart';
import 'package:mobile/core/widgets/screen_backdrop.dart';
import 'package:mobile/models/crop_model.dart';
import 'package:mobile/models/farmer_model.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/services/farmer_service.dart';
import 'package:mobile/services/observation_service.dart';

import 'package:mobile/core/localization/app_localizations.dart';

class FieldObservationScreen extends StatefulWidget {
  final String? initialFarmerId;

  const FieldObservationScreen({super.key, this.initialFarmerId});

  @override
  State<FieldObservationScreen> createState() => _FieldObservationScreenState();
}

class _FieldObservationScreenState extends State<FieldObservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _observationService = ObservationService(apiClient: ApiClient());
  final _farmerService = FarmerService(apiClient: ApiClient());

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _actionTakenController = TextEditingController();

  String _selectedType = 'GENERAL_CHECKUP';
  String _selectedSeverity = 'LOW';
  String? _selectedFarmerId;
  String? _selectedCropId;

  List<FarmerModel> _farmers = [];
  List<CropModel> _crops = [];
  bool _loadingMetadata = true;
  bool _isSubmitting = false;
  final List<String> _attachedFiles = [];

  final Map<String, String> _typeLabels = {
    'GENERAL_CHECKUP': 'General Checkup',
    'PEST_INFESTATION': 'Pest Infestation',
    'DISEASE': 'Disease Outbreak',
    'WEATHER_DAMAGE': 'Weather Damage',
    'SOIL_ISSUE': 'Soil / Nutrient Issue',
  };

  final Map<String, String> _severityLabels = {
    'LOW': 'Low - Routine Check',
    'MEDIUM': 'Medium - Monitor Closely',
    'HIGH': 'High - Action Needed',
    'CRITICAL': 'Critical - Immediate Threat',
  };

  @override
  void initState() {
    super.initState();
    _selectedFarmerId = widget.initialFarmerId;
    _loadMetadata();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _actionTakenController.dispose();
    super.dispose();
  }

  Future<void> _loadMetadata() async {
    setState(() => _loadingMetadata = true);
    try {
      final results = await Future.wait([
        _farmerService.getFarmers(),
        _farmerService.getCrops(),
      ]);
      if (mounted) {
        setState(() {
          _farmers = results[0] as List<FarmerModel>;
          _crops = results[1] as List<CropModel>;
          if (_selectedFarmerId == null && _farmers.isNotEmpty) {
            _selectedFarmerId = _farmers.first.id;
          }
          if (_crops.isNotEmpty) {
            _selectedCropId = _crops.first.id;
          }
        });
      }
    } catch (e) {
      debugPrint('[FieldObservationScreen] Error loading metadata: $e');
    } finally {
      if (mounted) setState(() => _loadingMetadata = false);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _attachedFiles.addAll(result.files.map((f) => f.name));
      });
    }
  }

  Future<void> _submitObservation({bool escalate = false}) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedFarmerId == null) {
      if (!mounted) return;
      messenger?.showSnackBar(
        SnackBar(content: Text(appText('Please select an assigned farmer.'))),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    var desc = _descriptionController.text.trim();
    if (_attachedFiles.isNotEmpty) {
      desc += '\n\n[Attachments: ${_attachedFiles.join(", ")}]';
    }

    try {
      final obs = await _observationService.createObservation(
        farmerId: _selectedFarmerId!,
        cropId: _selectedCropId,
        observationType: _selectedType,
        severity: _selectedSeverity,
        title: _titleController.text.trim(),
        description: desc,
        actionTaken: _actionTakenController.text.trim().isNotEmpty
            ? _actionTakenController.text.trim()
            : null,
      );

      if (!mounted) return;
      if (escalate) {
        messenger?.showSnackBar(
          SnackBar(
            content: Text(
              'Observation "${obs.title}" recorded and flagged for escalation.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        messenger?.showSnackBar(
          SnackBar(
            content: Text('Observation "${obs.title}" recorded successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          content: Text('Failed to record observation: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(appText('Record Field Observation')),
          actions: buildRoleAppBarActions(context),
        ),
        body: _loadingMetadata
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        appText(
                          'Record technical field observations, crop health findings, and pest/disease issues.',
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSizes.p16),

                      // Farmer selection
                      if (_farmers.isNotEmpty)
                        DropdownButtonFormField<String>(
                          initialValue: _selectedFarmerId,
                          decoration: InputDecoration(
                            labelText: appText('Farmer *'),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          items: _farmers
                              .map(
                                (f) => DropdownMenuItem(
                                  value: f.id,
                                  child: Text('${f.fullName} (${f.woreda})'),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedFarmerId = val),
                        ),
                      const SizedBox(height: AppSizes.p16),

                      // Crop selection
                      if (_crops.isNotEmpty)
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCropId,
                          decoration: InputDecoration(
                            labelText: appText('Affected Crop'),
                            prefixIcon: const Icon(Icons.eco_outlined),
                          ),
                          items: _crops
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCropId = val),
                        ),
                      const SizedBox(height: AppSizes.p16),

                      // Observation Type
                      DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        decoration: InputDecoration(
                          labelText: appText('Observation Type *'),
                          prefixIcon: const Icon(Icons.category_outlined),
                        ),
                        items: _typeLabels.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedType = val);
                        },
                      ),
                      const SizedBox(height: AppSizes.p16),

                      // Severity Level
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSeverity,
                        decoration: InputDecoration(
                          labelText: appText('Severity Level *'),
                          prefixIcon: const Icon(Icons.warning_amber_rounded),
                        ),
                        items: _severityLabels.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedSeverity = val);
                          }
                        },
                      ),
                      const SizedBox(height: AppSizes.p16),

                      AppTextField(
                        label: appText('Observation Title *'),
                        controller: _titleController,
                        prefixIcon: Icons.title,
                        validator: (v) => (v == null || v.trim().length < 3)
                            ? appText('Title must be at least 3 characters.')
                            : null,
                      ),
                      const SizedBox(height: AppSizes.p16),

                      AppTextField(
                        label: appText('Detailed Description *'),
                        controller: _descriptionController,
                        prefixIcon: Icons.description_outlined,
                        maxLines: 4,
                        validator: (v) => (v == null || v.trim().length < 10)
                            ? appText(
                                'Description must be at least 10 characters.',
                              )
                            : null,
                      ),
                      const SizedBox(height: AppSizes.p16),

                      AppTextField(
                        label: appText('Immediate Action Taken / Advice Given'),
                        controller: _actionTakenController,
                        prefixIcon: Icons.healing_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSizes.p16),

                      // Attachments Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${appText("Field Attachments")} (${_attachedFiles.length})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          TextButton.icon(
                            onPressed: _pickFile,
                            icon: const Icon(Icons.attach_file_rounded, size: 16),
                            label: Text(appText('Attach File')),
                          ),
                        ],
                      ),
                      if (_attachedFiles.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.p8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: _attachedFiles.map((name) {
                            return Chip(
                              label: Text(name, style: const TextStyle(fontSize: 11)),
                              onDeleted: () => setState(() => _attachedFiles.remove(name)),
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: AppSizes.p24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => _submitObservation(escalate: false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: Text(appText('Save Record')),
                            ),
                          ),
                          const SizedBox(width: AppSizes.p12),
                          Expanded(
                            child: AppButton(
                              label: appText('Save & Escalate'),
                              isLoading: _isSubmitting,
                              onPressed: () =>
                                  _submitObservation(escalate: true),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
