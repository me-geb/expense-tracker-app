import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> loadExpenses();
  Future<void> saveExpense(Expense expense);
  Future<void> deleteExpense(String id);
}

class LocalExpenseRepository implements ExpenseRepository {
  static const String _storageKey = 'expenses';
  final SharedPreferences _prefs;

  LocalExpenseRepository(this._prefs);

  @override
  Future<List<Expense>> loadExpenses() async {
    final String? expensesJson = _prefs.getString(_storageKey);
    if (expensesJson == null) return [];
    
    final List<dynamic> decodedList = jsonDecode(expensesJson);
    return decodedList.map((e) => Expense.fromJson(e)).toList();
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    final expenses = await loadExpenses();
    final index = expenses.indexWhere((e) => e.id == expense.id);
    
    if (index >= 0) {
      expenses[index] = expense;
    } else {
      expenses.add(expense);
    }
    
    await _saveList(expenses);
  }

  @override
  Future<void> deleteExpense(String id) async {
    final expenses = await loadExpenses();
    expenses.removeWhere((e) => e.id == id);
    await _saveList(expenses);
  }

  Future<void> _saveList(List<Expense> expenses) async {
    final String encodedList = jsonEncode(expenses.map((e) => e.toJson()).toList());
    await _prefs.setString(_storageKey, encodedList);
  }
}
