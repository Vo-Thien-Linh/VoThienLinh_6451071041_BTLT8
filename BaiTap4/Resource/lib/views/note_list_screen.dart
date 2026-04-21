import 'package:flutter/material.dart';
import '../controller/expense_controller.dart';
import '../data/models/category_models.dart';
import '../data/models/expense.dart';
import '../data/repository/category_repository.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ExpenseController controller = ExpenseController();
  final CategoryRepository catRepo = CategoryRepository();

  List<Expense> expenses = [];
  List<Category> categories = [];
  List<Map<String, dynamic>> summary = [];

  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController noteCtrl = TextEditingController();
  int? selectedCategory;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    expenses = await controller.getExpenses();
    categories = await catRepo.getAll();

    if (categories.isEmpty) {
      await catRepo.insert(Category(name: 'An uong'));
      await catRepo.insert(Category(name: 'Di chuyen'));
      await catRepo.insert(Category(name: 'Mua sam'));
      categories = await catRepo.getAll();
      selectedCategory = categories.first.id;
    }

    summary = await controller.getSummary();

    setState(() {});
  }

  Future<void> addExpense() async {
    if (selectedCategory == null || amountCtrl.text.isEmpty) {
      return;
    }

    final parsedAmount = double.tryParse(amountCtrl.text.trim());
    if (parsedAmount == null || parsedAmount <= 0) {
      return;
    }

    await controller.addExpense(
      Expense(
        amount: parsedAmount,
        note: noteCtrl.text.trim(),
        categoryId: selectedCategory!,
      ),
    );

    amountCtrl.clear();
    noteCtrl.clear();
    loadData();
  }

  Future<void> updateExpense(Expense expense) async {
    final parsedAmount = double.tryParse(amountCtrl.text.trim());
    if (selectedCategory == null || parsedAmount == null || parsedAmount <= 0) {
      return;
    }

    await controller.updateExpense(
      Expense(
        id: expense.id,
        amount: parsedAmount,
        note: noteCtrl.text.trim(),
        categoryId: selectedCategory!,
      ),
    );

    amountCtrl.clear();
    noteCtrl.clear();
    loadData();
  }

  Future<void> showExpenseForm({Expense? editingExpense}) async {
    if (editingExpense != null) {
      amountCtrl.text = editingExpense.amount.toString();
      noteCtrl.text = editingExpense.note;
      selectedCategory = editingExpense.categoryId;
    } else {
      amountCtrl.clear();
      noteCtrl.clear();
      selectedCategory ??= categories.isNotEmpty ? categories.first.id : null;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            editingExpense == null ? 'Them chi tieu' : 'Sua chi tieu',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'So tien'),
                ),
                TextFormField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: 'Ghi chu'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Danh muc'),
                  items: categories
                      .map(
                        (c) => DropdownMenuItem<int>(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (editingExpense == null) {
                  await addExpense();
                } else {
                  await updateExpense(editingExpense);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(editingExpense == null ? 'Them' : 'Luu'),
            ),
          ],
        );
      },
    );
  }

  double _summaryTotalValue(Map<String, dynamic> e) {
    final value = e['total'];
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0;
  }

  double get overallTotal {
    return summary.fold<double>(
      0,
      (sum, item) => sum + _summaryTotalValue(item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quan ly chi tieu - 6451071041')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showExpenseForm(),
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tong chi tieu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${overallTotal.toStringAsFixed(0)} VND',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: expenses.isEmpty
                ? const Center(child: Text('Chua co chi tieu nao'))
                : ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final e = expenses[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text('${e.amount.toStringAsFixed(0)} VND'),
                          subtitle: Text('${e.note} - ${e.categoryName ?? ''}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    showExpenseForm(editingExpense: e),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await controller.deleteExpense(e.id!);
                                  loadData();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tong theo danh muc',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (summary.isEmpty)
                      const Text('Chua co du lieu tong hop')
                    else
                      ...summary.map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '${e['name']}: ${_summaryTotalValue(e).toStringAsFixed(0)} VND',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
