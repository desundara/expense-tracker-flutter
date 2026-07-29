import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/category.dart';
import '../models/transaction.dart' as model;
import '../providers/user_provider.dart';
import '../services/database_service.dart';
import '../utils/category_icons.dart';
import '../utils/app_notifier.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;
  List<Category> _categories = [];
  bool _isLoadingCategories = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final all = await DatabaseService.instance.getCategories();
    final expenseCategories = all.where((c) => c.type == CategoryType.expense).toList();
    if (!mounted) return;
    setState(() {
      _categories = expenseCategories;
      _selectedCategory = expenseCategories.isNotEmpty ? expenseCategories.first : null;
      _isLoadingCategories = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _handleSave() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      AppNotifier.error(context, 'Enter a valid amount');
      return;
    }
    if (_selectedCategory == null) {
      AppNotifier.error(context, 'Choose a category');
      return;
    }

    final user = context.read<UserProvider>().currentUser;
    if (user == null || user.id == null) return;

    setState(() => _isSaving = true);
    try {
      await DatabaseService.instance.insertTransaction(
        model.Transaction(
          userId: user.id!,
          categoryId: _selectedCategory!.id!,
          amount: amount,
          type: CategoryType.expense,
          date: _selectedDate,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: colors.textBody),
                  ),
                  Text('Add expense', style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Column(
                        children: [
                          Text('Amount', style: TextStyle(color: colors.textMuted, fontSize: 11)),
                          const SizedBox(height: 6),
                          IntrinsicWidth(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: colors.negative,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixText: 'Rs ',
                                prefixStyle: TextStyle(color: colors.negative, fontSize: 24),
                                hintText: '0',
                                hintStyle: TextStyle(color: colors.textMuted),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('CATEGORY',
                        style: TextStyle(
                            color: colors.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _isLoadingCategories
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: CircularProgressIndicator(color: AppColors.mauveMagic),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categories.map((c) {
                              final selected = _selectedCategory?.id == c.id;
                              return ChoiceChip(
                                selected: selected,
                                onSelected: (_) => setState(() => _selectedCategory = c),
                                avatar: Icon(iconForCategory(c.icon),
                                    size: 15,
                                    color: selected ? AppColors.petalFrost : colors.textBody),
                                label: Text(c.name),
                                labelStyle: TextStyle(
                                    color: selected ? AppColors.petalFrost : colors.textBody,
                                    fontSize: 12),
                                backgroundColor: colors.inputFill,
                                selectedColor: AppColors.royalViolet,
                                side: BorderSide(color: colors.inputBorder),
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 18),
                    InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.inputFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.inputBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 16, color: AppColors.mauveMagic),
                            const SizedBox(width: 12),
                            Text(DateFormat('d MMM yyyy').format(_selectedDate),
                                style: TextStyle(color: colors.textBody, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      style: TextStyle(color: colors.textBody),
                      decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                        prefixIcon: Icon(Icons.notes_rounded, color: AppColors.mauveMagic),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => AppNotifier.info(context, 'Receipt photo — coming next'),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.inputFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.inputBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.camera_alt_outlined,
                                size: 16, color: AppColors.mauveMagic),
                            const SizedBox(width: 12),
                            Text('Attach receipt',
                                style: TextStyle(color: colors.textBody, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save expense'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}