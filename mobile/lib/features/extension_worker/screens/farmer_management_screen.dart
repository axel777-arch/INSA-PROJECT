import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../models/farmer_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/farmer_service.dart';
import 'register_farmer_flow.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class FarmerManagementScreen extends StatefulWidget {
  const FarmerManagementScreen({super.key});

  @override
  State<FarmerManagementScreen> createState() => _FarmerManagementScreenState();
}

class _FarmerManagementScreenState extends State<FarmerManagementScreen> {
  final FarmerService _farmerService = FarmerService(apiClient: ApiClient());
  final _searchController = TextEditingController();

  List<FarmerModel> _farmers = [];
  bool _isLoading = true;
  String _cropFilter = 'All';
  String _regionFilter = 'All';

  static const List<String> _cropOptions = [
    'All',
    'wheat',
    'maize',
    'soybeans',
    'teff',
    'barley',
  ];
  static const List<String> _regionOptions = [
    'All',
    'Oromia',
    'Amhara',
    'SNNPR',
    'Tigray',
  ];

  @override
  void initState() {
    super.initState();
    _loadFarmers();
    _searchController.addListener(_loadFarmers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_loadFarmers);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFarmers() async {
    setState(() => _isLoading = true);
    final results = await _farmerService.getFarmers(
      query: _searchController.text,
      cropId: _cropFilter,
      region: _regionFilter,
    );
    if (!mounted) return;
    setState(() {
      _farmers = results;
      _isLoading = false;
    });
  }

  Future<void> _openRegisterFlow() async {
    final registered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterFarmerFlow()),
    );
    if (registered == true) {
      _loadFarmers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text('Farmer Management')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openRegisterFlow,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Register Farmer'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            children: [
              // Search Input
              AppTextField(
                label: 'Search farmers...',
                controller: _searchController,
                prefixIcon: Icons.search_rounded,
              ),
              const SizedBox(height: AppSizes.p12),

              // Filter chips row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _cropFilter,
                      decoration: const InputDecoration(labelText: 'Crop'),
                      items: _cropOptions
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() => _cropFilter = val);
                        _loadFarmers();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _regionFilter,
                      decoration: const InputDecoration(labelText: 'Region'),
                      items: _regionOptions
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() => _regionFilter = val);
                        _loadFarmers();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p16),

              // List of Farmers
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _farmers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search_rounded,
                              size: 48,
                              color: theme.disabledColor,
                            ),
                            const SizedBox(height: AppSizes.p12),
                            const Text(
                              'No farmers match your search or filters.',
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _farmers.length,
                        itemBuilder: (context, index) {
                          final farmer = _farmers[index];
                          final isActive = farmer.active;
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSizes.p12),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSizes.p16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          farmer.fullName.isEmpty
                                              ? 'Unnamed farmer'
                                              : farmer.fullName,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? AppColors.success.withValues(
                                                  alpha: 0.1,
                                                )
                                              : Colors.grey.withValues(
                                                  alpha: 0.1,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          isActive ? 'Active' : 'Inactive',
                                          style: TextStyle(
                                            color: isActive
                                                ? AppColors.success
                                                : Colors.grey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Crops: ${farmer.cropIds.isEmpty ? '—' : farmer.cropIds.join(', ')}',
                                  ),
                                  Text(
                                    'Location: ${farmer.region}, ${farmer.woreda}',
                                  ),
                                  Text('Phone: ${farmer.phone}'),
                                  const Divider(height: AppSizes.p24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppButton.outlined(
                                          label: 'View',
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (_) =>
                                                  _FarmerDetailSheet(
                                                    farmer: farmer,
                                                  ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: AppSizes.p12),
                                      Expanded(
                                        child: AppButton(
                                          label: 'Edit',
                                          onPressed: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Editing ${farmer.fullName} is not available in this mock build yet.',
                                                ),
                                              ),
                                            );
                                          },
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FarmerDetailSheet extends StatelessWidget {
  final FarmerModel farmer;

  const _FarmerDetailSheet({required this.farmer});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              farmer.fullName,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p8),
            Text('Phone: ${farmer.phone}'),
            Text('Gender: ${farmer.gender}'),
            Text('Region: ${farmer.region}, ${farmer.zone}'),
            Text('Woreda / Kebele: ${farmer.woreda} / ${farmer.kebele}'),
            Text(
              'Crops: ${farmer.cropIds.isEmpty ? '—' : farmer.cropIds.join(', ')}',
            ),
            const SizedBox(height: AppSizes.p16),
          ],
        ),
      ),
    );
  }
}
