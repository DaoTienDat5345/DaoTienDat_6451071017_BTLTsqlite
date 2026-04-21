import 'package:flutter_test/flutter_test.dart';

import 'package:bai2/app/bai2_app.dart';
import 'package:bai2/utils/database_factory.dart';

void main() {
  testWidgets('renders the note app shell', (WidgetTester tester) async {
    await configureDatabaseFactory();
    await tester.pumpWidget(const Bai2App());
    await tester.pump();

    expect(find.text('Ghi chú có danh mục'), findsOneWidget);
    expect(find.text('Ghi chú'), findsWidgets);
    expect(find.text('Danh mục'), findsWidgets);
  });
}
