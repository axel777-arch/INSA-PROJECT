import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/farmer_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/farmer_service.dart';
import '../../../../services/observation_service.dart';

class ScheduleFollowUpScreen extends StatefulWidget {
  final String? initialFarmerId;
  final String? initialFarmerName;
  final String? initialObservationId;

  const ScheduleFollowUpScreen({
    super.key,
    this.initialFarmerId,
    this.initialFarmerName,
    this.initialObservationId,
  });

  @override
  State<ScheduleFollowUpScreen> createState() => _ScheduleFollowUpScreenState();
}

class _ScheduleFollowUpScreenState extends State<ScheduleFollowUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _observationService = ObservationService(apiClient: ApiClient());
  final _farmerService = FarmerService(apiClient: ApiClient());

  List<FarmerModel> _farmers = [];
  String? _selectedFarmerId;
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoadingFarmers = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedFarmerId = widget.initialFarmerId;
    _loadFarmers();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadFarmers() async {
    try {
      final list = await _farmerService.getFarmers();
      if (mounted) {
        setState(() {
          _farmers = list;
          if (_selectedFarmerId == null && _farmers.isNotEmpty) {
            _selectedFarmerId = _farmers.first.id;
          }
          _isLoadingFarmers = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingFarmers = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _scheduledDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedFarmerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a farmer for this follow-up visit.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _observationService.scheduleFollowUp(
        farmerId: _selectedFarmerId!,
        observationId: widget.initialObservationId,
        scheduledDate: _scheduledDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Follow-up visit scheduled successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to schedule follow-up: $e'),
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
    final formattedDate =
        '${_scheduledDate.year}-${_scheduledDate.month.toString().padLeft(2, '0')}-${_scheduledDate.day.toString().padLeft(2, '0')}';

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Schedule Follow-Up Visit')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Follow-Up Visit Details',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.p4),
                Text(
                  'Schedule an on-site visit or follow-up check for a registered farmer.',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSizes.p24),

                // Farmer Selection
                if (widget.initialFarmerName != null) ...[
                  Text('Farmer', style: theme.textTheme.labelMedium),
                  const SizedBox(height: AppSizes.p8),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.p16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(AppSizes.r12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 20),
                        const SizedBox(width: AppSizes.p8),
                        Text(widget.initialFarmerName!, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.p16),
                ] else if (_isLoadingFarmers) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: AppSizes.p16),
                ] else ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedFarmerId,
                    decoration: const InputDecoration(
                      labelText: 'Select Farmer *',
                      prefixIcon: Icon(Icons.person_search_outlined),
                    ),
                    items: _farmers.map((f) {
                      final locationLabel = f.woreda.isNotEmpty ? f.woreda : f.region;
                      return DropdownMenuItem(
                        value: f.id,
                        child: Text('${f.fullName} ($locationLabel)'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedFarmerId = val);
                    },
                  ),
                  const SizedBox(height: AppSizes.p16),
                ],

                // Scheduled Date
                InkWell(
                  onTap: _isSubmitting ? null : _selectDate,
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Scheduled Date *',
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(formattedDate, style: theme.textTheme.bodyMedium),
                  ),
                ),
                const SizedBox(height: AppSizes.p16),

                // Visit Notes
                AppTextField(
                  controller: _notesController,
                  label: 'Visit Objectives / Notes',
                  hintText: 'e.g. Inspect response to Teff fertilization and check armyworm traps',
                  maxLines: 4,
                ),
                const SizedBox(height: AppSizes.p24),

                // Submit Button
                AppButton(
                  label: _isSubmitting ? 'Scheduling Visit...' : 'Confirm Schedule',
                  onPressed: _isSubmitting ? null : _submit,
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
