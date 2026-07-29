import 'category.dart';

class Transaction {
  final int? id;
  final int userId;
  final int categoryId;
  final double amount;
  final CategoryType type;
  final DateTime date;
  final String? note;
  final String? receiptPath;

  Transaction({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    this.receiptPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'type': type == CategoryType.income ? 'income' : 'expense',
      'date': date.toIso8601String(),
      'note': note,
      'receipt_path': receiptPath,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      categoryId: map['category_id'] as int,
      amount: map['amount'] as double,
      type: map['type'] == 'income' ? CategoryType.income : CategoryType.expense,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      receiptPath: map['receipt_path'] as String?,
    );
  }
}