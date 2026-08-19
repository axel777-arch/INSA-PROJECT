import 'api_client.dart';

/// A stateful fake backend that implements the same interface as
/// [ApiClient] but never touches the network. It keeps its own
/// in-memory, JSON-shaped state and routes requests against it, so data
/// created or edited through one screen (e.g. registering a farmer) is
/// visible from every other screen that talks to this same client.
///
/// It's a singleton: every `MockApiClient()` call returns the same
/// instance, so all services/screens share one "database" for the
/// lifetime of the app.
class MockApiClient extends ApiClient {
  MockApiClient._internal();

  static final MockApiClient _instance = MockApiClient._internal();

  factory MockApiClient() => _instance;

  static const _networkDelay = Duration(milliseconds: 250);

  // ---------------------------------------------------------------------
  // Seed data. Shapes match FarmerModel/CropModel/ContentModel.fromJson.
  // ---------------------------------------------------------------------

  final List<Map<String, dynamic>> _farmers = [
    {
      'id': '1',
      'user_id': 'u1',
      'full_name': 'Elias Thorne',
      'phone': '+251911000001',
      'gender': 'Male',
      'region': 'Oromia',
      'zone': 'East Shewa',
      'woreda': 'Adama',
      'kebele': '02',
      'alert_enabled': true,
      'active': true,
      'crop_ids': ['wheat'],
    },
    {
      'id': '2',
      'user_id': 'u2',
      'full_name': 'Sarah Jenkins',
      'phone': '+251911000002',
      'gender': 'Female',
      'region': 'Amhara',
      'zone': 'North Shewa',
      'woreda': 'Debre Birhan',
      'kebele': '05',
      'alert_enabled': true,
      'active': true,
      'crop_ids': ['maize'],
    },
    {
      'id': '3',
      'user_id': 'u3',
      'full_name': 'Marcus Reyes',
      'phone': '+251911000003',
      'gender': 'Male',
      'region': 'SNNPR',
      'zone': 'Sidama',
      'woreda': 'Hawassa Zuria',
      'kebele': '01',
      'alert_enabled': false,
      'active': false,
      'crop_ids': ['soybeans'],
    },
  ];

  final List<Map<String, dynamic>> _crops = [
    {'id': 'wheat', 'name': 'Wheat', 'description': 'Cereal crop', 'active': true},
    {'id': 'maize', 'name': 'Maize', 'description': 'Cereal crop', 'active': true},
    {'id': 'soybeans', 'name': 'Soybeans', 'description': 'Legume crop', 'active': true},
    {'id': 'teff', 'name': 'Teff', 'description': 'Cereal crop', 'active': true},
    {'id': 'barley', 'name': 'Barley', 'description': 'Cereal crop', 'active': true},
  ];

