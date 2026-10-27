import 'package:flutter/material.dart';

import '../../../../core/config/user_session.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/content_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';

class ExtensionDraftsScreen extends StatefulWidget {
  const ExtensionDraftsScreen({super.key});

  @override
  State<ExtensionDraftsScreen> createState() => _ExtensionDraftsScreenState();
}

class _ExtensionDraftsScreenState extends State<ExtensionDraftsScreen> {
  final ContentService _contentService = ContentService(apiClient: ApiClient());
  List<ContentModel> _drafts = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  String? _authorId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await UserSession.get();
      if (user == null) {
        throw StateError('Sign in to view your advisory drafts.');
      }
      final drafts = await _contentService.getAdvisories(
        status: 'DRAFT',
        authorId: user.id,
      );
      if (!mounted) return;
      setState(() {
        _authorId = user.id;
        _drafts = drafts;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createDraft() async {
    final input = await showDialog<({String title, String body})>(
      context: context,
      builder: (context) => const _DraftEditorDialog(),
    );
    if (input == null) return;
    setState(() => _isSaving = true);
    try {
      final draft = await _contentService.createAdvisory(
        title: input.title,
        body: input.body,
        language: 'en',
      );
      if (!mounted) return;
      setState(() => _drafts.insert(0, draft));
    } catch (error) {
      _showError('Draft could not be saved: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _submitForReview(ContentModel draft) async {
    if (_authorId == null || draft.createdBy != _authorId) {
      _showError('Only the author can submit this draft for review.');
      return;
    }
    try {
      await _contentService.submitForReview(draft.id);
      await _load();
    } catch (error) {
      _showError('Draft could not be submitted for review: $error');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Advisory drafts'),
          actions: [
            IconButton(
              onPressed: _isLoading ? null : _load,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh drafts',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isSaving ? null : _createDraft,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
          label: const Text('New draft'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _DraftError(message: _error!, onRetry: _load)
            : _drafts.isEmpty
            ? const Center(
                child: Text('No drafts yet. Create one to get started.'),
              )
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  itemCount: _drafts.length,
                  itemBuilder: (context, index) {
                    final draft = _drafts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.p12),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.p16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              draft.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSizes.p8),
                            Text(
                              draft.body,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSizes.p12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                onPressed: () => _submitForReview(draft),
                                icon: const Icon(Icons.send_outlined),
                                label: const Text('Submit for review'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _DraftEditorDialog extends StatefulWidget {
  const _DraftEditorDialog();

  @override
  State<_DraftEditorDialog> createState() => _DraftEditorDialogState();
}

class _DraftEditorDialogState extends State<_DraftEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create advisory draft'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a title.'
                    : null,
              ),
              const SizedBox(height: AppSizes.p12),
              TextFormField(
                controller: _bodyController,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Advisory',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter the advisory text.'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.pop(context, (
              title: _titleController.text.trim(),
              body: _bodyController.text.trim(),
            ));
          },
          child: const Text('Save draft'),
        ),
      ],
    );
  }
}

class _DraftError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DraftError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.p12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
