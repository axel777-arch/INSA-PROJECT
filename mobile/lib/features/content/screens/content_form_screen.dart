import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/content_model.dart';
import '../../../../models/crop_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';
import '../../../../services/farmer_service.dart';

class ContentFormScreen extends StatefulWidget {
  final ContentModel? initialContent;

  const ContentFormScreen({super.key, this.initialContent});

  @override
  State<ContentFormScreen> createState() => _ContentFormScreenState();
}

class _ContentFormScreenState extends State<ContentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _summaryController;
  late final TextEditingController _bodyController;
  late final TextEditingController _zoneController;
  late final TextEditingController _woredaController;
  late final TextEditingController _kebeleController;
  late final TextEditingController _sourceInfoController;
  late final TextEditingController _attachmentsController;
  late final TextEditingController _changeSummaryController;

  final ContentService _contentService = ContentService(apiClient: ApiClient());
  final FarmerService _farmerService = FarmerService(apiClient: ApiClient());

  String _selectedLanguage = 'en';
  String _selectedPriority = 'NORMAL';
  String? _selectedCategory;
  String? _selectedRegion;
  String? _selectedSeason;
  String? _selectedCropStage;
  CropModel? _selectedCrop;
  List<CropModel> _crops = [];
  bool _loadingCrops = true;
  bool _isSubmitting = false;

  List<ContentReviewModel> _reviewHistory = [];
  bool _loadingReviews = false;

  static const List<String> _languages = ['en', 'am', 'om', 'ti'];
  static const Map<String, String> _languageLabels = {
    'en': 'English',
    'am': 'Amharic (አማርኛ)',
    'om': 'Afaan Oromoo',
    'ti': 'Tigrinya (ትግርኛ)',
  };

  static const List<String> _categories = [
    'Agronomy Advisory',
    'Pest & Disease Control',
    'Irrigation & Water',
    'Soil Health & Fertility',
    'Weather Alert',
    'Harvest & Storage',
    'Market & Input Guidance',
  ];

  static const List<String> _regions = [
    'Oromia',
    'Amhara',
    'Tigray',
    'Sidama',
    'Somali',
    'Afar',
    'Benishangul-Gumuz',
    'Central Ethiopia',
    'South Ethiopia',
    'South West Ethiopia',
    'Harari',
    'Dire Dawa',
    'Addis Ababa',
  ];

  static const List<String> _seasons = [
    'Meher (Main Rainy Season)',
    'Belg (Short Rainy Season)',
    'Bega (Dry Season)',
    'All Seasons',
  ];

  static const List<String> _cropStages = [
    'Land Preparation',
    'Sowing / Planting',
    'Vegetative Growth',
    'Flowering / Seed Setting',
    'Maturity / Ripening',
    'Harvesting',
    'Post-Harvest & Storage',
  ];

  @override
  void initState() {
    super.initState();
    final init = widget.initialContent;
    _titleController = TextEditingController(text: init?.title ?? '');
    _summaryController = TextEditingController(text: init?.summary ?? '');
    _bodyController = TextEditingController(text: init?.body ?? '');
    _zoneController = TextEditingController(text: init?.zone ?? '');
    _woredaController = TextEditingController(text: init?.woreda ?? '');
    _kebeleController = TextEditingController(text: init?.kebele ?? '');
    _sourceInfoController = TextEditingController(text: init?.sourceInfo ?? '');
    _attachmentsController = TextEditingController(text: init?.attachments ?? '');
    _changeSummaryController = TextEditingController();

    if (init != null) {
      _selectedLanguage = init.language;
      _selectedPriority = init.priority;
      _selectedCategory = init.category;
      _selectedRegion = init.region;
      _selectedSeason = init.season;
      _selectedCropStage = init.cropStage;
      if (init.isNeedsRevision) {
        _loadReviewHistory(init.id);
      }
    }

    _loadCrops();
  }

  Future<void> _loadCrops() async {
    try {
      final crops = await _farmerService.getCrops();
      if (!mounted) return;
      setState(() {
        _crops = crops;
        _loadingCrops = false;
        if (widget.initialContent?.cropId != null) {
          _selectedCrop = _crops.where((c) => c.id == widget.initialContent!.cropId).firstOrNull;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCrops = false);
    }
  }

  Future<void> _loadReviewHistory(String contentId) async {
    setState(() => _loadingReviews = true);
    try {
      final reviews = await _contentService.getContentReviews(contentId);
      if (!mounted) return;
      setState(() {
        _reviewHistory = reviews;
        _loadingReviews = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingReviews = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _bodyController.dispose();
    _zoneController.dispose();
    _woredaController.dispose();
    _kebeleController.dispose();
    _sourceInfoController.dispose();
    _attachmentsController.dispose();
    _changeSummaryController.dispose();
    super.dispose();
  }

  Future<void> _save({required bool submitNow}) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);

    try {
      ContentModel result;
      final isEditing = widget.initialContent != null;

      if (isEditing) {
        // Update existing content
        result = await _contentService.updateAdvisory(
          widget.initialContent!.id,
          title: _titleController.text.trim(),
          summary: _summaryController.text.trim(),
          body: _bodyController.text.trim(),
          cropId: _selectedCrop?.id,
          category: _selectedCategory,
          language: _selectedLanguage,
          region: _selectedRegion,
          zone: _zoneController.text.trim(),
          woreda: _woredaController.text.trim(),
          kebele: _kebeleController.text.trim(),
          season: _selectedSeason,
          cropStage: _selectedCropStage,
          priority: _selectedPriority,
          sourceInfo: _sourceInfoController.text.trim(),
          attachments: _attachmentsController.text.trim(),
          changeSummary: _changeSummaryController.text.trim().isNotEmpty
              ? _changeSummaryController.text.trim()
              : (submitNow ? 'Submitted for review' : 'Draft updated'),
        );

        if (submitNow) {
          result = await _contentService.submitForReview(result.id);
        }
      } else {
        // Create new draft
        result = await _contentService.createAdvisory(
          title: _titleController.text.trim(),
          summary: _summaryController.text.trim(),
          body: _bodyController.text.trim(),
          cropId: _selectedCrop?.id,
          category: _selectedCategory,
          language: _selectedLanguage,
          region: _selectedRegion,
          zone: _zoneController.text.trim(),
          woreda: _woredaController.text.trim(),
          kebele: _kebeleController.text.trim(),
          season: _selectedSeason,
          cropStage: _selectedCropStage,
          priority: _selectedPriority,
          sourceInfo: _sourceInfoController.text.trim(),
          attachments: _attachmentsController.text.trim(),
        );

        if (submitNow) {
          result = await _contentService.submitForReview(result.id);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            submitNow
                ? 'Advisory submitted for expert review! (v${result.version})'
                : 'Advisory draft saved successfully.',
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
        SnackBar(content: Text('Failed to save advisory: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialContent != null;
    final isRevision = widget.initialContent?.isNeedsRevision ?? false;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            isRevision
                ? 'Revise Advisory (v${widget.initialContent!.version})'
                : (isEditing ? 'Edit Advisory Draft' : 'New Advisory Draft'),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.p16),
            children: [
              // Expert Revision Banner if revision requested
              if (isRevision) _buildRevisionBanner(theme),

              // Title Field
              AppTextField(
                label: 'Advisory Title *',
                controller: _titleController,
                prefixIcon: Icons.title_rounded,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: AppSizes.p16),

              // Summary Field
              AppTextField(
                label: 'Short Summary / Digest (SMS / Alert preview)',
                controller: _summaryController,
                prefixIcon: Icons.short_text_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.p16),

              // Full Content Body
              AppTextField(
                label: 'Full Advisory Content *',
                controller: _bodyController,
                prefixIcon: Icons.description_outlined,
                maxLines: 5,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Content body is required' : null,
              ),
              const SizedBox(height: AppSizes.p16),

              // Category / Topic
              DropdownButtonFormField<String?>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Topic / Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('General / Uncategorized'),
                  ),
                  ..._categories.map(
                    (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                  ),
                ],
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: AppSizes.p16),

              // Target Crop & Language row
              Row(
                children: [
                  Expanded(
                    child: _loadingCrops
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<CropModel?>(
                            value: _selectedCrop,
                            decoration: const InputDecoration(
                              labelText: 'Target Crop',
                              prefixIcon: Icon(Icons.eco_outlined),
                            ),
                            items: [
                              const DropdownMenuItem<CropModel?>(
                                value: null,
                                child: Text('All Crops'),
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
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedLanguage,
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
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p16),

              // Priority & Region row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority Level',
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'LOW', child: Text('Low')),
                        DropdownMenuItem(value: 'NORMAL', child: Text('Normal')),
                        DropdownMenuItem(value: 'HIGH', child: Text('High')),
                        DropdownMenuItem(value: 'URGENT', child: Text('Urgent')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPriority = val);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: _selectedRegion,
                      decoration: const InputDecoration(
                        labelText: 'Target Region',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Regions (National)'),
                        ),
                        ..._regions.map(
                          (r) => DropdownMenuItem(value: r, child: Text(r)),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedRegion = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p16),

              // Location details: Zone & Woreda
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Target Zone (optional)',
                      controller: _zoneController,
                      prefixIcon: Icons.map_outlined,
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: AppTextField(
                      label: 'Target Woreda (optional)',
                      controller: _woredaController,
                      prefixIcon: Icons.pin_drop_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p16),

              // Season & Crop Stage
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: _selectedSeason,
                      decoration: const InputDecoration(
                        labelText: 'Season',
                        prefixIcon: Icon(Icons.wb_sunny_outlined),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Any Season'),
                        ),
                        ..._seasons.map(
                          (s) => DropdownMenuItem(value: s, child: Text(s)),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedSeason = val),
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: _selectedCropStage,
                      decoration: const InputDecoration(
                        labelText: 'Crop Stage',
                        prefixIcon: Icon(Icons.grass_outlined),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Any Stage'),
                        ),
                        ..._cropStages.map(
                          (cs) => DropdownMenuItem(value: cs, child: Text(cs)),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedCropStage = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p16),

              // Source & Attribution
              AppTextField(
                label: 'Scientific Reference / Research Source',
                controller: _sourceInfoController,
                prefixIcon: Icons.menu_book_outlined,
                hintText: 'e.g. EIAR Bulletin / MoA Agronomy Standard',
              ),
              const SizedBox(height: AppSizes.p16),

              // Supporting Attachments
              AppTextField(
                label: 'Supporting Documentation / Attachments (URL)',
                controller: _attachmentsController,
                prefixIcon: Icons.attach_file_rounded,
                hintText: 'Link to PDF bulletin, image, or research report',
              ),
              const SizedBox(height: AppSizes.p16),

              // Revision Change Summary (if editing)
              if (isEditing) ...[
                AppTextField(
                  label: 'Revision Notes (What changed?)',
                  controller: _changeSummaryController,
                  prefixIcon: Icons.history_edu_rounded,
                  hintText: isRevision
                      ? 'Explain how reviewer feedback was addressed...'
                      : 'Summary of changes made...',
                ),
                const SizedBox(height: AppSizes.p16),
              ],

              const SizedBox(height: AppSizes.p16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save Draft'),
                      onPressed: _isSubmitting ? null : () => _save(submitNow: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: AppButton(
                      label: isRevision ? 'Resubmit for Review' : 'Submit for Review',
                      icon: Icons.send_rounded,
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : () => _save(submitNow: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevisionBanner(ThemeData theme) {
    final latestReview = _reviewHistory.firstOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p20),
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade700, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_late_rounded, color: Colors.amber.shade800),
              const SizedBox(width: AppSizes.p8),
              Text(
                'Expert Revision Requested',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p8),
          const Text(
            'An agricultural expert requested modifications before this advisory can be approved and published:',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: AppSizes.p8),
          if (_loadingReviews)
            const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)))
          else if (latestReview?.comments != null && latestReview!.comments!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.p12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reviewer Feedback (${latestReview.reviewerName ?? 'Expert'}):',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    latestReview.comments!,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            )
          else
            const Text(
              'Please review and enhance technical details before resubmitting.',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
