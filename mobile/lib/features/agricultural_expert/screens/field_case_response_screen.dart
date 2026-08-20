import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class FieldCaseResponseScreen extends StatefulWidget {
  const FieldCaseResponseScreen({super.key});

  @override
  State<FieldCaseResponseScreen> createState() => _FieldCaseResponseScreenState();
}

class _FieldCaseResponseScreenState extends State<FieldCaseResponseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _recommendationController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;
  bool _isResolved = false;

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _caseImages = [];

  @override
  void dispose() {
    _diagnosisController.dispose();
    _recommendationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceSheet() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text('Browse files'),
              onTap: () => Navigator.pop(context, 'files'),
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;

    switch (choice) {
      case 'camera':
        final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
        if (picked != null) setState(() => _caseImages.add(picked));
        break;
      case 'gallery':
        final picked = await _picker.pickMultiImage(imageQuality: 80);
        if (picked.isNotEmpty) setState(() => _caseImages.addAll(picked));
        break;
      case 'files':
        await _browseFiles();
        break;
    }
  }

  Future<void> _browseFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'heic'],
      allowMultiple: true,
    );

    if (result == null) return;

    final picked = result.paths
        .whereType<String>()
        .map((path) => XFile(path))
        .toList();

    if (picked.isNotEmpty) setState(() => _caseImages.addAll(picked));
  }

  void _removeImage(int index) {
    setState(() => _caseImages.removeAt(index));
  }

  Future<void> _submitResponse() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the diagnosis and recommendation fields.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final response = {
      'diagnosis': _diagnosisController.text.trim(),
      'recommendation': _recommendationController.text.trim(),
      'internal_notes': _notesController.text.trim(),
      'image_count': _caseImages.length,
      'submitted_at': DateTime.now().toIso8601String(),
    };
    debugPrint('Field case response submitted: $response');

    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _isResolved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnosis Response Submitted successfully!'), backgroundColor: AppColors.success),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,

      appBar: AppBar(title: const Text('Case #8492-B')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Escalation Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (_isResolved ? AppColors.success : theme.colorScheme.error).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _isResolved ? 'Resolved' : 'Urgent Escalation',
                      style: TextStyle(
                        color: _isResolved ? AppColors.success : theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  const Text('Today, 09:14 AM'),
                ],
              ),
              const SizedBox(height: AppSizes.p12),
              Text(
                'Escalated by: Sarah Jenkins, Extension Worker Level 2',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Divider(height: AppSizes.p24),

              // Imagery upload
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Field Imagery (${_caseImages.length} loaded)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            onPressed: _isResolved ? null : _showImageSourceSheet,
                            icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                            label: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.p8),
                      SizedBox(
                        height: 100,
                        child: _caseImages.isEmpty
                            ? Center(
                                child: Text(
                                  'No images yet — tap Add to attach field photos.',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              )
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _caseImages.length,
                                separatorBuilder: (_, __) => const SizedBox(width: AppSizes.p8),
                                itemBuilder: (context, index) {
                                  final file = _caseImages[index];
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(file.path),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      if (!_isResolved)
                                        Positioned(
                                          top: 2,
                                          right: 2,
                                          child: GestureDetector(
                                            onTap: () => _removeImage(index),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(2),
                                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p16),

              // Crop details
              Row(
                children: [
                  Expanded(child: _buildInfoCard('Crop Type', 'Maize (Zea mays)')),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(child: _buildInfoCard('Location', 'Sector 4B, North Ridge')),
                ],
              ),
              const SizedBox(height: AppSizes.p16),

              // Issue description
              const Text(
                'Issue Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Rapid onset of leaf streaking observed over the last 48 hours. Lesions are elongating quickly, starting from lower leaves and moving upward. Humidity has been unusually high (85% RH) with overnight temperatures remaining above 20°C.',
              ),
              const Divider(height: AppSizes.p32),

              // Diagnosis Form
              Text(
                'Expert Response Panel',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
              ),
              const SizedBox(height: AppSizes.p12),
              AppTextField(
                label: 'Confirmed Diagnosis *',
                controller: _diagnosisController,
                prefixIcon: Icons.fact_check_outlined,
                enabled: !_isResolved,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Diagnosis is required.' : null,
              ),
              const SizedBox(height: AppSizes.p16),
              AppTextField(
                label: 'Primary Recommendation (Visible to Worker) *',
                controller: _recommendationController,
                prefixIcon: Icons.recommend_outlined,
                enabled: !_isResolved,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Recommendation is required.' : null,
              ),
              const SizedBox(height: AppSizes.p16),
              AppTextField(
                label: 'Internal Notes (Experts Only)',
                controller: _notesController,
                prefixIcon: Icons.lock_outline_rounded,
                enabled: !_isResolved,
              ),
              const SizedBox(height: AppSizes.p24),

              AppButton(
                label: _isResolved ? 'Response Submitted' : 'Submit Response',
                isLoading: _isSubmitting,
                onPressed: _isResolved || _isSubmitting ? null : _submitResponse,
              ),
              const SizedBox(height: AppSizes.p12),
              AppButton.outlined(
                label: 'Request More Info',
                onPressed: _isResolved
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request sent to the extension worker for more field detail.')),
                        );
                      },
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}