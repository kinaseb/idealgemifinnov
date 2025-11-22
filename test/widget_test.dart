import 'package:flutter_test/flutter_test.dart';

import 'package:ideal_calcule/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app title is present.
    expect(find.text('Ideal Calcule'), findsOneWidget);
    
    // Verify tabs are present
    expect(find.text('Métrage'), findsOneWidget);
    expect(find.text('Prix'), findsOneWidget);
  });
}
