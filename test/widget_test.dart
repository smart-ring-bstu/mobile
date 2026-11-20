
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_ring/main.dart';

void main() {
  testWidgets('Smart Ring app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartRingApp());
    await tester.pump();

    expect(find.byType(SmartRingApp), findsOneWidget);
  });
}
