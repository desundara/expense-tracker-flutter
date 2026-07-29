import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/add_expense_screen.dart';
import '../screens/add_income_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/transaction_list_screen.dart';
import '../utils/app_notifier.dart';

/// Bottom navigation bar shared by Dashboard, Transactions, Reports
/// and Settings. Tabs that don't have a real screen yet show a
/// "coming next" message instead of navigating.
class FinTrackBottomNav extends StatelessWidget {
  final int currentIndex;
  final VoidCallback? onTransactionAdded;
  const FinTrackBottomNav({super.key, required this.currentIndex, this.onTransactionAdded});

  void _showComingSoon(BuildContext context, String label) {
    AppNotifier.info(context, '$label — coming next');
  }

  Future<void> _showAddSheet(BuildContext context) async {
    final colors = context.colors;
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final sheetColors = sheetContext.colors;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: sheetColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_downward_rounded, color: AppColors.mauveMagic),
                  title: Text('Add expense',
                      style: TextStyle(color: sheetColors.textBody, fontSize: 14.5)),
                  onTap: () => Navigator.of(sheetContext).pop('expense'),
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_upward_rounded, color: AppColors.mauveMagic),
                  title: Text('Add income',
                      style: TextStyle(color: sheetColors.textBody, fontSize: 14.5)),
                  onTap: () => Navigator.of(sheetContext).pop('income'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (choice == null || !context.mounted) return;

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => choice == 'expense' ? const AddExpenseScreen() : const AddIncomeScreen(),
      ),
    );
    if (saved == true) {
      onTransactionAdded?.call();
      if (context.mounted) {
        AppNotifier.success(
            context, choice == 'expense' ? 'Expense added' : 'Income added');
      }
    }
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    VoidCallback? onTap,
  }) {
    final active = index == currentIndex;
    final colors = context.colors;
    return InkWell(
      onTap: active ? null : (onTap ?? () => _showComingSoon(context, label)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: active ? AppColors.mauveMagic : colors.textMuted),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: active ? AppColors.mauveMagic : colors.textMuted)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            context,
            icon: Icons.home_rounded,
            label: 'Home',
            index: 0,
            onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          _navItem(
            context,
            icon: Icons.receipt_long_rounded,
            label: 'Activity',
            index: 1,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TransactionListScreen()),
            ),
          ),
          GestureDetector(
            onTap: () => _showAddSheet(context),
            child: Transform.translate(
              offset: const Offset(0, -22),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                      colors: [AppColors.mauveMagic, AppColors.royalViolet]),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.mauveMagic.withOpacity(0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 6)),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
          _navItem(
            context,
            icon: Icons.pie_chart_rounded,
            label: 'Reports',
            index: 3,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReportsScreen()),
            ),
          ),
          _navItem(
            context,
            icon: Icons.settings_rounded,
            label: 'Settings',
            index: 4,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}