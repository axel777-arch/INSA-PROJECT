import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('App starts on login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pump(); // Render initial frame (Splash Screen)

    // Verify Splash Screen is shown
    expect(find.text('Agri-Insight Beacon'), findsOneWidget);
    expect(find.text('Precision agriculture, grounded in data.'), findsOneWidget);

    // Pass 2 seconds to trigger splash timer and navigate to Language screen
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify Choose Language screen is shown
    expect(find.text('Select Language'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Tap Continue to go to Login screen
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify that our login screen is shown with its headers and fields
    expect(find.text('Agri-Insight Beacon'), findsOneWidget);
    expect(find.text('Expert Agricultural Advisory System'), findsOneWidget);
    expect(find.text('Phone or Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
