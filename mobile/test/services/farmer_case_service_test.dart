import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/services/farmer_case_service.dart';

import 'content_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FarmerCaseService Tests', () {
    late FarmerCaseService caseService;
    late MockApiClient mockApiClient;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockApiClient = MockApiClient();
      caseService = FarmerCaseService(apiClient: mockApiClient);
    });

    test('submitCase accepts valid JPEG attachment', () async {
      when(mockApiClient.post(any, any)).thenAnswer((_) async => {
        'id': 'case-test-1',
        'trackingNumber': 'CASE-2026-9999',
        'subject': 'Yellow rust in wheat',
        'description': 'Leaves show yellow striped pustules.',
        'cropName': 'Wheat',
        'location': 'Adama, Oromia',
        'attachmentPaths': ['photo.jpeg'],
        'status': 'OPEN',
        'urgency': 'HIGH',
        'createdAt': DateTime.now().toIso8601String(),
      });

      final newCase = await caseService.submitCase(
        subject: 'Yellow rust in wheat',
        description: 'Leaves show yellow striped pustules.',
        crop: 'Wheat',
        location: 'Adama, Oromia',
        attachments: ['photo.jpeg'],
        urgency: 'HIGH',
      );

      expect(newCase.id, 'case-test-1');
      expect(newCase.status, 'OPEN');
      expect(newCase.attachments, ['photo.jpeg']);
    });

    test('submitCase accepts valid PNG and PDF attachments', () async {
      when(mockApiClient.post(any, any)).thenAnswer((_) async => {
        'id': 'case-test-2',
        'trackingNumber': 'CASE-2026-9998',
        'subject': 'Soil analysis document',
        'description': 'Attached laboratory test report.',
        'cropName': 'Teff',
        'location': 'Bishoftu',
        'attachmentPaths': ['doc.pdf', 'leaf.png'],
        'status': 'OPEN',
        'urgency': 'MEDIUM',
        'createdAt': DateTime.now().toIso8601String(),
      });

      final newCase = await caseService.submitCase(
        subject: 'Soil analysis document',
        description: 'Attached laboratory test report.',
        crop: 'Teff',
        location: 'Bishoftu',
        attachments: ['doc.pdf', 'leaf.png'],
      );

      expect(newCase.attachments.length, 2);
    });

    test('submitCase rejects disallowed file formats according to Shared Attachment Contract', () async {
      // Allowed formats are strictly JPEG, PNG, PDF
      expect(
        () => caseService.submitCase(
          subject: 'Video of field',
          description: 'Attaching video or script.',
          crop: 'Maize',
          location: 'Hawassa',
          attachments: ['field_video.mp4'],
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => caseService.submitCase(
          subject: 'Executable file',
          description: 'Attaching exe file.',
          crop: 'Maize',
          location: 'Hawassa',
          attachments: ['program.exe'],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('getCases fetches cases and supports canonical statuses', () async {
      when(mockApiClient.get(any)).thenAnswer((_) async => [
        {
          'id': 'case-101',
          'trackingNumber': 'CASE-2026-0101',
          'subject': 'Pest identification',
          'description': 'Stalk borer in maize',
          'cropName': 'Maize',
          'location': 'Jimma',
          'attachmentPaths': ['stalk.jpg'],
          'status': 'ASSIGNED',
          'urgency': 'HIGH',
          'assignedWorkerName': 'Abebe Tadesse',
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'case-102',
          'trackingNumber': 'CASE-2026-0102',
          'subject': 'Coffee leaf rust',
          'description': 'Rust spots on bottom leaves',
          'cropName': 'Coffee',
          'location': 'Jimma',
          'attachmentPaths': ['leaf.png'],
          'status': 'RESOLVED',
          'urgency': 'MEDIUM',
          'assignedWorkerName': 'Chaltu Desta',
          'responseNotes': 'Coffee leaf rust (Hemileia vastatrix)',
          'createdAt': DateTime.now().toIso8601String(),
        }
      ]);

      final cases = await caseService.getCases();
      expect(cases.length, 2);

      expect(cases[0].status, 'ASSIGNED');
      expect(cases[0].isClosed, isFalse);

      expect(cases[1].status, 'RESOLVED');
      expect(cases[1].isClosed, isTrue);
      expect(cases[1].diagnosis, 'Coffee leaf rust (Hemileia vastatrix)');
    });

    test('getCases falls back gracefully on API error', () async {
      when(mockApiClient.get(any)).thenThrow(ApiException('Network Error'));

      final cases = await caseService.getCases();
      expect(cases.isNotEmpty, isTrue);
      expect(cases.first.trackingNumber.startsWith('CASE-'), isTrue);
    });
  });
}
