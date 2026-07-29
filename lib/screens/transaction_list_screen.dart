import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/category.dart';
import '../models/transaction.dart' as model;
import '../providers/user_provider.dart';
import '../services/database_service.dart';
import '../widgets/bottom_nav.dart';
import '../utils/category_icons.dart';
import '../utils/app_notifier.dart';

enum _Filter { all, income, expense }

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  bool _isLoading = true;
  bool _showSearch = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  _Filter _filter = _Filter.all;

  List<model.Transaction> _transactions = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = context.read<UserProvider>().currentUser;
    if (user == null || user.id == null) {
      setState(() => _isLoading = false);
      return;
    }
    final results = await Future.wait([
      DatabaseService.instance.getTransactions(user.id!),
      DatabaseService.instance.getCategories(),
    ]);
    if (!mounted) return;
    setState(() {
      _transactions = results[0] as List<model.Transaction>;
      _categories = results[1] as List<Category>;
      _isLoading = false;
    });
  }

  Category? _categoryFor(int id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(date.year, date.month, date.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('d MMM yyyy').format(date);
  }

  List<model.Transaction> get _filtered {
    return _transactions.where((t) {
      if (_filter == _Filter.income && t.type != CategoryType.income) return false;
      if (_filter == _Filter.expense && t.type != CategoryType.expense) return false;

      if (_searchQuery.isEmpty) return true;
      final category = _categoryFor(t.categoryId);
      final inCategory = category?.name.toLowerCase().contains(_searchQuery) ?? false;
      final inNote = t.note?.toLowerCase().contains(_searchQuery) ?? false;
      return inCategory || inNote;
    }).toList();
  }

  Map<String, List<model.Transaction>> get _grouped {
    final map = <String, List<model.Transaction>>{};
    for (final t in _filtered) {
      final label = _dateLabel(t.date);
      map.putIfAbsent(label, () => []).add(t);
    }
    return map;
  }

  Future<void> _openDetail(model.Transaction t) async {
    final colors = context.colors;
    final category = _categoryFor(t.categoryId);
    final isIncome = t.type == CategoryType.income;
    final currency = NumberFormat('#,##0');

    await showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final c = sheetContext.colors;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.mauveMagic.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(iconForCategory(category?.icon ?? 'other'),
                      size: 22, color: AppColors.mauveMagic),
                ),
                const SizedBox(height: 14),
                Text(category?.name ?? 'Other',
                    style: TextStyle(color: c.textBody, fontSize: 14.5)),
                const SizedBox(height: 4),
                Text(
                  '${isIncome ? '+' : '-'}Rs ${currency.format(t.amount)}',
                  style: TextStyle(
                      color: isIncome ? c.positive : c.negative,
                      fontSize: 26,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                Divider(color: c.divider),
                _detailRow(c, Icons.calendar_today_outlined,
                    DateFormat('d MMM yyyy').format(t.date)),
                if (t.note != null && t.note!.isNotEmpty)
                  _detailRow(c, Icons.notes_rounded, t.note!),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          AppNotifier.info(context, 'Edit transaction — coming next');
                        },
                        icon: Icon(Icons.edit_outlined, color: c.textBody, size: 16),
                        label: Text('Edit', style: TextStyle(color: c.textBody)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: c.inputBorder),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape:
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          if (t.id != null) {
                            await DatabaseService.instance.deleteTransaction(t.id!);
                          }
                          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                          await _loadData();
                          if (context.mounted) {
                            AppNotifier.success(context, 'Transaction deleted');
                          }
                        },
                        icon: Icon(Icons.delete_outline, color: c.negative, size: 16),
                        label: Text('Delete', style: TextStyle(color: c.negative)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: c.negative.withOpacity(0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape:
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(AppSemanticColors c, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.mauveMagic),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: c.textBody, fontSize: 13.5))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currency = NumberFormat('#,##0');
    final grouped = _grouped;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Transactions', style: Theme.of(context).textTheme.headlineMedium),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) {
                        _searchController.clear();
                      }
                    }),
                    icon: Icon(_showSearch ? Icons.close : Icons.search,
                        color: colors.textBody),
                  ),
                ],
              ),
            ),
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: TextStyle(color: colors.textBody),
                  decoration: InputDecoration(
                    hintText: 'Search by category or note',
                    hintStyle: TextStyle(color: colors.textMuted),
                    prefixIcon: Icon(Icons.search, color: colors.textMuted),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _filterChip(colors, 'All', _Filter.all),
                  const SizedBox(width: 8),
                  _filterChip(colors, 'Income', _Filter.income),
                  const SizedBox(width: 8),
                  _filterChip(colors, 'Expense', _Filter.expense),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.mauveMagic))
                  : grouped.isEmpty
                      ? Center(
                          child: Text('No transactions found',
                              style: TextStyle(color: colors.textMuted)),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                          children: grouped.entries.expand((entry) {
                            return [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8, top: 6),
                                child: Text(
                                  entry.key.toUpperCase(),
                                  style: TextStyle(
                                      color: colors.textMuted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.6),
                                ),
                              ),
                              ...entry.value.map((t) {
                                final category = _categoryFor(t.categoryId);
                                final isIncome = t.type == CategoryType.income;
                                return InkWell(
                                  onTap: () => _openDetail(t),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      border:
                                          Border(bottom: BorderSide(color: colors.divider)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: AppColors.mauveMagic.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(11),
                                          ),
                                          child: Icon(
                                              iconForCategory(category?.icon ?? 'other'),
                                              size: 16,
                                              color: AppColors.mauveMagic),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(category?.name ?? 'Other',
                                                  style: TextStyle(
                                                      color: colors.textBody, fontSize: 14.5)),
                                              if (t.note != null && t.note!.isNotEmpty)
                                                Text(t.note!,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: colors.textMuted, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${isIncome ? '+' : '-'}${currency.format(t.amount)}',
                                          style: TextStyle(
                                              color: isIncome ? colors.positive : colors.negative,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ];
                          }).toList(),
                        ),
            ),
            FinTrackBottomNav(currentIndex: 1, onTransactionAdded: _loadData),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(AppSemanticColors colors, String label, _Filter value) {
    final selected = _filter == value;
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      label: Text(label),
      labelStyle: TextStyle(
          color: selected ? AppColors.petalFrost : colors.textBody, fontSize: 13),
      backgroundColor: colors.inputFill,
      selectedColor: AppColors.royalViolet,
      side: BorderSide(color: colors.inputBorder),
    );
  }
}