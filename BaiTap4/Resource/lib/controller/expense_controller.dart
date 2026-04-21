import '../data/models/expense.dart';
import '../data/repository/expense_repository.dart';

class ExpenseController {
  final ExpenseRepository _repo = ExpenseRepository();

  Future<List<Expense>> getExpenses() {
    return _repo.getAll();
  }

  Future<void> addExpense(Expense expense) {
    return _repo.insert(expense);
  }

  Future<void> updateExpense(Expense expense) {
    return _repo.update(expense);
  }

  Future<void> deleteExpense(int id) {
    return _repo.delete(id);
  }

  Future<List<Map<String, dynamic>>> getSummary() {
    return _repo.sumByCategory();
  }
}