  final List<Map<String, dynamic>> _advisories = [
    {
      'id': 'adv-1',
      'title': 'Optimal Irrigation Scheduling for Winter Wheat under Drought Stress',
      'body':
          'Recent meteorological data indicates a sustained 60-day dry spell across the southwestern '
          'quadrants. Traditional calendar-based irrigation will result in critical yield losses during '
          'the booting and anthesis stages of winter wheat. If soil moisture tension at a 30cm depth '
          'exceeds 80 kPa, an emergency application of 25mm irrigation is required within 48 hours to '
          'prevent irreversible floret abortion.',
      'crop_id': 'wheat',
      'language': 'en',
      'status': 'IN_REVIEW',
      'created_by': 'Dr. Elena Rostova',
      'created_at': '2023-10-24T00:00:00.000',
      'updated_at': '2023-10-24T00:00:00.000',
    },
    {
      'id': 'adv-2',
      'title': 'Optimizing Nitrogen Application for Winter Wheat Yields',
      'body':
          'Guidance on split nitrogen dosing timed to tillering and stem extension stages to reduce '
          'lodging risk while maintaining protein content targets.',
      'crop_id': 'wheat',
      'language': 'en',
      'status': 'IN_REVIEW',
      'created_by': 'Dr. Robert Chen',
      'created_at': '2023-10-24T00:00:00.000',
      'updated_at': '2023-10-24T00:00:00.000',
    },
    {
      'id': 'adv-3',
      'title': 'Early Detection of Sudden Death Syndrome in Soybean Crops',
      'body':
          'Field scouting checklist and foliar symptom photos to help extension workers flag suspected '
          'SDS cases before canopy-level yield impact occurs.',
      'crop_id': 'soybeans',
      'language': 'en',
      'status': 'IN_REVIEW',
      'created_by': 'Amanda Martinez, Agronomist',
      'created_at': '2023-10-23T00:00:00.000',
      'updated_at': '2023-10-23T00:00:00.000',
    },
    {
      'id': 'adv-4',
      'title': 'Assessing Drought Tolerance in New Corn Hybrids',
      'body':
          'Comparative trial results across three hybrid lines under deficit irrigation, with regional '
          'sowing-window recommendations.',
      'crop_id': 'maize',
      'language': 'en',
      'status': 'IN_REVIEW',
      'created_by': 'Sarah Williams, PhD',
      'created_at': '2023-10-20T00:00:00.000',
      'updated_at': '2023-10-20T00:00:00.000',
    },
    {
      'id': 'adv-5',
      'title': 'Integrating Cover Crops for Soil Health Improvement',
      'body':
          'Rotation planning guidance for legume cover crops to rebuild soil nitrogen and reduce erosion '
          'between primary growing seasons.',
      'crop_id': 'general',
      'language': 'en',
      'status': 'IN_REVIEW',
      'created_by': 'Tom Kovac',
      'created_at': '2023-10-18T00:00:00.000',
      'updated_at': '2023-10-18T00:00:00.000',
    },
  ];

  // ---------------------------------------------------------------------
  // Request routing
  // ---------------------------------------------------------------------

  @override
  Future<dynamic> get(String endpoint) async {
    await Future.delayed(_networkDelay);
    final uri = Uri.parse(endpoint);
    final seg = uri.pathSegments;

    // GET /api/farmers
    if (_isPath(seg, ['api', 'farmers'])) {
      var results = _farmers.map(_copy).toList();

      final query = uri.queryParameters['query'];
      final cropId = uri.queryParameters['crop_id'];
      final region = uri.queryParameters['region'];

      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        results = results.where((f) {
          return (f['full_name'] as String).toLowerCase().contains(q) ||
              (f['region'] as String).toLowerCase().contains(q) ||
              (f['woreda'] as String).toLowerCase().contains(q) ||
              (f['phone'] as String).toLowerCase().contains(q);
        }).toList();
      }

      if (cropId != null && cropId.isNotEmpty && cropId.toLowerCase() != 'all') {
        results = results.where((f) => (f['crop_ids'] as List).contains(cropId)).toList();
      }

      if (region != null && region.isNotEmpty && region.toLowerCase() != 'all') {
        results = results.where((f) => f['region'] == region).toList();
      }

      return results;
    }

    // GET /api/farmers/:id
    if (seg.length == 3 && seg[0] == 'api' && seg[1] == 'farmers') {
      final farmer = _findById(_farmers, seg[2]);
      return farmer == null ? null : _copy(farmer);
    }

    // GET /api/crops
    if (_isPath(seg, ['api', 'crops'])) {
      return _crops.map(_copy).toList();
    }

    // GET /api/content
    if (_isPath(seg, ['api', 'content'])) {
      var results = _advisories.map(_copy).toList();

      final status = uri.queryParameters['status'];
      final language = uri.queryParameters['language'];

      if (status != null && status.isNotEmpty) {
        results = results.where((c) => c['status'] == status).toList();
      }
      if (language != null && language.isNotEmpty) {
        results = results.where((c) => c['language'] == language).toList();
      }

      return results;
    }

    // GET /api/content/:id
    if (seg.length == 3 && seg[0] == 'api' && seg[1] == 'content') {
      final content = _findById(_advisories, seg[2]);
      return content == null ? null : _copy(content);
    }

