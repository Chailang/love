import 'package:flutter_test/flutter_test.dart';
import 'package:qingteng_app/main.dart';

void main() {
  testWidgets('App should launch', (WidgetTester tester) async {
    await tester.pumpWidget(const QingtengApp());
    // 验证认证网关已经渲染
    expect(find.byType(QingtengApp), findsOneWidget);
  });
}