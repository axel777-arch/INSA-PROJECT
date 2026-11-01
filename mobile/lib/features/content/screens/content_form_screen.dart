import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/role_app_bar_actions.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/crop_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';
import '../../../../services/farmer_service.dart';

import 'package:mobile/core/localization/app_localizations.dart';

class ContentFormScreen extends StatefulWidget {
  const ContentFormScreen({super.key});

  @override
  State<ContentFormScreen> createState() => _ContentFormScreenState();
}

class _ContentFormScreenState extends State<ContentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  final ContentService _contentService = ContentService(apiClient: ApiClient());
  final FarmerService _farmerService = FarmerService(apiClient: ApiClient());

  String _selectedLanguage = 'en';
  CropModel? _selectedCrop;
  List<CropModel> _crops = [];
  bool _loadingCrops = true;
  bool _isSubmitting = false;
  final List<String> _attachedFiles = [];

  static const List<String> _languages = ['en', 'am', 'om', 'ti'];
  static const Map<String, String> _languageLabels = {
    'en': 'English',
    'am': 'Amharic',
    'om': 'Afaan Oromoo',
    'ti': 'Tigrinya',
  };

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
        _crops = crops;
        _loadingCrops = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCrops = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
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

  Future<void> _submitDraft() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);

    var fullBody = _bodyController.text.trim();
    if (_attachedFiles.isNotEmpty) {
      fullBody += '\n\n[Attachments: ${_attachedFiles.join(", ")}]';
    }

    try {
      final created = await _contentService.createAdvisory(
        title: _titleController.text.trim(),
        body: fullBody,
        language: _selectedLanguage,
        cropId: _selectedCrop?.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Advisory saved as Draft (id: ${created.id.substring(0, 8)}…)',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(appText('New Advisory Draft')),
          actions: buildRoleAppBarActions(context),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.p16),
            children: [
              AppTextField(
                label: appText('Advisory Title *'),
                controller: _titleController,
                prefixIcon: Icons.title_rounded,
                validator: (val) => val == null || val.trim().isEmpty
                    ? appText('Title is required')
                    : null,
              ),
              const SizedBox(height: AppSizes.p16),
              AppTextField(
                label: appText('Content Body *'),
                controller: _bodyController,
                prefixIcon: Icons.description_outlined,
                validator: (val) => val == null || val.trim().isEmpty
                    ? appText('Content body is required')
                    : null,
              ),
              const SizedBox(height: AppSizes.p16),
              DropdownButtonFormField<String>(
                initialValue: _selectedLanguage,
                decoration: InputDecoration(
                  labelText: appText('Language *'),
                  prefixIcon: const Icon(Icons.language_rounded),
                ),
                items: _languages
                    .map(
                      (l) => DropdownMenuItem(
                        value: l,
                        child: Text(_languageLabels[l] ?? l),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLanguage = val);
                },
              ),
              const SizedBox(height: AppSizes.p16),
              _loadingCrops
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<CropModel?>(
                      initialValue: _selectedCrop,
                      decoration: InputDecoration(
                        labelText: appText('Target Crop (optional)'),
                        prefixIcon: const Icon(Icons.eco_outlined),
                      ),
                      items: [
                        DropdownMenuItem<CropModel?>(
                          value: null,
                          child: Text(appText('All Crops / General')),
                        ),
                        ..._crops.map(
                          (c) => DropdownMenuItem<CropModel?>(
                            value: c,
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedCrop = val),
                    ),
              const SizedBox(height: AppSizes.p16),

              // File attachments section
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
              AppButton(
                label: appText('Save as Draft'),
                icon: Icons.save_outlined,
                onPressed: _isSubmitting ? null : _submitDraft,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
