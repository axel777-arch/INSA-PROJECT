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

  Future<void> _editFarmer(FarmerModel farmer) async {
    final nameController = TextEditingController(text: farmer.fullName);
    final phoneController = TextEditingController(text: farmer.phone);
    final regionController = TextEditingController(text: farmer.region);
    final zoneController = TextEditingController(text: farmer.zone);
    final woredaController = TextEditingController(text: farmer.woreda);
    final kebeleController = TextEditingController(text: farmer.kebele);
    var gender = farmer.gender == 'Female' ? 'Female' : 'Male';
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Object>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Farmer'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(label: 'Full Name', controller: nameController),
                  const SizedBox(height: AppSizes.p12),
                  AppTextField(label: 'Phone', controller: phoneController, keyboardType: TextInputType.phone),
                  const SizedBox(height: AppSizes.p12),
                  DropdownButtonFormField<String>(
                    initialValue: gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: const ['Male', 'Female'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                    onChanged: (value) => gender = value ?? gender,
                  ),
                  const SizedBox(height: AppSizes.p12),
                  AppTextField(label: 'Region', controller: regionController),
                  const SizedBox(height: AppSizes.p12),
                  AppTextField(label: 'Zone', controller: zoneController),
                  const SizedBox(height: AppSizes.p12),
                  AppTextField(label: 'Woreda', controller: woredaController),
                  const SizedBox(height: AppSizes.p12),
                  AppTextField(label: 'Kebele', controller: kebeleController),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: dialogContext,
                builder: (confirmContext) => AlertDialog(
                  title: const Text('Delete Farmer?'),
                  content: Text('Remove ${farmer.fullName} permanently?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(confirmContext, false), child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () => Navigator.pop(confirmContext, true),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && dialogContext.mounted) Navigator.pop(dialogContext, 'delete');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete Farmer'),
          ),
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? true)) return;
              Navigator.pop(dialogContext, FarmerModel(
                id: farmer.id,
                userId: farmer.userId,
                fullName: nameController.text.trim(),
                phone: phoneController.text.trim(),
                gender: gender,
                region: regionController.text.trim(),
                zone: zoneController.text.trim(),
                woreda: woredaController.text.trim(),
                kebele: kebeleController.text.trim(),
                alertEnabled: farmer.alertEnabled,
                active: farmer.active,
                cropIds: farmer.cropIds,
              ));
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
    // Let the dialog route finish unmounting before disposing its controllers.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    nameController.dispose();
    phoneController.dispose();
    regionController.dispose();
    zoneController.dispose();
    woredaController.dispose();
    kebeleController.dispose();
    if (result == 'delete') {
      try {
        await _farmerService.deleteManagedFarmer(farmer.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Farmer deleted successfully.')));
          await _loadFarmers();
        }
      } on ApiException catch (error) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
      return;
    }
    final edited = result is FarmerModel ? result : null;
    if (edited == null || !mounted) return;
    if (edited.id == farmer.id && edited.fullName == farmer.fullName && edited.phone == farmer.phone && edited.region == farmer.region && edited.zone == farmer.zone && edited.woreda == farmer.woreda && edited.kebele == farmer.kebele && edited.gender == farmer.gender) {
      return;
    }
    try {
      await _farmerService.updateManagedFarmer(edited);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Farmer updated successfully.')));
        await _loadFarmers();
      }
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  void _viewFarmer(FarmerModel farmer) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const CircleAvatar(radius: 28, child: Icon(Icons.person_rounded)),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(child: Text(farmer.fullName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                ]),
                const Divider(height: AppSizes.p24),
                _detailRow('Phone', farmer.phone),
                _detailRow('Gender', farmer.gender),
                _detailRow('Region / Zone', '${farmer.region} / ${farmer.zone}'),
                _detailRow('Woreda / Kebele', '${farmer.woreda} / ${farmer.kebele}'),
                _detailRow('Crops', farmer.cropNames.isNotEmpty ? farmer.cropNames.join(', ') : 'None registered'),
                const SizedBox(height: AppSizes.p16),
                Align(alignment: Alignment.centerRight, child: FilledButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: AppSizes.p8),
    child: Row(children: [SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Colors.grey))), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)))]),
  );

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
                                    'Crops: ${farmer.cropNames.isNotEmpty ? farmer.cropNames.join(', ') : '—'}',
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
                                            _viewFarmer(farmer);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: AppSizes.p12),
                                      Expanded(
                                        child: AppButton(
                                          label: 'Edit',
                                          onPressed: () => _editFarmer(farmer),
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

