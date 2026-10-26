import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/crop_calendar_model.dart';
import '../../../../services/crop_calendar_service.dart';

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  final CropCalendarService _calendarService = CropCalendarService();
  final TextEditingController _searchController = TextEditingController();

  List<CropCalendarModel> _entries = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedCrop = 'All';
  String _selectedSeason = 'All';

  final List<String> _crops = [
    'All',
    'Teff',
    'Wheat',
    'Maize',
    'Coffee',
    'Barley',
  ];
  final List<String> _seasons = ['All', 'Meher', 'Belg'];

  @override
  void initState() {
    super.initState();
    _loadCalendar();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCalendar() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _calendarService.getCalendarEntries(
        cropName: _selectedCrop == 'All' ? null : _selectedCrop,
        season: _selectedSeason == 'All' ? null : _selectedSeason,
        query: _searchController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _entries = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTask(CropCalendarModel item) async {
    final nextState = !item.isCompleted;
    setState(() {
      item.isCompleted = nextState;
    });
    await _calendarService.toggleTaskCompletion(item.id, nextState);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nextState
              ? 'Task "${item.stage}" marked as completed!'
              : 'Task "${item.stage}" marked as pending.',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.current;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(loc.cropCalendar),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: loc.refresh,
              onPressed: _loadCalendar,
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.p16,
                AppSizes.p12,
                AppSizes.p16,
                AppSizes.p8,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '${loc.search} (Wheat, Weeding, Dega...)',
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p12,
                    vertical: AppSizes.p10,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _loadCalendar();
                          },
                        )
                      : null,
                ),
                onSubmitted: (_) => _loadCalendar(),
              ),
            ),

            // Filters: Crop Selection
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                itemCount: _crops.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSizes.p8),
                itemBuilder: (context, index) {
                  final crop = _crops[index];
                  final isSelected = _selectedCrop == crop;
                  return ChoiceChip(
                    label: Text(crop),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedCrop = crop);
                      _loadCalendar();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.p8),

            // Filters: Season Selection
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                itemCount: _seasons.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSizes.p8),
                itemBuilder: (context, index) {
                  final season = _seasons[index];
                  final isSelected = _selectedSeason == season;
                  return ChoiceChip(
                    label: Text('Season: $season'),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedSeason = season);
                      _loadCalendar();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.p8),

            // Body
            Expanded(child: _buildBody(theme, loc)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, AppLocalizations loc) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSizes.p12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.p16),
              ElevatedButton.icon(
                onPressed: _loadCalendar,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(loc.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 64,
              color: theme.disabledColor,
            ),
            const SizedBox(height: AppSizes.p12),
            Text(appText('No crop calendar schedule found for this filter.')),
            const SizedBox(height: AppSizes.p16),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedCrop = 'All';
                  _selectedSeason = 'All';
                });
                _loadCalendar();
              },
              icon: const Icon(Icons.clear_all_rounded),
              label: Text(appText('Reset Filters')),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCalendar,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final item = _entries[index];

          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.p12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.r12),
              side: BorderSide(
                color: item.isCompleted
                    ? AppColors.success.withValues(alpha: 0.5)
                    : theme.dividerColor,
                width: item.isCompleted ? 1.5 : 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Crop Chip + Season + Checkbox
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.cropName,
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.p8),
                          Text(
                            item.season,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          item.isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: item.isCompleted
                              ? AppColors.success
                              : Colors.grey.shade400,
                          size: 26,
                        ),
                        tooltip: item.isCompleted
                            ? 'Mark as incomplete'
                            : 'Mark as completed',
                        onPressed: () => _toggleTask(item),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p8),

                  // Stage & Time window
                  Text(
                    item.stage,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.timePeriod,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSizes.p12),
                      const Icon(
                        Icons.terrain_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.agroecologicalZone,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: AppSizes.p20),

                  // Recommended Task
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        size: 18,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: AppSizes.p8),
                      Expanded(
                        child: Text(
                          item.recommendedTask,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
