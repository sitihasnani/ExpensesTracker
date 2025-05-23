import 'package:expenses_tracker/providers/expenses_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentBudget = Provider.of<ExpensesProvider>(context, listen: false).budget;
    _budgetController.text = currentBudget.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    final value = double.tryParse(_budgetController.text);
    if (value == null || value < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter a valid positive number")),
      );
      return;
    }
    Provider.of<ExpensesProvider>(context, listen: false).setBudget(value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Budget updated")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Monthly Budget (RM)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveBudget,
              child: Text("Save Budget"),
            ),
          ],
        ),
      ),
    );
  }
}
