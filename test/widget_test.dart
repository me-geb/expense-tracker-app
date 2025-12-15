// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker_app/main.dart';
import 'package:expense_tracker_app/src/repositories/expense_repository.dart';
import 'package:expense_tracker_app/src/models/expense.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final repository = FakeExpenseRepository();
    await tester.pumpWidget(MyApp(repository: repository));

    // Verify that the app title is present (or just that it builds without crashing).
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

class FakeExpenseRepository implements ExpenseRepository {
  @override
  Future<List<Expense>> loadExpenses() async => [];

  @override
  Future<void> saveExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String id) async {}
}
