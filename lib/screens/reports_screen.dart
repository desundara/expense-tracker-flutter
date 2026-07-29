import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/category.dart';
import '../models/transaction.dart' as model;
import '../providers/user_provider.dart';
import '../services/database_service.dart';
import '../widgets/bottom_nav.dart';
import '../utils/category_icons.dart';

enum _Period { week, month, year }

/// Colours cycled through for pie chart slices — the palette
/// deliberately avoids the brand's dark tones so slices stay
/// distinct against a dark or light card background alike.
const List<Color> _chartPalette = [
  AppColors.mauveMagic,
  AppColors.periwinkle,
  AppColors.lavenderPurple,
  AppColors.petalFrost,
  AppColors.periwinkle2,
  AppColors.mauve,
];

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isLoading = true;
  _Period _period = _Period.month;
  List<model.Transaction> _transactions = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
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

  DateTimeRange _rangeFor(_Period period) {
    final now = DateTime.now();
    switch (period) {
      case _Period.week:
        final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        return DateTimeRange(start: start, end: now);
      case _Period.month:
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
      case _Period.year:
        return DateTimeRange(start: DateTime(now.year, 1, 1), end: now);
    }
  }

  List<model.Transaction> get _inRange {
    final range = _rangeFor(_period);
    return _transactions.where((t) {
      final d = t.date;
      return !d.isBefore(range.start) && !d.isAfter(range.end.add(const Duration(days: 1)));
    }).toList();
  }

  Map<int, double> get _categoryTotals {
    final map = <int, double>{};
    for (final t in _inRange.where((t) => t.type == CategoryType.expense)) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  List<MapEntry<String, double>> get _trend {
    final expenses = _inRange.where((t) => t.type == CategoryType.expense).toList();
    final now = DateTime.now();

    if (_period == _Period.week) {
      final days = List.generate(
          7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
      return days.map((d) {
        final total = expenses
            .where((t) => t.date.year == d.year && t.date.month == d.month && t.date.day == d.day)
            .fold(0.0, (sum, t) => sum + t.amount);
        return MapEntry(DateFormat('E').format(d).substring(0, 1), total);
      }).toList();
    }

    if (_period == _Period.month) {
      final buckets = List.filled(5, 0.0);
      for (final t in expenses) {
        if (t.date.year == now.year && t.date.month == now.month) {
          final weekIndex = ((t.date.day - 1) ~/ 7).clamp(0, 4);
          buckets[weekIndex] += t.amount;
        }
      }
      return List.generate(5, (i) => MapEntry('W${i + 1}', buckets[i]));
    }

    final buckets = List.filled(12, 0.0);
    for (final t in expenses) {
      if (t.date.year == now.year) buckets[t.date.month - 1] += t.amount;
    }
    return List.generate(
        12, (i) => MapEntry(DateFormat('MMM').format(DateTime(now.year, i + 1)), buckets[i]));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currency = NumberFormat('#,##0');
    final categoryTotals = _categoryTotals;
    final totalExpense = categoryTotals.values.fold(0.0, (sum, v) => sum + v);
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final trend = _trend;
    final maxTrendValue = trend.isEmpty
        ? 0.0
        : trend.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  Text('Reports', style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _periodChip(colors, 'Week', _Period.week),
                  const SizedBox(width: 8),
                  _periodChip(colors, 'Month', _Period.month),
                  const SizedBox(width: 8),
                  _periodChip(colors, 'Year', _Period.year),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.mauveMagic))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      children: [
                        if (totalExpense == 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text('No spending in this period yet',
                                  style: TextStyle(color: colors.textMuted)),
                            ),
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 140,
                                height: 140,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    PieChart(
                                      PieChartData(
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 42,
                                        sections: List.generate(sortedEntries.length, (i) {
                                          final entry = sortedEntries[i];
                                          return PieChartSectionData(
                                            value: entry.value,
                                            color: _chartPalette[i % _chartPalette.length],
                                            radius: 26,
                                            showTitle: false,
                                          );
                                        }),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Spent',
                                            style:
                                                TextStyle(color: colors.textMuted, fontSize: 10)),
                                        Text(currency.format(totalExpense),
                                            style: TextStyle(
                                                color: colors.textPrimary,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(sortedEntries.length, (i) {
                                    final entry = sortedEntries[i];
                                    final category = _categoryFor(entry.key);
                                    final pct = (entry.value / totalExpense * 100).round();
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              color: _chartPalette[i % _chartPalette.length]
                                                  .withOpacity(0.18),
                                              borderRadius: BorderRadius.circular(7),
                                            ),
                                            child: Icon(
                                              iconForCategory(category?.icon ?? 'other'),
                                              size: 12,
                                              color: _chartPalette[i % _chartPalette.length],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(category?.name ?? 'Other',
                                                style: TextStyle(
                                                    color: colors.textBody, fontSize: 12.5)),
                                          ),
                                          Text('$pct%',
                                              style: TextStyle(
                                                  color: colors.textMuted, fontSize: 12)),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 26),
                        Text('SPENDING TREND',
                            style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6)),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 140,
                          child: maxTrendValue == 0
                              ? Center(
                                  child: Text('Nothing to chart yet',
                                      style: TextStyle(color: colors.textMuted, fontSize: 12)),
                                )
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: maxTrendValue * 1.25,
                                    gridData: const FlGridData(show: false),
                                    borderData: FlBorderData(show: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final index = value.toInt();
                                            if (index < 0 || index >= trend.length) {
                                              return const SizedBox.shrink();
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: Text(trend[index].key,
                                                  style: TextStyle(
                                                      color: colors.textMuted, fontSize: 10)),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    barGroups: List.generate(trend.length, (i) {
                                      final isMax =
                                          trend[i].value == maxTrendValue && maxTrendValue > 0;
                                      return BarChartGroupData(x: i, barRods: [
                                        BarChartRodData(
                                          toY: trend[i].value,
                                          width: _period == _Period.week ? 18 : 14,
                                          borderRadius: BorderRadius.circular(4),
                                          color: isMax
                                              ? AppColors.mauveMagic
                                              : AppColors.indigoVelvet,
                                        ),
                                      ]);
                                    }),
                                  ),
                                ),
                        ),
                      ],
                    ),
            ),
            const FinTrackBottomNav(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _periodChip(AppSemanticColors colors, String label, _Period value) {
    final selected = _period == value;
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => setState(() => _period = value),
      label: Text(label),
      labelStyle:
          TextStyle(color: selected ? AppColors.petalFrost : colors.textBody, fontSize: 13),
      backgroundColor: colors.inputFill,
      selectedColor: AppColors.royalViolet,
      side: BorderSide(color: colors.inputBorder),
    );
  }
}