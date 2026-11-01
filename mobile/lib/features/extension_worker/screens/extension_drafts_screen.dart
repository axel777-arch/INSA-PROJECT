import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/user_session.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/role_app_bar_actions.dart';
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
      // Load all advisories authored by this extension worker
      final allItems = await _contentService.getAdvisories(authorId: user.id);
      if (!mounted) return;
      setState(() {
        _authorId = user.id;
        // Include both working DRAFTs and REJECTED items needing revision
        _drafts = allItems
            .where((item) => item.status == 'DRAFT' || item.status == 'REJECTED')
            .toList();
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createDraft() async {
    final input = await showDialog<({String title, String body, List<String> files})>(
      context: context,
      builder: (context) => const _DraftEditorDialog(),
    );
    if (input == null) return;
    setState(() => _isSaving = true);
    try {
      // Append attachment references to body if provided
      var fullBody = input.body;
      if (input.files.isNotEmpty) {
        fullBody += '\n\n[Attachments: ${input.files.join(", ")}]';
      }

      final draft = await _contentService.createAdvisory(
        title: input.title,
        body: fullBody,
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

  Future<void> _editDraft(ContentModel draft) async {
    final input = await showDialog<({String title, String body, List<String> files})>(
      context: context,
      builder: (context) => _DraftEditorDialog(
        initialTitle: draft.title,
        initialBody: draft.body,
        isRejected: draft.status == 'REJECTED',
      ),
    );
    if (input == null) return;
    setState(() => _isSaving = true);
    try {
      var fullBody = input.body;
      if (input.files.isNotEmpty && !fullBody.contains('[Attachments:')) {
        fullBody += '\n\n[Attachments: ${input.files.join(", ")}]';
      }

      // Update content on backend
      await _contentService.updateAdvisory(
        draft.id,
        title: input.title,
        body: fullBody,
      );

      // If it was rejected, automatically submit it back to expert review
      if (draft.status == 'REJECTED') {
        await _contentService.submitForReview(draft.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appText('Advisory revised and submitted for review!')),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appText('Draft updated successfully!')),
            backgroundColor: AppColors.success,
          ),
        );
      }
      await _load();
    } catch (error) {
      _showError('Failed to update draft: $error');
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appText('Submitted for expert review!')),
            backgroundColor: AppColors.success,
          ),
        );
      }
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
          title: Text(appText('Advisory drafts')),
          actions: [
            IconButton(
              onPressed: _isLoading ? null : _load,
              icon: const Icon(Icons.refresh),
              tooltip: appText('Refresh'),
            ),
            ...buildRoleAppBarActions(context),
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
          label: Text(appText('New draft')),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _DraftError(message: _error!, onRetry: _load)
            : _drafts.isEmpty
            ? Center(
                child: Text(
                  appText('No drafts yet. Create one to get started.'),
                ),
              )
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  itemCount: _drafts.length,
                  itemBuilder: (context, index) {
                    final draft = _drafts[index];
                    final isRejected = draft.status == 'REJECTED';

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.p12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                        side: BorderSide(
                          color: isRejected
                              ? AppColors.error.withValues(alpha: 0.5)
                              : Colors.transparent,
                          width: isRejected ? 1.5 : 0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.p16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    draft.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                if (isRejected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.error.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Text(
                                      appText('Needs Revision'),
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (isRejected) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.amber.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: Colors.brown,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        appText(
                                          'Returned by Expert. Tap Edit & Resubmit to update details.',
                                        ),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.brown,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSizes.p8),
                            Text(
                              draft.body,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSizes.p12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isRejected)
                                  FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                    ),
                                    onPressed: () => _editDraft(draft),
                                    icon: const Icon(Icons.edit_note_rounded),
                                    label: Text(appText('Edit & Resubmit')),
                                  )
                                else ...[
                                  OutlinedButton.icon(
                                    onPressed: () => _editDraft(draft),
                                    icon: const Icon(Icons.edit_outlined, size: 16),
                                    label: Text(appText('Edit')),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton.icon(
                                    onPressed: () => _submitForReview(draft),
                                    icon: const Icon(Icons.send_outlined, size: 16),
                                    label: Text(appText('Submit for review')),
                                  ),
                                ],
                              ],
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
  final String? initialTitle;
  final String? initialBody;
  final bool isRejected;

  const _DraftEditorDialog({
    this.initialTitle,
    this.initialBody,
    this.isRejected = false,
  });

  @override
  State<_DraftEditorDialog> createState() => _DraftEditorDialogState();
}

class _DraftEditorDialogState extends State<_DraftEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  final List<String> _attachedFiles = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _bodyController = TextEditingController(text: widget.initialBody ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _attachedFiles.addAll(result.files.map((f) => f.name));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isRejected
            ? appText('Edit & Resubmit Advisory')
            : appText('Create advisory draft'),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: appText('Title'),
                  border: const OutlineInputBorder(),
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
                decoration: InputDecoration(
                  labelText: appText('Advisory'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter the advisory text.'
                    : null,
              ),
              const SizedBox(height: AppSizes.p12),
              // Attachment Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appText('Attached Files (${_attachedFiles.length})'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  TextButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file_rounded, size: 16),
                    label: Text(appText('Attach File')),
                  ),
                ],
              ),
              if (_attachedFiles.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _attachedFiles.map((name) {
                    return Chip(
                      label: Text(name, style: const TextStyle(fontSize: 11)),
                      onDeleted: () => setState(() => _attachedFiles.remove(name)),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(appText('Cancel')),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.pop(context, (
              title: _titleController.text.trim(),
              body: _bodyController.text.trim(),
              files: _attachedFiles,
            ));
          },
          child: Text(
            widget.isRejected
                ? appText('Save & Resubmit')
                : appText('Save draft'),
          ),
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
            FilledButton(onPressed: onRetry, child: Text(appText('Retry'))),
          ],
        ),
      ),
    );
  }
}
