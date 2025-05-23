class ExpensesModel{
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String? notes;

  ExpensesModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.notes
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'amount': amount,
        'date': date.toIso8601String(),
        'notes': notes,
      };

  factory ExpensesModel.fromJson(Map<String, dynamic> json) {
    return ExpensesModel(
      id: json['id'],
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      notes: json['notes'],
    );
  }
}