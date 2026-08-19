import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

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

  @override
  void dispose() {
    _diagnosisController.dispose();
    _recommendationController.dispose();
    _notesController.dispose();
    super.dispose();
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

    // Package the diagnostic response text the expert submits back to the
    // escalated field case. A CaseService/API wiring can replace this once
    // the backend endpoint for case responses is available.
    final response = {
      'diagnosis': _diagnosisController.text.trim(),
      'recommendation': _recommendationController.text.trim(),
      'internal_notes': _notesController.text.trim(),
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
    return Scaffold(
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

              // Imagery Carousel mock
              Card(
                child: Container(
                  height: 180,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 48, color: theme.primaryColor),
                      const SizedBox(height: AppSizes.p8),
                      const Text('Field Imagery Carousel (3 Images Loaded)', style: TextStyle(color: Colors.grey)),
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
    );
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
