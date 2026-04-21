class Expense {
  final int? id;
  final double amount;
  final String note;
  final int categoryId;
  final String? categoryName;

  Expense({
    this.id,
    required this.amount,
    required this.note,
    required this.categoryId,
    this.categoryName,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'amount': amount,
    'note': note,
    'categoryId': categoryId,
  };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
    id: map['id'],
    amount: map['amount'],
    note: map['note'],
    categoryId: map['categoryId'],
    categoryName: map['categoryName'],
  );
}