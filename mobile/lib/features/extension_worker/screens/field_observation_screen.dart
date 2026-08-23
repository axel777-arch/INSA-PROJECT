import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../services/api_client.dart';

class FieldObservationScreen extends StatefulWidget {
  const FieldObservationScreen({super.key});

  @override
  State<FieldObservationScreen> createState() => _FieldObservationScreenState();
}

class _FieldObservationScreenState extends State<FieldObservationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _observationFormKey = GlobalKey<FormState>();
  final _escalationFormKey = GlobalKey<FormState>();

  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  final _questionsController = TextEditingController();
  String _selectedCategory = 'Pest';
  String _selectedCrop = 'Wheat';
  bool _isSubmitting = false;
  final ImagePicker _imagePicker = ImagePicker();
  final List<Uint8List> _photoBytes = [];
  final List<String> _photoNames = [];
  String _idempotencyKey = 'observation-${DateTime.now().microsecondsSinceEpoch}';

  List<Map<String, dynamic>> _observations = [];
  bool _isLoadingHistory = false;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    _questionsController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });
    try {
      final response = await ApiClient().get('/field/observations');
      if (mounted) {
        setState(() {
          _observations = (response as List)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _historyError = e.toString();
          _isLoadingHistory = false;
        });
      }
    }
  }

  String? _validateNotes(String? value) {
    if (value == null || value.trim().isEmpty) return 'Field notes are required.';
    return null;
  }

  String? _validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) return 'Location is required to escalate.';
    return null;
  }

  void _saveDraft() {
    if (!(_observationFormKey.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Observation saved as draft.')),
    );
  }

  Future<void> _submitEscalation() async {
    final observationValid = _observationFormKey.currentState?.validate() ?? false;
    final escalationValid = _escalationFormKey.currentState?.validate() ?? false;
    if (!observationValid || !escalationValid) return;
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await ApiClient().post('/field/observations', {
        'category': _selectedCategory,
        'crop': _selectedCrop,
        'notes': _notesController.text.trim(),
        'location': _locationController.text.trim(),
        'questions': _questionsController.text.trim(),
        'photoData': _photoBytes.map(base64Encode).toList(),
        'idempotencyKey': _idempotencyKey,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Observation submitted to an expert.')),
      );
      // Reset form fields
      _notesController.clear();
      _locationController.clear();
      _questionsController.clear();
      setState(() {
        _photoBytes.clear();
        _photoNames.clear();
        _selectedCategory = 'Pest';
        _selectedCrop = 'Wheat';
        _idempotencyKey = 'observation-${DateTime.now().microsecondsSinceEpoch}';
      });
      // Refresh history and switch to history tab
      _loadHistory();
      _tabController.animateTo(0);
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final photo = await _imagePicker.pickImage(
      source: source,
      imageQuality: 65,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      if (mounted) {
        setState(() {
          _photoBytes.add(bytes);
          _photoNames.add(photo.name);
        });
      }
    }
  }

  void _showObservationDetailsDialog(Map<String, dynamic> obs) {
    final theme = Theme.of(context);
    final isResolved = obs['status'] == 'RESOLVED';
    final photoStrings = List<String>.from(obs['photoData'] ?? obs['photo_data'] ?? []);
    final dateStr = obs['createdAt'] ?? obs['created_at'] ?? 'Recently';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(AppSizes.p20, AppSizes.p20, AppSizes.p20, 0),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Observation Details',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (isResolved ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                obs['status'] ?? 'SUBMITTED',
                style: TextStyle(
                  color: isResolved ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Submitted on: $dateStr',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const Divider(height: AppSizes.p16),
                _buildDetailRow('Crop Type', obs['crop'] ?? 'Unknown'),
                _buildDetailRow('Category', obs['category'] ?? 'Unknown'),
                _buildDetailRow('Location', obs['location'] ?? 'Unknown'),
                if (obs['questions'] != null && obs['questions'].toString().isNotEmpty)
                  _buildDetailRow('Questions', obs['questions']),
                const SizedBox(height: AppSizes.p12),
                const Text('Field Notes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(obs['notes'] ?? 'No notes provided.', style: theme.textTheme.bodyMedium),
                if (photoStrings.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.p16),
                  const Text('Field Imagery:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: AppSizes.p8),
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: photoStrings.length,
                      separatorBuilder: (context, index) => const SizedBox(width: AppSizes.p8),
                      itemBuilder: (context, idx) {
                        try {
                          final bytes = base64Decode(photoStrings[idx]);
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(bytes, width: 96, height: 96, fit: BoxFit.cover),
                          );
                        } catch (e) {
                          return Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                          );
                        }
                      },
                    ),
                  ),
                ],
                const SizedBox(height: AppSizes.p16),
                const Divider(),
                const SizedBox(height: AppSizes.p8),
                Text(
                  'Expert Response Panel',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppSizes.p8),
                if (isResolved) ...[
                  _buildDetailRow('Diagnosis', obs['diagnosis'] ?? 'No diagnosis.'),
                  _buildDetailRow('Recommendation', obs['recommendation'] ?? 'No recommendation.'),
                  if (obs['respondedAt'] != null)
                    _buildDetailRow('Responded At', obs['respondedAt']),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(AppSizes.p12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.hourglass_empty_rounded, color: theme.colorScheme.secondary),
                        const SizedBox(width: AppSizes.p12),
                        const Expanded(
                          child: Text(
                            'Pending expert review. Please pull to refresh the history list later to check for updates.',
                            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 13),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Field Observations & Cases'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.history), text: 'My Observations'),
              Tab(icon: Icon(Icons.add_photo_alternate_outlined), text: 'Log New'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: History of observations
            _isLoadingHistory
                ? const LoadingWidget(message: 'Loading logged observations...')
                : _historyError != null
                    ? AppErrorWidget(
                        message: _historyError!,
                        onRetry: _loadHistory,
                      )
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        child: _observations.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.6,
                                    child: EmptyState(
                                      title: 'No Observations Logged',
                                      message: 'You have not submitted any field observations yet. Tap the "Log New" tab to submit your first case.',
                                      icon: Icons.travel_explore_outlined,
                                      actionLabel: 'Log New Observation',
                                      onActionPressed: () => _tabController.animateTo(1),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(AppSizes.p16),
                                itemCount: _observations.length,
                                itemBuilder: (context, index) {
                                  final obs = _observations[index];
                                  final isResolved = obs['status'] == 'RESOLVED';
                                  final dateStr = obs['createdAt'] ?? obs['created_at'] ?? 'Recently';
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: AppSizes.p12),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () => _showObservationDetailsDialog(obs),
                                      child: Padding(
                                        padding: const EdgeInsets.all(AppSizes.p16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '${obs['crop'] ?? 'Unknown Crop'} (${obs['category'] ?? 'Observation'})',
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: (isResolved ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    obs['status'] ?? 'SUBMITTED',
                                                    style: TextStyle(
                                                      color: isResolved ? AppColors.success : AppColors.warning,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: AppSizes.p8),
                                            Text(
                                              'Location: ${obs['location'] ?? 'Unknown Location'}',
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                            const SizedBox(height: AppSizes.p4),
                                            Text(
                                              obs['notes'] ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                                            ),
                                            const SizedBox(height: AppSizes.p8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Logged: $dateStr',
                                                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, color: Colors.grey),
                                                ),
                                                const Text(
                                                  'View Details →',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

            // Tab 2: Create new observation form
            SingleChildScrollView(
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
                  Form(
                    key: _observationFormKey,
                    child: Card(
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
                              validator: _validateNotes,
                            ),
                            const SizedBox(height: AppSizes.p16),
                            // Capture image button
                            OutlinedButton.icon(
                              icon: const Icon(Icons.camera_alt_outlined),
                              label: Text(_photoBytes.isEmpty ? 'Capture or Upload Photo' : 'Add Another Photo (${_photoBytes.length})'),
                              onPressed: _pickPhoto,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                              ),
                            ),
                            if (_photoBytes.isNotEmpty) ...[
                              const SizedBox(height: AppSizes.p12),
                              SizedBox(
                                height: 96,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _photoBytes.length,
                                  separatorBuilder: (context, index) => const SizedBox(width: AppSizes.p8),
                                  itemBuilder: (context, index) => SizedBox(
                                    width: 96,
                                    height: 96,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.memory(_photoBytes[index], fit: BoxFit.cover),
                                        ),
                                        Positioned(
                                          top: 2,
                                          right: 2,
                                          child: IconButton(
                                            icon: const Icon(Icons.close, color: Colors.white),
                                            style: IconButton.styleFrom(backgroundColor: Colors.black54),
                                            onPressed: () => setState(() {
                                              _photoBytes.removeAt(index);
                                              _photoNames.removeAt(index);
                                            }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p16),

                  // Escalate to Expert Card
                  Form(
                    key: _escalationFormKey,
                    child: Card(
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
                              validator: _validateLocation,
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
                                    onPressed: _saveDraft,
                                  ),
                                ),
                                const SizedBox(width: AppSizes.p12),
                                Expanded(
                                  child: AppButton(
                                    label: 'Submit to Expert',
                                    isLoading: _isSubmitting,
                                    onPressed: _isSubmitting ? null : _submitEscalation,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}