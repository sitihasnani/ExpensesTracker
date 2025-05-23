import 'package:expenses_tracker/core/models/catergory_model.dart';
import 'package:expenses_tracker/core/models/expenses_model.dart';
import 'package:expenses_tracker/core/services/api_services.dart';
import 'package:expenses_tracker/providers/expenses_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ExpenseFormScreen extends StatefulWidget {
  final ExpensesModel? existingExpense;

  const ExpenseFormScreen({this.existingExpense, super.key});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  List<CategoryModel> _categories = [];

  bool get isEditing => widget.existingExpense != null;
  double _enteredAmount = 0.0;

  final _amountController = MoneyMaskedTextController(
  leftSymbol: 'RM ',
  decimalSeparator: '.',
  thousandSeparator: ',',
);

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _amountController.addListener(_onAmountChanged);

    if (isEditing) {
      final e = widget.existingExpense!;
      _amountController.text = e.amount.toString();
      _noteController.text = e.notes ?? '';
      _selectedDate = e.date;
      _selectedCategory = e.category;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    setState(() {
      _enteredAmount = _amountController.numberValue;
    });
  }

  void _fetchCategories() async {
    try {
      final categories = await ApiServices().fetchCategories();
      setState(() => _categories = categories);
    } catch (e) {
      print('Failed to load categories: $e');
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;

    final provider = Provider.of<ExpensesProvider>(context, listen: false);
    final expense = ExpensesModel(
      id: isEditing ? widget.existingExpense!.id : Uuid().v4(),
      category: _selectedCategory!,
      amount: _amountController.numberValue,
      date: _selectedDate,
      notes: _noteController.text,
    );

    if (isEditing) {
      await provider.updateExpenses(expense);
    } else {
      await provider.addExpenses(expense);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpensesProvider>();
    final currentBalance = provider.balance;
    final previewBalance = currentBalance - _enteredAmount;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Expense' : 'Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _categories.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories.map((c) {
                        return DropdownMenuItem(
                          value: c.name,
                          child: Text(c.name),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value),
                      decoration: InputDecoration(labelText: 'Category'),
                      validator: (value) => value == null ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Amount (RM)'),
                      validator: (_) => _amountController.numberValue <= 0
                           ? 'Enter valid amount' : null,
                    ),
                    Text(
                      "Balance After This Expense: RM ${previewBalance.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: previewBalance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    ListTile(
                      title: Text('Date: ${_selectedDate.toLocal()}'.split(' ')[0]),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                    ),
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(labelText: 'Notes (optional)'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(isEditing ? 'Update Expense' : 'Add Expense'),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
