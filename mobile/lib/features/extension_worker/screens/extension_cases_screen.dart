import 'package:flutter/material.dart';
import 'case_collaboration_screen.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/farmer_case_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/farmer_case_service.dart';

class ExtensionCasesScreen extends StatefulWidget {
  const ExtensionCasesScreen({super.key});

  @override
  State<ExtensionCasesScreen> createState() => _ExtensionCasesScreenState();
}

class _ExtensionCasesScreenState extends State<ExtensionCasesScreen> {
  final FarmerCaseService _caseService = FarmerCaseService(
    apiClient: ApiClient(),
  );
  List<FarmerCaseModel> _cases = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final cases = await _caseService.getCases(useLocalFallback: false);
      if (!mounted) return;
      setState(() {
        _cases = cases;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) => switch (status.toUpperCase()) {
    'OPEN' => Colors.orange,
    'ASSIGNED' || 'IN_PROGRESS' => Colors.blue,
    'WAITING_FOR_INFORMATION' => Colors.deepPurple,
    'ESCALATED' => AppColors.error,
    'RESOLVED' || 'CLOSED' => AppColors.success,
    _ => Colors.grey,
  };

  Future<void> _showCaseDetails(FarmerCaseModel item) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CaseCollaborationScreen(caseId: item.id),
      ),
    );
    await _loadCases();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.current;
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(loc.cases),
          actions: [
            IconButton(
              tooltip: loc.refresh,
              onPressed: _loadCases,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSizes.p12),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: AppSizes.p16),
                      ElevatedButton.icon(
                        onPressed: _loadCases,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(loc.retry),
                      ),
                    ],
                  ),
                ),
              )
            : _cases.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Theme.of(context).disabledColor,
                      ),
                      const SizedBox(height: AppSizes.p12),
                      Text(loc.noCases),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadCases,
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  itemCount: _cases.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSizes.p8),
                  itemBuilder: (context, index) {
                    final item = _cases[index];
                    final color = _statusColor(item.status);
                    return Card(
                      child: ListTile(
                        onTap: () => _showCaseDetails(item),
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.12),
                          child: Icon(Icons.assignment_outlined, color: color),
                        ),
                        title: Text(
                          item.subject,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: AppSizes.p8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item.farmerName} · ${item.cropName}'),
                              const SizedBox(height: AppSizes.p4),
                              Text(item.location),
                              const SizedBox(height: AppSizes.p8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.p8,
                                  vertical: AppSizes.p4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.r8,
                                  ),
                                ),
                                child: Text(
                                  loc.caseStatusLabel(item.status),
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
