import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // for routeObserver
import '../theme/app_theme.dart';
import '../models/category.dart';
import '../models/transaction.dart' as model;
import '../providers/user_provider.dart';
import '../services/database_service.dart';
import '../widgets/bottom_nav.dart';
import '../utils/category_icons.dart';
import '../utils/app_notifier.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with RouteAware {
  bool _isLoading = true;
  List<model.Transaction> _transactions = [];
  List<Category> _categories = [];

  double get _totalIncome => _transactions
      .where((t) => t.type == CategoryType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _totalExpense => _transactions
      .where((t) => t.type == CategoryType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _balance => _totalIncome - _totalExpense;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes so we know when this screen is
    // popped back into view (e.g. after adding a transaction).
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Called automatically when the screen above this one (e.g. Add
  // Transaction) is popped and this Dashboard becomes visible again.
  @override
  void didPopNext() {
    _loadData();
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(date.year, date.month, date.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('d MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final colors = context.colors;
    final currency = NumberFormat('#,##0');

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.mauveMagic))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_greeting(),
                                  style: TextStyle(color: colors.textMuted, fontSize: 11)),
                              Text(
                                user?.name.split(' ').first ?? 'there',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              AppNotifier.info(context, 'Notifications — coming next'),
                          icon: Icon(Icons.notifications_none_rounded, color: colors.textBody),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.indigoVelvet, AppColors.royalViolet],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total balance',
                                  style: TextStyle(color: AppColors.petalFrost, fontSize: 11)),
                              const SizedBox(height: 6),
                              Text('Rs ${currency.format(_balance)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  const Icon(Icons.arrow_upward_rounded,
                                      size: 14, color: AppColors.petalFrost),
                                  const SizedBox(width: 4),
                                  Text('Income  Rs ${currency.format(_totalIncome)}',
                                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  const SizedBox(width: 20),
                                  const Icon(Icons.arrow_downward_rounded,
                                      size: 14, color: AppColors.petalFrost),
                                  const SizedBox(width: 4),
                                  Text('Expense  Rs ${currency.format(_totalExpense)}',
                                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text('RECENT TRANSACTIONS',
                            style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6)),
                        const SizedBox(height: 8),
                        if (_transactions.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Center(
                              child: Text('No transactions yet — tap + to add one',
                                  style: TextStyle(color: colors.textMuted)),
                            ),
                          )
                        else
                          ..._transactions.take(8).map((t) {
                            final category = _categoryFor(t.categoryId);
                            final isIncome = t.type == CategoryType.income;
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: colors.divider)),
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
                                    child: Icon(iconForCategory(category?.icon ?? 'other'),
                                        size: 16, color: AppColors.mauveMagic),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(category?.name ?? 'Other',
                                            style:
                                                TextStyle(color: colors.textBody, fontSize: 13)),
                                        Text(_formatDate(t.date),
                                            style: TextStyle(
                                                color: colors.textMuted, fontSize: 10.5)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${isIncome ? '+' : '-'}${currency.format(t.amount)}',
                                    style: TextStyle(
                                        color: isIncome ? colors.positive : colors.negative,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  FinTrackBottomNav(currentIndex: 0, onTransactionAdded: _loadData),
                ],
              ),
      ),
    );
  }
}