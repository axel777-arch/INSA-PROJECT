import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class RegisterFarmerFlow extends StatefulWidget {
  const RegisterFarmerFlow({super.key});

  @override
  State<RegisterFarmerFlow> createState() => _RegisterFarmerFlowState();
}

class _RegisterFarmerFlowState extends State<RegisterFarmerFlow> {
  int _currentStep = 0;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedGender = 'Male';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Farmer')),
      body: SafeArea(
        child: Column(
          children: [
            // Horizontal Step Indicators
            Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStepIndicator('1', 'Personal', active: _currentStep >= 0),
                  _buildStepIndicator('2', 'Farm', active: _currentStep >= 1),
                  _buildStepIndicator('3', 'Crops', active: _currentStep >= 2),
                  _buildStepIndicator('4', 'Review', active: _currentStep >= 3),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.p20),
                child: _buildStepContent(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: AppButton.outlined(
                        label: 'Back',
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                          });
                        },
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: AppButton(
                      label: _currentStep == 3 ? 'Register Farmer' : 'Next Step',
                      onPressed: () {
                        if (_currentStep < 3) {
                          setState(() {
                            _currentStep++;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Farmer Registered Successfully!')),
                          );
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String index, String label, {required bool active}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: active ? theme.primaryColor : theme.dividerColor,
          child: Text(
            index,
            style: TextStyle(color: active ? Colors.white : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? theme.textTheme.bodyLarge?.color : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    final theme = Theme.of(context);
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter farmer\'s primary contact and personal information.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.p20),
            AppTextField(
              label: 'Full Name *',
              controller: _nameController,
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'Phone Number *',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender *',
                prefixIcon: Icon(Icons.wc_rounded),
              ),
              items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedGender = val);
              },
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Farm Location details', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSizes.p20),
            const AppTextField(label: 'Region', prefixIcon: Icons.map_outlined),
            const SizedBox(height: AppSizes.p16),
            const AppTextField(label: 'Zone', prefixIcon: Icons.explore_outlined),
            const SizedBox(height: AppSizes.p16),
            const AppTextField(label: 'Woreda', prefixIcon: Icons.location_city_outlined),
            const SizedBox(height: AppSizes.p16),
            const AppTextField(label: 'Kebele', prefixIcon: Icons.home_outlined),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Select Crops to register', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSizes.p20),
            CheckboxListTile(
              title: const Text('Wheat'),
              value: true,
              onChanged: (val) {},
            ),
            CheckboxListTile(
              title: const Text('Soybeans'),
              value: true,
              onChanged: (val) {},
            ),
            CheckboxListTile(
              title: const Text('Maize'),
              value: false,
              onChanged: (val) {},
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Verify Registration Details', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSizes.p20),
            ListTile(
              title: const Text('Full Name'),
              subtitle: Text(_nameController.text.isEmpty ? 'John Doe' : _nameController.text),
            ),
            ListTile(
              title: const Text('Phone Number'),
              subtitle: Text(_phoneController.text.isEmpty ? '+251 900 000 000' : _phoneController.text),
            ),
            ListTile(
              title: const Text('Gender'),
              subtitle: Text(_selectedGender),
            ),
            const ListTile(
              title: Text('Crops Selected'),
              subtitle: Text('Wheat, Soybeans'),
            ),
          ],
        );
    }
  }
}
