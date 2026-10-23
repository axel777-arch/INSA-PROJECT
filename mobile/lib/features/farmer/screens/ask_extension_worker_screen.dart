import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/config/user_session.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/farmer_case_model.dart';
import '../../../../services/farmer_case_service.dart';

class AskExtensionWorkerScreen extends StatefulWidget {
  final int initialTabIndex;

  const AskExtensionWorkerScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AskExtensionWorkerScreen> createState() =>
      _AskExtensionWorkerScreenState();
}

class _AskExtensionWorkerScreenState extends State<AskExtensionWorkerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedCrop = 'Teff';
  final List<String> _crops = [
    'Teff',
    'Wheat',
    'Maize',
    'Coffee',
    'Barley',
    'Beans',
    'Sorghum',
    'Other Crop',
  ];

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _attachments = [];

  final FarmerCaseService _caseService = FarmerCaseService();
  List<FarmerCaseModel> _myCases = [];
  bool _isLoadingCases = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _loadUserContext();
    _loadCases();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserContext() async {
    final user = await UserSession.get();
    if (user != null && mounted) {
      if (_locationController.text.isEmpty) {
        _locationController.text = 'Oromia / East Shewa / Adama';
      }
    }
  }

  Future<void> _loadCases() async {
    setState(() => _isLoadingCases = true);
    final list = await _caseService.getCases();
    if (!mounted) return;
    setState(() {
      _myCases = list;
      _isLoadingCases = false;
    });
  }

  Future<void> _pickAttachmentSource() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo of field/crop issue'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose photo from gallery'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file_rounded),
              title: const Text('Attach PDF or Document'),
              onTap: () => Navigator.pop(context, 'document'),
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;

    if (choice == 'camera') {
      final img = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (img != null) {
        _addValidatedAttachment(img);
      }
    } else if (choice == 'gallery') {
      final list = await _picker.pickMultiImage(imageQuality: 80);
      for (final img in list) {
        _addValidatedAttachment(img);
      }
    } else if (choice == 'document') {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        allowMultiple: true,
      );
      if (res != null) {
        for (final f in res.files) {
          if (f.bytes != null) {
            _addValidatedAttachment(XFile.fromData(f.bytes!, name: f.name));
          } else if (f.path != null && f.path!.isNotEmpty) {
            _addValidatedAttachment(XFile(f.path!));
          }
        }
      }
    }
  }

  void _addValidatedAttachment(XFile file) {
    final ext = file.name.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'pdf'].contains(ext)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid format: .$ext. Allowed: JPG, PNG, PDF'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _attachments.add(file));
  }

  Future<void> _submitCase() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final user = await UserSession.get();

    try {
      final created = await _caseService.submitCase(
        farmerId: user?.id ?? 'farmer-demo',
        farmerName: user?.fullName ?? 'Abebe Bikila',
        farmerPhone: user?.phone ?? '+251911223344',
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        cropName: _selectedCrop,
        location: _locationController.text.trim(),
        attachmentPaths: _attachments.map((a) => a.name).toList(),
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _attachments.clear();
        _subjectController.clear();
        _descriptionController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Question #${created.id} submitted to Extension Worker!'),
          backgroundColor: AppColors.success,
        ),
      );

      await _loadCases();
      _tabController.animateTo(1); // Switch to tracking tab
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.current;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(loc.askExtensionWorker),
          bottom: TabBar(
            controller: _tabController,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: theme.primaryColor,
            tabs: const [
              Tab(icon: Icon(Icons.edit_note_rounded), text: 'New Question'),
              Tab(icon: Icon(Icons.track_changes_rounded), text: 'Track Cases'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSubmissionTab(theme, loc),
            _buildTrackingTab(theme, loc),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionTab(ThemeData theme, AppLocalizations loc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.p16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              color: theme.primaryColor.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p12),
                child: Row(
                  children: [
                    Icon(Icons.support_agent_rounded, color: theme.primaryColor, size: 28),
                    const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: Text(
                        loc.askWorkerDesc,
                        style: TextStyle(fontSize: 12, color: theme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            // Crop selector
            Text(loc.commodity, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedCrop,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.eco_outlined),
              ),
              items: _crops.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCrop = val);
              },
            ),
            const SizedBox(height: AppSizes.p16),

            // Subject
            AppTextField(
              label: 'Subject / Observed Problem *',
              hintText: 'e.g., Yellow spots spreading on maize leaves',
              controller: _subjectController,
              prefixIcon: Icons.title_rounded,
              validator: (v) => (v == null || v.trim().isEmpty) ? loc.fieldRequired : null,
            ),
            const SizedBox(height: AppSizes.p16),

            // Description
            AppTextField(
              label: 'Detailed Description *',
              hintText: 'Describe how long this has occurred, field conditions, and current soil moisture.',
              controller: _descriptionController,
              prefixIcon: Icons.description_outlined,
              maxLines: 4,
              validator: (v) => (v == null || v.trim().isEmpty) ? loc.fieldRequired : null,
            ),
            const SizedBox(height: AppSizes.p16),

            // Location
            AppTextField(
              label: 'Farm Location / Plot Name',
              controller: _locationController,
              prefixIcon: Icons.pin_drop_outlined,
            ),
            const SizedBox(height: AppSizes.p20),

            // Attachments
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
                          'Field Photos & Docs (${_attachments.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: _pickAttachmentSource,
                          icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                          label: const Text('Add File'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Allowed: JPG, PNG, PDF (Max 10MB per file)',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: AppSizes.p12),
                    if (_attachments.isEmpty)
                      Container(
                        height: 70,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'No attachments yet — photos help experts diagnose faster.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _attachments.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final file = entry.value;
                          final isPdf = file.name.toLowerCase().endsWith('.pdf');

                          return Chip(
                            avatar: Icon(
                              isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
                              size: 16,
                            ),
                            label: Text(
                              file.name.length > 20
                                  ? '${file.name.substring(0, 17)}...'
                                  : file.name,
                              style: const TextStyle(fontSize: 11),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () {
                              setState(() => _attachments.removeAt(idx));
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p24),

            AppButton(
              label: 'Submit Case to Extension Worker',
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submitCase,
            ),
            const SizedBox(height: AppSizes.p24),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTab(ThemeData theme, AppLocalizations loc) {
    if (_isLoadingCases) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myCases.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: theme.disabledColor),
              const SizedBox(height: AppSizes.p12),
              const Text('No submitted cases yet.'),
              const SizedBox(height: AppSizes.p8),
              const Text(
                'Use the "New Question" tab to submit your crop inquiry.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCases,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: _myCases.length,
        itemBuilder: (context, index) {
          final item = _myCases[index];
          final statusColor = _statusColor(item.status);

          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.p12),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSizes.r12),
              onTap: () => _showCaseDetail(item),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Case ID and Status Chip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Case #${item.id}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            loc.caseStatusLabel(item.status),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p8),

                    // Subject
                    Text(
                      item.subject,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Description snippet
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const Divider(height: AppSizes.p20),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.eco_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              item.cropName,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            if (item.attachmentPaths.isNotEmpty) ...[
                              const SizedBox(width: AppSizes.p12),
                              const Icon(Icons.attach_file, size: 14, color: Colors.grey),
                              Text(
                                '${item.attachmentPaths.length}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              item.responseNotes != null ? 'View Response' : 'View Details',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.chevron_right, size: 16, color: theme.primaryColor),
                          ],
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
    );
  }

  void _showCaseDetail(FarmerCaseModel item) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.current;
    final statusColor = _statusColor(item.status);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(AppSizes.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Case #${item.id}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          loc.caseStatusLabel(item.status),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p12),

                  Text(
                    item.subject,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Crop: ${item.cropName}  •  Location: ${item.location}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: AppSizes.p12),

                  Text(item.description, style: theme.textTheme.bodyMedium),
                  const Divider(height: AppSizes.p24),

                  if (item.responseNotes != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.p16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 20),
                              const SizedBox(width: AppSizes.p8),
                              Expanded(
                                child: Text(
                                  item.assignedWorkerName ?? 'Extension Officer Response',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.p8),
                          Text(
                            item.responseNotes!,
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.p16),
                  ] else ...[
                    Card(
                      color: Colors.amber.withValues(alpha: 0.08),
                      child: const Padding(
                        padding: EdgeInsets.all(AppSizes.p12),
                        child: Row(
                          children: [
                            Icon(Icons.hourglass_top_rounded, color: Colors.amber),
                            SizedBox(width: AppSizes.p12),
                            Expanded(
                              child: Text(
                                'Your inquiry is currently being evaluated by the assigned extension agent. You will receive an update here and via SMS.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.p16),
                  ],

                  AppButton.outlined(
                    label: 'Close',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase().replaceAll('-', '_')) {
      case 'OPEN':
        return Colors.blue;
      case 'ASSIGNED':
        return Colors.indigo;
      case 'IN_PROGRESS':
        return Colors.cyan;
      case 'WAITING_FOR_INFORMATION':
        return Colors.orange;
      case 'ESCALATED':
        return Colors.deepOrange;
      case 'RESOLVED':
        return AppColors.success;
      case 'CLOSED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
