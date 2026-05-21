  // This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:command_center/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CommandCenterApp());

    // Verify that the title or some element exists.
    // It's a GetMaterialApp that routes to DashboardView which has a GoogleMap.
    // Testing GoogleMap in a simple widget test might be tricky,
    // so we'll just check if the app built without crashing.
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
