import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class ExtensionHomeScreen extends StatefulWidget {
  const ExtensionHomeScreen({super.key});

  @override
  State<ExtensionHomeScreen> createState() => _ExtensionHomeScreenState();
}

class _ExtensionHomeScreenState extends State<ExtensionHomeScreen> {
  final _farmerFormKey = GlobalKey<FormState>();
  final _advisoryFormKey = GlobalKey<FormState>();

  // Farmer registration fields
  final _farmerNameController = TextEditingController();
  final _farmerPhoneController = TextEditingController();
  String _farmerRegion = 'Oromia';
  String _farmerCrop = 'Wheat';

  // Advisory fields
  final _advisoryTitleController = TextEditingController();
  final _advisoryBodyController = TextEditingController();
  String _advisoryCrop = 'Wheat';

  final List<String> _registeredFarmers = ['Asefa Tolosa (+251911...)', 'Chala Kebe (+251912...)'];
  final List<String> _submittedDrafts = ['Rust alert draft - Pending', 'Wheat fertilizer tips - Approved'];

  @override
  void dispose() {
    _farmerNameController.dispose();
    _farmerPhoneController.dispose();
    _advisoryTitleController.dispose();
    _advisoryBodyController.dispose();
    super.dispose();
  }

  void _registerFarmer() {
    if (_farmerFormKey.currentState!.validate()) {
      setState(() {
        _registeredFarmers.add('${_farmerNameController.text} (${_farmerPhoneController.text})');
        _farmerNameController.clear();
        _farmerPhoneController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Farmer Registered Successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _submitAdvisory() {
    if (_advisoryFormKey.currentState!.validate()) {
      setState(() {
        _submittedDrafts.add('${_advisoryTitleController.text} - Pending Review');
        _advisoryTitleController.clear();
        _advisoryBodyController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Advisory Draft Submitted for Expert Review!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Extension Workspace'),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
              onPressed: () {
                MyApp.themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person_add_alt_1_rounded), text: 'Farmers'),
              Tab(icon: Icon(Icons.note_add_rounded), text: 'Advisories'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            // Farmers Registration Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      child: Form(
                        key: _farmerFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Register New Farmer',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSizes.p12),
                            AppTextField(
                              label: 'Farmer Name',
                              controller: _farmerNameController,
                              prefixIcon: Icons.person_add_alt_1_outlined,
                              validator: (val) => val == null || val.isEmpty ? 'Enter name' : null,
                            ),
                            const SizedBox(height: AppSizes.p12),
                            AppTextField(
                              label: 'Phone Number',
                              controller: _farmerPhoneController,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_outlined,
                              validator: (val) => val == null || val.isEmpty ? 'Enter phone number' : null,
                            ),
                            const SizedBox(height: AppSizes.p12),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _farmerRegion,
                                    decoration: const InputDecoration(labelText: 'Region'),
                                    items: ['Oromia', 'Amhara', 'Tigray', 'SNNPR'].map((region) {
                                      return DropdownMenuItem(value: region, child: Text(region));
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _farmerRegion = val);
                                    },
                                  ),
                                ),
                                const SizedBox(width: AppSizes.p12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _farmerCrop,
                                    decoration: const InputDecoration(labelText: 'Crop'),
                                    items: ['Wheat', 'Teff', 'Maize', 'Barley'].map((crop) {
                                      return DropdownMenuItem(value: crop, child: Text(crop));
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _farmerCrop = val);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.p16),
                            AppButton(
                              label: 'Register Farmer',
                              onPressed: _registerFarmer,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Text(
                    'My Registered Farmers',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  ..._registeredFarmers.map((farmer) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.account_circle_outlined),
                      title: Text(farmer),
                      trailing: Icon(Icons.check_circle, color: theme.primaryColor),
                    ),
                  )),
                ],
              ),
            ),
            
            // Advisories Draft Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      child: Form(
                        key: _advisoryFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Create Advisory Draft',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSizes.p12),
                            AppTextField(
                              label: 'Advisory Title',
                              controller: _advisoryTitleController,
                              prefixIcon: Icons.title_rounded,
                              validator: (val) => val == null || val.isEmpty ? 'Enter title' : null,
                            ),
                            const SizedBox(height: AppSizes.p12),
                            DropdownButtonFormField<String>(
                              initialValue: _advisoryCrop,
                              decoration: const InputDecoration(labelText: 'Target Crop'),
                              items: ['Wheat', 'Teff', 'Maize', 'Barley'].map((crop) {
                                return DropdownMenuItem(value: crop, child: Text(crop));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _advisoryCrop = val);
                              },
                            ),
                            const SizedBox(height: AppSizes.p12),
                            AppTextField(
                              label: 'Detailed Advice / Content',
                              controller: _advisoryBodyController,
                              prefixIcon: Icons.description_outlined,
                              validator: (val) => val == null || val.isEmpty ? 'Enter advisory text' : null,
                            ),
                            const SizedBox(height: AppSizes.p16),
                            AppButton.secondary(
                              label: 'Submit for Review',
                              onPressed: _submitAdvisory,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Text(
                    'Submitted Advisories Status',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  ..._submittedDrafts.map((draft) => Card(
                    child: ListTile(
                      leading: Icon(
                        draft.contains('Pending') ? Icons.hourglass_empty : Icons.check_circle_outline,
                        color: draft.contains('Pending') ? AppColors.warning : AppColors.success,
                      ),
                      title: Text(draft),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
