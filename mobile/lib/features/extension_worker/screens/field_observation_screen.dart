import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class FieldObservationScreen extends StatefulWidget {
  const FieldObservationScreen({super.key});

  @override
  State<FieldObservationScreen> createState() => _FieldObservationScreenState();
}

class _FieldObservationScreenState extends State<FieldObservationScreen> {
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  final _questionsController = TextEditingController();
  String _selectedCategory = 'Pest';
  String _selectedCrop = 'Wheat';

  @override
  void dispose() {
    _notesController.dispose();
    _locationController.dispose();
    _questionsController.dispose();
    super.dispose();
  }

  void _submitEscalation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Observation Escalated to Expert!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Field Observation & Escalation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Record anomalies and escalate potential issues to agronomy experts directly from the field.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSizes.p16),

            // New Observation Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'New Observation',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSizes.p12),
                    // Category Chips
                    Text('Observation Category', style: theme.textTheme.bodySmall),
                    const SizedBox(height: AppSizes.p8),
                    Wrap(
                      spacing: AppSizes.p8,
                      children: ['Pest', 'Disease', 'Weed', 'Environment'].map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSizes.p16),
                    AppTextField(
                      label: 'Field Notes',
                      controller: _notesController,
                      prefixIcon: Icons.edit_note_rounded,
                    ),
                    const SizedBox(height: AppSizes.p16),
                    // Capture image button
                    OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Capture or Upload Photo'),
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            // Escalate to Expert Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Escalate to Expert',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCrop,
                      decoration: const InputDecoration(labelText: 'Affected Crop / Field'),
                      items: ['Wheat', 'Soybeans', 'Maize'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCrop = val);
                      },
                    ),
                    const SizedBox(height: AppSizes.p16),
                    AppTextField(
                      label: 'Precise Location (Coordinates or description)',
                      controller: _locationController,
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: AppSizes.p16),
                    AppTextField(
                      label: 'Specific Questions / Concerns for Expert',
                      controller: _questionsController,
                      prefixIcon: Icons.question_answer_outlined,
                    ),
                    const SizedBox(height: AppSizes.p20),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton.outlined(
                            label: 'Save Draft',
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: AppSizes.p12),
                        Expanded(
                          child: AppButton(
                            label: 'Submit to Expert',
                            onPressed: _submitEscalation,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
