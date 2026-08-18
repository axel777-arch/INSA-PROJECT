import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regionController = TextEditingController(text: 'Oromia');
  final _zoneController = TextEditingController(text: 'East Shewa');
  final _woredaController = TextEditingController(text: 'Ada\'a');
  final _kebeleController = TextEditingController(text: 'Bishoftu 01');
  bool _alertsEnabled = true;

  @override
  void dispose() {
    _regionController.dispose();
    _zoneController.dispose();
    _woredaController.dispose();
    _kebeleController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmer Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.p16),
          children: [
            AppTextField(
              label: 'Region',
              controller: _regionController,
              prefixIcon: Icons.map_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'Zone',
              controller: _zoneController,
              prefixIcon: Icons.explore_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'Woreda',
              controller: _woredaController,
              prefixIcon: Icons.location_city_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'Kebele',
              controller: _kebeleController,
              prefixIcon: Icons.home_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            SwitchListTile(
              title: const Text('Receive SMS Alerts'),
              subtitle: const Text('Get notified of critical advisories immediately'),
              value: _alertsEnabled,
              onChanged: (val) {
                setState(() {
                  _alertsEnabled = val;
                });
              },
            ),
            const SizedBox(height: AppSizes.p24),
            AppButton(
              label: 'Save Profile',
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}
