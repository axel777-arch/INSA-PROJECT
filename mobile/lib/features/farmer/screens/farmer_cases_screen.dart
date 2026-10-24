import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/user_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/api_client.dart';

class FarmerCasesScreen extends StatefulWidget {
  const FarmerCasesScreen({super.key});

  @override
  State<FarmerCasesScreen> createState() => _FarmerCasesScreenState();
}

class _FarmerCasesScreenState extends State<FarmerCasesScreen> {
  final ApiClient _api = ApiClient();
  List<Map<String, dynamic>> _cases = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _api.get('/cases');
      if (result is! List) {
        throw const FormatException('Unexpected case list response');
      }
      if (!mounted) return;
      setState(() {
        _cases = result.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openQuestionForm() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (_) => const FarmerQuestionFormScreen()),
    );
    if (created == true) _loadCases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My questions and cases'),
        actions: [
          IconButton(
            onPressed: _loadCases,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openQuestionForm,
        icon: const Icon(Icons.add),
        label: const Text('Ask a question'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _loadCases,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            )
          : _cases.isEmpty
          ? const Center(child: Text('You have not submitted a question yet.'))
          : RefreshIndicator(
              onRefresh: _loadCases,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                itemCount: _cases.length,
                itemBuilder: (context, index) {
                  final item = _cases[index];
                  final status = item['status']?.toString() ?? 'OPEN';
                  final id = item['id']?.toString() ?? '';
                  return Card(
                    child: ExpansionTile(
                      leading: Icon(
                        Icons.assignment_outlined,
                        color: _statusColor(status),
                      ),
                      title: Text(
                        item['title']?.toString() ?? 'Farmer question',
                      ),
                      subtitle: Text(
                        'Case $id\n$status • ${item['priority'] ?? 'NORMAL'}',
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['description']?.toString() ?? ''),
                        const SizedBox(height: 8),
                        Text('Category: ${item['category'] ?? 'GENERAL'}'),
                        if (item['cropName'] != null)
                          Text('Crop: ${item['cropName']}'),
                        if (item['location'] != null &&
                            item['location'].toString().isNotEmpty)
                          Text('Location: ${item['location']}'),
                        if (item['resolutionSummary'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Resolution: ${item['resolutionSummary']}',
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'RESOLVED':
      case 'CLOSED':
        return AppColors.success;
      case 'ESCALATED':
        return AppColors.error;
      case 'WAITING_FOR_INFORMATION':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }
}

class FarmerQuestionFormScreen extends StatefulWidget {
  const FarmerQuestionFormScreen({super.key});

  @override
  State<FarmerQuestionFormScreen> createState() =>
      _FarmerQuestionFormScreenState();
}

class _FarmerQuestionFormScreenState extends State<FarmerQuestionFormScreen> {
  static const _categories = [
    'GENERAL',
    'PEST',
    'DISEASE',
    'SOIL',
    'WEATHER',
    'IRRIGATION',
    'OTHER',
  ];
  static const _priorities = ['LOW', 'NORMAL', 'HIGH', 'URGENT'];
  static const _languages = {
    'English': 'en',
    'Amharic': 'am',
    'Afaan Oromoo': 'om',
  };
  final _formKey = GlobalKey<FormState>();
  final _api = ApiClient();
  final _picker = ImagePicker();
  final _subject = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  List<Map<String, dynamic>> _crops = [];
  final List<Map<String, dynamic>> _attachments = [];
  String? _cropId;
  String _category = _categories.first;
  String _priority = 'NORMAL';
  String _language = 'en';
  DateTime? _observationDate;
  bool _saving = false;
  String? _error;
  int _attachmentBytes = 0;

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  Future<void> _loadDefaults() async {
    final user = await UserSession.get();
    if (mounted &&
        user != null &&
        _languages.values.contains(user.preferredLanguage)) {
      setState(() => _language = user.preferredLanguage);
    }
    await _loadCrops();
  }

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _loadCrops() async {
    try {
      final result = await _api.get('/crops');
      if (!mounted || result is! List) return;
      setState(() => _crops = result.cast<Map<String, dynamic>>());
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not load crops: $error');
    }
  }

  Future<void> _pickPhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (photo == null) return;
    await _addAttachment(
      photo.name,
      photo.mimeType ?? 'image/jpeg',
      await photo.readAsBytes(),
    );
  }

  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null) return;
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes != null) {
        await _addAttachment(
          file.name,
          file.extension ?? 'application/octet-stream',
          bytes,
        );
      }
    }
  }

  Future<void> _addAttachment(String name, String type, List<int> bytes) async {
    if (_attachments.length >= 5 ||
        _attachmentBytes + bytes.length > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Add up to five files with a combined size under 5 MB.',
            ),
          ),
        );
      }
      return;
    }
    setState(() {
      _attachmentBytes += bytes.length;
      _attachments.add({
        'name': name,
        'type': type,
        'data': base64Encode(bytes),
      });
    });
  }

  Future<void> _selectObservationDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _observationDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (picked != null) setState(() => _observationDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final payload = <String, dynamic>{
        'title': _subject.text.trim(),
        'description': _description.text.trim(),
        'cropId': _cropId,
        'location': _location.text.trim(),
        'category': _category,
        'priority': _priority,
        'preferredResponseLanguage': _language,
        'attachments': _attachments,
        if (_observationDate != null)
          'observationDate':
              '${_observationDate!.year.toString().padLeft(4, '0')}-'
              '${_observationDate!.month.toString().padLeft(2, '0')}-'
              '${_observationDate!.day.toString().padLeft(2, '0')}',
      };
      final result = await _api.post('/cases', payload);
      if (!mounted) return;
      final caseId = result is Map ? result['id']?.toString() : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            caseId == null
                ? 'Question submitted.'
                : 'Question submitted. Case ID: $caseId',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ask an agricultural question')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _subject,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a subject'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Describe the issue',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Describe your question'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _cropId,
              decoration: const InputDecoration(
                labelText: 'Crop (optional)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Not specified'),
                ),
                ..._crops.map(
                  (crop) => DropdownMenuItem<String>(
                    value: crop['id']?.toString(),
                    child: Text(crop['name']?.toString() ?? 'Crop'),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _cropId = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _location,
              decoration: const InputDecoration(
                labelText: 'Location (region / zone / woreda / kebele)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _category = value ?? _categories.first),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Urgency',
                border: OutlineInputBorder(),
              ),
              items: _priorities
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _priority = value ?? 'NORMAL'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _selectObservationDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                _observationDate == null
                    ? 'Observation date (optional)'
                    : '${_observationDate!.year}-${_observationDate!.month.toString().padLeft(2, '0')}-${_observationDate!.day.toString().padLeft(2, '0')}',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _language,
              decoration: const InputDecoration(
                labelText: 'Preferred response language',
                border: OutlineInputBorder(),
              ),
              items: _languages.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.value,
                      child: Text(entry.key),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _language = value ?? 'en'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Add photo'),
                ),
                OutlinedButton.icon(
                  onPressed: _pickDocuments,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Add files'),
                ),
              ],
            ),
            for (var i = 0; i < _attachments.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.attachment),
                title: Text(_attachments[i]['name'] as String),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    _attachmentBytes -= base64Decode(
                      _attachments[i]['data'] as String,
                    ).length;
                    _attachments.removeAt(i);
                  }),
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit question'),
            ),
          ],
        ),
      ),
    );
  }
}
