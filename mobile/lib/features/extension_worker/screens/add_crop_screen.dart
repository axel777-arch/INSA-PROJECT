import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/api_client.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveCrop() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final apiClient = ApiClient(); // Assuming you have a way to inject or get the global ApiClient

    try {
      // Auto adjust to lowercase before sending as requested
      final name = _nameController.text.trim().toLowerCase();
      
      await apiClient.post('/crops', {
        'name': name,
        'description': _descController.text.trim(),
        'active': true,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crop registered successfully!')),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      
      String errorMsg = e.message;
      if (e.statusCode == 409 || errorMsg.toLowerCase().contains('conflict')) {
        errorMsg = 'Error: This crop is already registered!';
      }
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Registration Failed'),
          content: Text(errorMsg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register crop: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Register New Crop')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Manually register a new crop to the central database.'),
                const SizedBox(height: AppSizes.p24),
                AppTextField(
                  label: 'Crop Name *',
                  controller: _nameController,
                  prefixIcon: Icons.eco_outlined,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Crop name is required.';
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.p16),
                AppTextField(
                  label: 'Description',
                  controller: _descController,
                  prefixIcon: Icons.description_outlined,
                ),
                const SizedBox(height: AppSizes.p32),
                AppButton(
                  label: _isLoading ? 'Saving...' : 'Register Crop',
                  onPressed: _isLoading ? null : _saveCrop,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
