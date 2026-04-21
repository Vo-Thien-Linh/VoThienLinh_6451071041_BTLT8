import 'package:flutter_test/flutter_test.dart';
import 'package:baitap2/app/app.dart';

void main() {
  testWidgets('app loads note list screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Danh sach ghi chu'), findsOneWidget);
  });
}
