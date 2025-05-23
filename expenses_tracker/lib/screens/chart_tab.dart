import 'package:expenses_tracker/providers/expenses_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartTab extends StatelessWidget {
  const ChartTab({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = Provider.of<ExpensesProvider>(context).expenses;

    final Map<String, double> groupedData = {};
    for (var e in expenses) {
      groupedData[e.category] = (groupedData[e.category] ?? 0) + e.amount;
    }

    final List<PieChartSectionData> sections = groupedData.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.key}\nRM ${entry.value.toStringAsFixed(1)}',
        color: _getColor(entry.key),
        radius: 80,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Expense Chart')),
      body: expenses.isEmpty
          ? Center(child: Text("No expenses yet."))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 4,
                ),
              ),
            ),
    );
  }

  Color _getColor(String category) {
    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.cyan, Colors.teal, Colors.amber,
    ];
    return colors[category.hashCode % colors.length];
  }
}
