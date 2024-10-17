import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart'; // 본인의 앱의 main.dart 경로로 수정

void main() {
  testWidgets('환영 메시지 표시 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // 스플래시 화면 대기
    await tester.pumpAndSettle(Duration(seconds: 2));

    // 로그인 버튼을 찾아서 클릭
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // 환영 화면이 표시되는지 확인
    expect(find.text('환영합니다, 사용자님!'), findsOneWidget);
  });
}
