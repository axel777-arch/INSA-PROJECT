import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/crop_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';
import '../../../../services/farmer_service.dart';

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

  Future<void> _submitDraft() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);
    try {
      final created = await _contentService.createAdvisory(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        language: _selectedLanguage,
        cropId: _selectedCrop?.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Advisory saved as Draft (id: ${created.id.substring(0, 8)}…)'),
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
        SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppColors.error),
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
        appBar: AppBar(title: const Text('New Advisory Draft')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.p16),
            children: [
              AppTextField(
                label: 'Advisory Title *',
                controller: _titleController,
                prefixIcon: Icons.title_rounded,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: AppSizes.p16),
              AppTextField(
                label: 'Content Body *',
                controller: _bodyController,
                prefixIcon: Icons.description_outlined,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Content body is required' : null,
              ),
              const SizedBox(height: AppSizes.p16),
              DropdownButtonFormField<String>(
                initialValue: _selectedLanguage,
                decoration: const InputDecoration(
                  labelText: 'Language *',
                  prefixIcon: Icon(Icons.language_rounded),
                ),
                items: _languages
                    .map((l) => DropdownMenuItem(
                          value: l,
                          child: Text(_languageLabels[l] ?? l),
                        ))
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
                      decoration: const InputDecoration(
                        labelText: 'Target Crop (optional)',
                        prefixIcon: Icon(Icons.eco_outlined),
                      ),
                      items: [
                        const DropdownMenuItem<CropModel?>(
                          value: null,
                          child: Text('All Crops / General'),
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
              const SizedBox(height: AppSizes.p24),
              AppButton(
                label: 'Save as Draft',
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
