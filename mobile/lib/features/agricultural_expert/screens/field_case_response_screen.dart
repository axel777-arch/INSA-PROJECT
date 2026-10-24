import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/api_client.dart';
import '../../../../services/notification_service.dart';

class FieldCaseResponseScreen extends StatefulWidget {
  final String? initialCaseId;

  const FieldCaseResponseScreen({super.key, this.initialCaseId});

  @override
  State<FieldCaseResponseScreen> createState() => _FieldCaseResponseScreenState();
}

class _FieldCaseResponseScreenState extends State<FieldCaseResponseScreen> {
  final ApiClient _apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _recommendationController = TextEditingController();
  final _notesController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _attachedPhotos = []; // { 'name': str, 'bytes': Uint8List, 'dataUrl': str }

  List<Map<String, dynamic>> _cases = [];
  Map<String, dynamic>? _selectedCase;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCases();
    });
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _recommendationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCases() async {
    setState(() => _isLoading = true);
    try {
      final routeArg = ModalRoute.of(context)?.settings.arguments;
      String? targetId = widget.initialCaseId;
      if (routeArg is String && routeArg.isNotEmpty) {
        targetId = routeArg;
      } else if (routeArg is Map && routeArg['id'] != null) {
        targetId = routeArg['id'].toString();
      }

      final response = await _apiClient.get('/cases');
      if (response is List) {
        final list = response.cast<Map<String, dynamic>>();
        setState(() {
          _cases = list;
          if (list.isNotEmpty) {
            if (targetId != null) {
              _selectedCase = list.firstWhere((c) => c['id'] == targetId, orElse: () => list.first);
            } else {
              // Prefer OPEN or IN_REVIEW case first
              _selectedCase = list.firstWhere(
                (c) => c['status'] == 'OPEN' || c['status'] == 'IN_REVIEW',
                orElse: () => list.first,
              );
            }
            _populateSelectedCase();
          }
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('[FieldCaseResponseScreen] _loadCases error: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _populateSelectedCase() {
    _attachedPhotos.clear();
    _diagnosisController.clear();
    _recommendationController.clear();
    _notesController.clear();

    if (_selectedCase != null && _selectedCase!['responses'] != null) {
      final resps = (_selectedCase!['responses'] as List).cast<Map<String, dynamic>>();
      if (resps.isNotEmpty) {
        final last = resps.last;
        _diagnosisController.text = last['diagnosis']?.toString() ?? '';
        _recommendationController.text = last['recommendation']?.toString() ?? '';
        _notesController.text = last['internalNotes']?.toString() ?? '';
      }
    }
  }

  Future<void> _showImageSourceSheet() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title: const Text('Live Camera Capture'),
              subtitle: const Text('Take high-resolution photo with device camera'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text('Choose from Photo Gallery'),
              subtitle: const Text('Pick existing image from media library'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;
    final source = choice == 'camera' ? ImageSource.camera : ImageSource.gallery;
    await _pickImageWithPreview(source);
  }

  Future<void> _pickImageWithPreview(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 80,
      );

      if (picked == null) return;
      final bytes = await picked.readAsBytes();

      if (!mounted) return;

      // In-app photo preview with "Retake" and "Confirm" controls
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(
                source == ImageSource.camera ? Icons.camera_alt_rounded : Icons.photo_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text('Review Photo'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  bytes,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'File: ${picked.name}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retake'),
              onPressed: () {
                Navigator.pop(ctx, false);
                _pickImageWithPreview(source);
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('Confirm Photo'),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _attachedPhotos.add({
            'name': picked.name,
            'bytes': bytes,
            'dataUrl': dataUrl,
          });
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture photo: $e')),
        );
      }
    }
  }

  void _removePhoto(int index) {
    setState(() => _attachedPhotos.removeAt(index));
  }

  Future<void> _submitResponse() async {
    if (_selectedCase == null) return;
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
    final caseId = _selectedCase!['id'];

    try {
      final payload = {
        'diagnosis': _diagnosisController.text.trim(),
        'recommendation': _recommendationController.text.trim(),
        'internalNotes': _notesController.text.trim(),
        'images': _attachedPhotos.isNotEmpty ? _attachedPhotos.map((p) => p['dataUrl']).join(';') : null,
      };

      await _apiClient.post('/cases/$caseId/responses', payload);

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        if (_selectedCase != null) {
          _selectedCase = {
            ..._selectedCase!,
            'status': 'RESOLVED',
          };
        }
        // Update case in master list
        final idx = _cases.indexWhere((c) => c['id'] == caseId);
        if (idx != -1) {
          _cases[idx] = {
            ..._cases[idx],
            'status': 'RESOLVED',
          };
        }
      });

      NotificationService.instance.fetchNotifications();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Diagnosis & Resolution successfully submitted! Case marked as RESOLVED.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting response: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isResolved = _selectedCase != null && _selectedCase!['status'] == 'RESOLVED';

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(_selectedCase != null ? 'Case #${_selectedCase!['id'].toString().substring(0, 8)}' : 'Field Case'),
          actions: [
            if (_cases.length > 1)
              PopupMenuButton<String>(
                icon: const Icon(Icons.swap_horiz_rounded),
                tooltip: 'Switch Field Case',
                onSelected: (caseId) {
                  setState(() {
                    _selectedCase = _cases.firstWhere((c) => c['id'] == caseId);
                    _populateSelectedCase();
                  });
                },
                itemBuilder: (ctx) => _cases.map((c) {
                  final title = c['title'] ?? 'Case ${c['id']}';
                  final status = c['status'] ?? 'OPEN';
                  return PopupMenuItem(
                    value: c['id'].toString(),
                    child: Row(
                      children: [
                        Icon(
                          status == 'RESOLVED' ? Icons.check_circle_outline : Icons.pending_actions_outlined,
                          size: 16,
                          color: status == 'RESOLVED' ? AppColors.success : AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _selectedCase == null
                ? const Center(child: Text('No field cases assigned.'))
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Status Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: (isResolved ? AppColors.success : AppColors.warning).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isResolved ? Icons.check_circle_rounded : Icons.pending_rounded,
                                      size: 14,
                                      color: isResolved ? AppColors.success : AppColors.warning,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isResolved ? 'Resolved & Addressed' : 'Active Escalation (${_selectedCase!['status']})',
                                      style: TextStyle(
                                        color: isResolved ? AppColors.success : AppColors.warning,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _selectedCase!['createdAt'] != null
                                    ? _selectedCase!['createdAt'].toString().substring(0, 10)
                                    : 'Recent',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.p12),

                          Text(
                            _selectedCase!['title'] ?? 'Agricultural Case',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: AppSizes.p8),

                          // Metadata cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard('Farmer', _selectedCase!['farmerName'] ?? 'Ethiopian Farmer'),
                              ),
                              const SizedBox(width: AppSizes.p8),
                              Expanded(
                                child: _buildInfoCard('Crop', _selectedCase!['cropName'] ?? 'Crop'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.p8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard('Location', _selectedCase!['location'] ?? 'Ethiopia'),
                              ),
                              if (_selectedCase!['farmerPhone'] != null) ...[
                                const SizedBox(width: AppSizes.p8),
                                Expanded(
                                  child: _buildInfoCard('Contact', _selectedCase!['farmerPhone'] ?? ''),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppSizes.p16),

                          // Description
                          const Text(
                            'Symptom Description & Field Observations',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(AppSizes.p12),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: Text(
                              _selectedCase!['description'] ?? 'No symptom description provided.',
                              style: const TextStyle(fontSize: 13, height: 1.4),
                            ),
                          ),
                          const SizedBox(height: AppSizes.p16),

                          // Media attachments
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
                                        'Field Imagery & Evidence (${_attachedPhotos.length})',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      if (!isResolved)
                                        TextButton.icon(
                                          onPressed: _showImageSourceSheet,
                                          icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                                          label: const Text('Add Photo'),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSizes.p8),
                                  SizedBox(
                                    height: 100,
                                    child: _attachedPhotos.isEmpty
                                        ? Center(
                                            child: Text(
                                              'No photos attached — tap Add Photo for camera/gallery.',
                                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                            ),
                                          )
                                        : ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: _attachedPhotos.length,
                                            separatorBuilder: (_, _) => const SizedBox(width: AppSizes.p8),
                                            itemBuilder: (context, index) {
                                              final photo = _attachedPhotos[index];
                                              final bytes = photo['bytes'] as Uint8List;
                                              return Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: Image.memory(
                                                      bytes,
                                                      width: 100,
                                                      height: 100,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  if (!isResolved)
                                                    Positioned(
                                                      top: 2,
                                                      right: 2,
                                                      child: GestureDetector(
                                                        onTap: () => _removePhoto(index),
                                                        child: Container(
                                                          decoration: const BoxDecoration(
                                                            color: Colors.black54,
                                                            shape: BoxShape.circle,
                                                          ),
                                                          padding: const EdgeInsets.all(3),
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
                          const Divider(height: AppSizes.p32),

                          // Expert Response Form
                          Text(
                            'Expert Response & Prescription',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: AppSizes.p12),

                          AppTextField(
                            label: 'Confirmed Diagnosis *',
                            controller: _diagnosisController,
                            prefixIcon: Icons.fact_check_outlined,
                            enabled: !isResolved,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Diagnosis is required.' : null,
                          ),
                          const SizedBox(height: AppSizes.p16),

                          AppTextField(
                            label: 'Agronomic Recommendation (Visible to Farmer & Worker) *',
                            controller: _recommendationController,
                            prefixIcon: Icons.recommend_outlined,
                            enabled: !isResolved,
                            maxLines: 3,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Recommendation is required.' : null,
                          ),
                          const SizedBox(height: AppSizes.p16),

                          AppTextField(
                            label: 'Internal Notes (Agronomy Advisory Board Only)',
                            controller: _notesController,
                            prefixIcon: Icons.lock_outline_rounded,
                            enabled: !isResolved,
                          ),
                          const SizedBox(height: AppSizes.p24),

                          if (!isResolved) ...[
                            AppButton(
                              label: 'Submit Resolution & Auto-Close Case',
                              icon: Icons.check_circle_outline_rounded,
                              isLoading: _isSubmitting,
                              onPressed: _isSubmitting ? null : _submitResponse,
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(AppSizes.p16),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.verified_rounded, color: AppColors.success),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'This case is officially resolved and archived in PostgreSQL. Farmers and extension workers can view this diagnosis.',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}