    return null;
  }

  @override
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    await Future.delayed(_networkDelay);
    final uri = Uri.parse(endpoint);
    final seg = uri.pathSegments;

    // POST /api/farmers
    if (_isPath(seg, ['api', 'farmers'])) {
      final farmer = Map<String, dynamic>.from(body);
      farmer['id'] = (farmer['id'] ?? '').toString().isNotEmpty
          ? farmer['id'].toString()
          : DateTime.now().millisecondsSinceEpoch.toString();
      _farmers.insert(0, farmer);
      return _copy(farmer);
    }

    // POST /api/farmers/:id/crops
    if (seg.length == 4 && seg[0] == 'api' && seg[1] == 'farmers' && seg[3] == 'crops') {
      final index = _farmers.indexWhere((f) => f['id'] == seg[2]);
      if (index == -1) return false;
      _farmers[index] = {
        ..._farmers[index],
        'crop_ids': List<String>.from(body['crop_ids'] ?? const []),
      };
      return true;
    }

    // POST /api/content
    if (_isPath(seg, ['api', 'content'])) {
      final now = DateTime.now().toIso8601String();
      final content = {
        'id': 'adv-${DateTime.now().millisecondsSinceEpoch}',
        'title': body['title'] ?? '',
        'body': body['body'] ?? '',
        'crop_id': body['crop_id'] ?? '',
        'language': body['language'] ?? 'en',
        'status': 'DRAFT',
        'created_by': body['created_by'] ?? '',
        'approved_by': null,
        'approved_at': null,
        'created_at': now,
        'updated_at': now,
      };
      _advisories.insert(0, content);
      return _copy(content);
    }

    // POST /api/content/:id/submit-review | /approve | /reject | /publish
    if (seg.length == 4 && seg[0] == 'api' && seg[1] == 'content') {
      final action = seg[3];
      const statusByAction = {
        'submit-review': 'IN_REVIEW',
        'approve': 'APPROVED',
        'reject': 'REJECTED',
        'publish': 'PUBLISHED',
      };
      final status = statusByAction[action];
      if (status == null) return null;
      return _updateAdvisoryStatus(
        seg[2],
        status,
        approvedBy: action == 'approve' ? 'Current Expert' : null,
      );
    }

    return null;
  }

  @override
  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    await Future.delayed(_networkDelay);
    final uri = Uri.parse(endpoint);
    final seg = uri.pathSegments;

    // PATCH /api/farmers/:id
    if (seg.length == 3 && seg[0] == 'api' && seg[1] == 'farmers') {
      final index = _farmers.indexWhere((f) => f['id'] == seg[2]);
      if (index == -1) return null;

      final current = _farmers[index];
      final updated = {
        ...current,
        for (final entry in body.entries)
          if (entry.value != null) entry.key: entry.value,
      };
      _farmers[index] = updated;
      return _copy(updated);
    }

    return null;
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  bool _isPath(List<String> segments, List<String> expected) {
    if (segments.length != expected.length) return false;
    for (var i = 0; i < segments.length; i++) {
      if (segments[i] != expected[i]) return false;
    }
    return true;
  }

  Map<String, dynamic>? _findById(List<Map<String, dynamic>> list, String id) {
    for (final item in list) {
      if (item['id'] == id) return item;
    }
    return null;
  }

  /// Shallow-copies a record (and its crop_ids list) so callers can't
  /// mutate our in-memory "database" by editing the map they got back.
  Map<String, dynamic> _copy(Map<String, dynamic> item) {
    final copy = Map<String, dynamic>.from(item);
    if (copy['crop_ids'] is List) {
      copy['crop_ids'] = List<String>.from(copy['crop_ids'] as List);
    }
    return copy;
  }

  bool _updateAdvisoryStatus(String id, String status, {String? approvedBy}) {
    final index = _advisories.indexWhere((c) => c['id'] == id);
    if (index == -1) return false;
    final current = _advisories[index];
    final now = DateTime.now().toIso8601String();
    _advisories[index] = {
      ...current,
      'status': status,
      'approved_by': approvedBy ?? current['approved_by'],
      'approved_at': approvedBy != null ? now : current['approved_at'],
      'updated_at': now,
    };
    return true;
  }
}
