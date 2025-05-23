import 'package:expenses_tracker/providers/expenses_provider.dart';
import 'package:expenses_tracker/screens/expenses_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpensesProvider>(context);
    final expenses = provider.filteredExpenses;
    final allCategories = ['All', ...provider.expenses.map((e) => e.category).toSet()];

    return Scaffold(
      appBar: AppBar(title: Text('Expenses')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Budget: RM ${provider.budget.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Total Expenses: RM ${provider.totalExpenses.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Remaining Balance: RM ${provider.balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: provider.balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 20,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Filter:'),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: provider.selectedCategory ?? 'All',
                      items: allCategories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (val) => provider.setCategoryFilter(val),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Sort by:'),
                    const SizedBox(width: 10),
                    DropdownButton<SortType>(
                      value: provider.sortType,
                      items: const [
                        DropdownMenuItem(
                          value: SortType.date,
                          child: Text('Date'),
                        ),
                        DropdownMenuItem(
                          value: SortType.amount,
                          child: Text('Amount'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          provider.setSort(val, ascending: false);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          // Expenses list
          Expanded(
            child: expenses.isEmpty
                ? const Center(child: Text('No expenses recorded.'))
                : ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (_, index) {
                      final e = expenses[index];
                      return ListTile(
                        title: Text(e.category),
                        subtitle: Text('${DateFormat.yMMMd().format(e.date)} • RM ${e.amount.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ExpenseFormScreen(existingExpense: e),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Delete Expense"),
                                    content: const Text("Are you sure you want to delete this?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          provider.deleteExpenses(e.id);
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ExpenseFormScreen()),
          );
        },
      ),
    );
  }
}
