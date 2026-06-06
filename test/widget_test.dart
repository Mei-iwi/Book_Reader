import 'package:book_reader/presentation/pages/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Login landing screen shows auth actions', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Login()));

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });
}
