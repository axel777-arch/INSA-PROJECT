import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/farmer_case_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/farmer_case_service.dart';
import '../../extension_worker/screens/case_collaboration_screen.dart';
import 'package:mobile/core/localization/app_localizations.dart';

class ExpertEscalatedCasesScreen extends StatefulWidget {
  const ExpertEscalatedCasesScreen({super.key});

  @override
  State<ExpertEscalatedCasesScreen> createState() =>
      _ExpertEscalatedCasesScreenState();
}

class _ExpertEscalatedCasesScreenState
    extends State<ExpertEscalatedCasesScreen> {
  final FarmerCaseService _caseService = FarmerCaseService(
    apiClient: ApiClient(),
  );
  List<FarmerCaseModel> _cases = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final allCases = await _caseService.getCases(useLocalFallback: false);
      if (!mounted) return;
      setState(() {
        _cases = allCases
            .where((item) => item.status.toUpperCase() == 'ESCALATED')
            .toList();
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openCase(FarmerCaseModel item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CaseCollaborationScreen(caseId: item.id),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(appText('Escalated cases')),
          actions: [
            IconButton(
              tooltip: appText('Refresh'),
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      TextButton(
                        onPressed: _load,
                        child: Text(appText('Retry')),
                      ),
                    ],
                  ),
                ),
              )
            : _cases.isEmpty
            ? Center(
                child: Text(
                  appText('There are no escalated cases to review.'),
                  textAlign: TextAlign.center,
                ),
              )
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  itemCount: _cases.length,
                  itemBuilder: (context, index) {
                    final item = _cases[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.p12),
                      child: ListTile(
                        leading: const Icon(Icons.priority_high_rounded),
                        title: Text(item.subject),
                        subtitle: Text(
                          '${item.farmerName} • ${item.cropName}\n${item.location}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openCase(item),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
