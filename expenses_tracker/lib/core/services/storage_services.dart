import 'dart:convert';

import 'package:expenses_tracker/core/models/expenses_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageServices {
  static const String expensesKey = 'expenses';
  static const String budgetKey = 'budget';

  // save all expenses
  Future<void> saveExpenses(List<ExpensesModel> expenses) async{
    final prefs = await SharedPreferences.getInstance();
    final jsonList = expenses.map((e) => e.toJson()).toList();
    prefs.setString(expensesKey, jsonEncode(jsonList));
  }

  // load all expenses
  Future<List<ExpensesModel>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(expensesKey);
    if(jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => ExpensesModel.fromJson(json)).toList();
  }

  // add expenses
  Future<void> addExpenses(ExpensesModel newExpenses) async{
    final current = await loadExpenses();
    current.add(newExpenses);
    await saveExpenses(current);
  }

  // delete expenses
 Future<void> deleteExpenses(String id) async{
    final current = await loadExpenses();
    current.removeWhere((e) => e.id == id);
    await saveExpenses(current);
  }

  // edit expenses
  Future<void> editExpenses(ExpensesModel updatedExpenses) async{
    final current = await loadExpenses();
    final index = current.indexWhere((e) => e.id == updatedExpenses.id);
    if(index != -1){
      current[index] = updatedExpenses;
      await saveExpenses(current);
    }
  }

  // save budget
  Future<void> saveBudget(double budget) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(budgetKey, budget);
  }

  // load budget
  Future<double> loadBudget() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(budgetKey) ?? 0.0;
  }

  
}