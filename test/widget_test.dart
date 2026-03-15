import 'package:flutter_test/flutter_test.dart';

import 'package:justtime/main.dart';

void main() {
  testWidgets('App launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(const JustTimeApp());
  });
}
