import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class ContentFormScreen extends StatefulWidget {
  const ContentFormScreen({super.key});

  @override
  State<ContentFormScreen> createState() => _ContentFormScreenState();
}

class _ContentFormScreenState extends State<ContentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submitDraft() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Advisory Draft')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.p16),
          children: [
            AppTextField(
              label: 'Advisory Title',
              controller: _titleController,
              prefixIcon: Icons.title_rounded,
              validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'Content Body',
              controller: _bodyController,
              prefixIcon: Icons.description_outlined,
              validator: (val) => val == null || val.isEmpty ? 'Content is required' : null,
            ),
            const SizedBox(height: AppSizes.p24),
            AppButton(
              label: 'Submit Advisory',
              onPressed: _submitDraft,
            ),
          ],
        ),
      ),
    );
  }
}
