import '../models/content_model.dart';
import 'api_client.dart';

class ContentService {
  final ApiClient apiClient;

  ContentService({required this.apiClient});

  // In-memory mock bulletin store, shared across every ContentService
  // instance until this is wired to a real API.
  static final List<ContentModel> _advisories = [
    ContentModel(
      id: 'adv-1',
      title: 'Optimal Irrigation Scheduling for Winter Wheat under Drought Stress',
      body: 'Recent meteorological data indicates a sustained 60-day dry spell across the southwestern '
          'quadrants. Traditional calendar-based irrigation will result in critical yield losses during '
          'the booting and anthesis stages of winter wheat. If soil moisture tension at a 30cm depth '
          'exceeds 80 kPa, an emergency application of 25mm irrigation is required within 48 hours to '
          'prevent irreversible floret abortion.',
      cropId: 'wheat',
      language: 'en',
      status: 'IN_REVIEW',
      createdBy: 'Dr. Elena Rostova',
      createdAt: DateTime(2023, 10, 24),
      updatedAt: DateTime(2023, 10, 24),
    ),
    ContentModel(
      id: 'adv-2',
      title: 'Optimizing Nitrogen Application for Winter Wheat Yields',
      body: 'Guidance on split nitrogen dosing timed to tillering and stem extension stages to reduce '
          'lodging risk while maintaining protein content targets.',
      cropId: 'wheat',
      language: 'en',
      status: 'IN_REVIEW',
      createdBy: 'Dr. Robert Chen',
      createdAt: DateTime(2023, 10, 24),
      updatedAt: DateTime(2023, 10, 24),
    ),
    ContentModel(
      id: 'adv-3',
      title: 'Early Detection of Sudden Death Syndrome in Soybean Crops',
      body: 'Field scouting checklist and foliar symptom photos to help extension workers flag suspected '
          'SDS cases before canopy-level yield impact occurs.',
      cropId: 'soybeans',
      language: 'en',
      status: 'IN_REVIEW',
      createdBy: 'Amanda Martinez, Agronomist',
      createdAt: DateTime(2023, 10, 23),
      updatedAt: DateTime(2023, 10, 23),
    ),
    ContentModel(
      id: 'adv-4',
      title: 'Assessing Drought Tolerance in New Corn Hybrids',
      body: 'Comparative trial results across three hybrid lines under deficit irrigation, with regional '
          'sowing-window recommendations.',
      cropId: 'maize',
      language: 'en',
      status: 'IN_REVIEW',
      createdBy: 'Sarah Williams, PhD',
      createdAt: DateTime(2023, 10, 20),
      updatedAt: DateTime(2023, 10, 20),
    ),
    ContentModel(
      id: 'adv-5',
      title: 'Integrating Cover Crops for Soil Health Improvement',
      body: 'Rotation planning guidance for legume cover crops to rebuild soil nitrogen and reduce erosion '
          'between primary growing seasons.',
      cropId: 'general',
      language: 'en',
      status: 'IN_REVIEW',
      createdBy: 'Tom Kovac',
      createdAt: DateTime(2023, 10, 18),
      updatedAt: DateTime(2023, 10, 18),
    ),
  ];

  Future<List<ContentModel>> getAdvisories({String? status, String? language}) async {
    // API endpoint: GET /api/content
    var results = List<ContentModel>.from(_advisories);
    if (status != null && status.isNotEmpty) {
      results = results.where((c) => c.status == status).toList();
    }
    if (language != null && language.isNotEmpty) {
      results = results.where((c) => c.language == language).toList();
    }
    return results;
  }

  Future<ContentModel?> getAdvisoryById(String id) async {
    try {
      return _advisories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<ContentModel?> createAdvisory(Map<String, dynamic> data) async {
    // API endpoint: POST /api/content
    final now = DateTime.now();
    final content = ContentModel(
      id: 'adv-${now.millisecondsSinceEpoch}',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      cropId: data['crop_id'] ?? '',
      language: data['language'] ?? 'en',
      status: 'DRAFT',
      createdBy: data['created_by'] ?? '',
      createdAt: now,
      updatedAt: now,
    );
    _advisories.insert(0, content);
    return content;
  }

  Future<bool> submitForReview(String contentId) async {
    // API endpoint: POST /api/content/:id/submit-review
    return _updateStatus(contentId, 'IN_REVIEW');
  }

  Future<bool> approveAdvisory(String contentId, {String? comment}) async {
    // API endpoint: POST /api/content/:id/approve
    return _updateStatus(contentId, 'APPROVED', approvedBy: 'Current Expert');
  }

  Future<bool> rejectAdvisory(String contentId, String comment) async {
    // API endpoint: POST /api/content/:id/reject
    return _updateStatus(contentId, 'REJECTED');
  }

  Future<bool> publishAdvisory(String contentId) async {
    // API endpoint: POST /api/content/:id/publish
    return _updateStatus(contentId, 'PUBLISHED');
  }

  bool _updateStatus(String contentId, String status, {String? approvedBy}) {
    final index = _advisories.indexWhere((c) => c.id == contentId);
    if (index == -1) return false;
    final current = _advisories[index];
    _advisories[index] = ContentModel(
      id: current.id,
      title: current.title,
      body: current.body,
      cropId: current.cropId,
      language: current.language,
      status: status,
      createdBy: current.createdBy,
      approvedBy: approvedBy ?? current.approvedBy,
      approvedAt: approvedBy != null ? DateTime.now() : current.approvedAt,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    return true;
  }
}
