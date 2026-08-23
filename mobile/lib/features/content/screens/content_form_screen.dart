import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';

class ContentFormScreen extends StatefulWidget {
  const ContentFormScreen({super.key});

  @override
  State<ContentFormScreen> createState() => _ContentFormScreenState();
}

class _ContentFormScreenState extends State<ContentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _languageController = TextEditingController(text: 'en');
  final _locationController = TextEditingController();
  final ContentService _contentService = ContentService(apiClient: ApiClient());
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _languageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitDraft() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final content = await _contentService.createAdvisory({
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'language': _languageController.text.trim(),
        'location': _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      });
      if (content == null) throw Exception('Content was not created.');
      await _contentService.submitForReview(content.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Advisory submitted for review.')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not submit advisory: $error')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      appBar: AppBar(title: const Text('New Advisory Draft')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.p16),
          children: [
            AppTextField(
              label: 'Advisory Title',
              controller: _titleController,
              prefixIcon: Icons.title_rounded,
              validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'Content Body',
              controller: _bodyController,
              prefixIcon: Icons.description_outlined,
              validator: (val) => val == null || val.isEmpty ? 'Content is required' : null,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'Language',
              controller: _languageController,
              prefixIcon: Icons.language_rounded,
              validator: (val) => val == null || val.trim().isEmpty ? 'Language is required' : null,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'Location (optional)',
              controller: _locationController,
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: AppSizes.p24),
            AppButton(
              label: _isSubmitting ? 'Submitting...' : 'Submit Advisory',
              isLoading: _isSubmitting,
              onPressed: _submitDraft,
            ),
          ],
        ),
      ),
    ));
  }
}
