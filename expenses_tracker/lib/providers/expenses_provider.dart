import 'package:expenses_tracker/core/models/expenses_model.dart';
import 'package:expenses_tracker/core/services/storage_services.dart';
import 'package:flutter/material.dart';

enum SortType { date, amount }

class ExpensesProvider with ChangeNotifier {
  final StorageServices storageServices = StorageServices();

  List<ExpensesModel> _expenses = [];
  double _budget = 0.0;

  List<ExpensesModel> get expenses => _expenses;
  double get budget => _budget;
  double get totalExpenses => _expenses.fold(0.0, (sum, item) => sum + item.amount);
  double get balance => _budget - totalExpenses;

  // load initial data
  Future<void> loadInitialData() async{
    _expenses = await storageServices.loadExpenses();
    _budget = await storageServices.loadBudget();
  }

  // load data
  Future<void> loadExpenses() async{
    _expenses = await storageServices.loadExpenses();
    notifyListeners();
  }

  // add new expenses
  Future<void> addExpenses(ExpensesModel expenses) async{
    _expenses.add(expenses);
    await storageServices.saveExpenses(_expenses);
    notifyListeners();
  }

  // delete expenses
  Future<void> deleteExpenses(String id) async{
    _expenses.removeWhere((e) => e.id == id);
    await storageServices.saveExpenses(_expenses);
    notifyListeners();
  }

  // edit/update expenses
  Future<void> updateExpenses(ExpensesModel expensesUpdated) async{
    final index = _expenses.indexWhere((e) => e.id == expensesUpdated.id);
    if(index != -1){
      _expenses[index] = expensesUpdated;
      await storageServices.saveExpenses(_expenses);
      notifyListeners();
    }
  }

  // set monthly budget
  void setBudget(double value) async{
    _budget = value;
    await storageServices.saveBudget(value);
    notifyListeners();
  }

// filter and sort
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  List<ExpensesModel> get filteredExpenses {
  List<ExpensesModel> filtered = _selectedCategory == null || _selectedCategory == 'All'
      ? List.from(_expenses)
      : _expenses.where((e) => e.category == _selectedCategory).toList();

  if (_sortType == SortType.date) {
    filtered.sort((a, b) => _ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date));
  } else {
    filtered.sort((a, b) => _ascending ? a.amount.compareTo(b.amount) : b.amount.compareTo(a.amount));
  }

  return filtered;
}

  void setCategoryFilter(String? category) {
  _selectedCategory = category;
  notifyListeners();
}

// sort
  SortType _sortType = SortType.date;
  bool _ascending = false;
  SortType get sortType => _sortType;

  void setSort(SortType type, {bool ascending = false}) {
  _sortType = type;
  _ascending = ascending;
  notifyListeners();
}

}