import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
}

const List<_FaqItem> _faqs = [
  _FaqItem(
    'How do I add a transaction?',
    'Tap the + button in the middle of the bottom navigation bar, then choose '
        'Add expense or Add income.',
  ),
  _FaqItem(
    'How do I edit or delete a transaction?',
    'Open Transactions from the bottom navigation, tap any transaction, then '
        'choose Edit or Delete.',
  ),
  _FaqItem(
    'How do I switch between light and dark mode?',
    'Go to Settings and use the Dark mode toggle at the top of the screen.',
  ),
  _FaqItem(
    'Is my data backed up?',
    'Your data is currently stored locally on this device using SQLite. Cloud '
        'backup is planned for a future update.',
  ),
  _FaqItem(
    'How is my spending summarised in Reports?',
    'The Reports screen groups your expenses by category and by time period '
        '(week, month or year) so you can see where your money goes.',
  ),
];

class _HelpScreenState extends State<HelpScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_FaqItem> get _filtered {
    if (_query.isEmpty) return _faqs;
    return _faqs.where((f) => f.question.toLowerCase().contains(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final results = _filtered;

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
                  Text('Help & support', style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  TextField(
                    controller: _searchController,
                    style: TextStyle(color: colors.textBody),
                    decoration: InputDecoration(
                      hintText: 'Search help articles',
                      hintStyle: TextStyle(color: colors.textMuted),
                      prefixIcon: Icon(Icons.search, color: colors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('FREQUENTLY ASKED',
                      style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6)),
                  const SizedBox(height: 6),
                  if (results.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('No matching articles',
                            style: TextStyle(color: colors.textMuted)),
                      ),
                    )
                  else
                    ...results.map((f) => Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            iconColor: colors.textMuted,
                            collapsedIconColor: colors.textMuted,
                            title: Text(f.question,
                                style: TextStyle(color: colors.textBody, fontSize: 14)),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(f.answer,
                                    style: TextStyle(
                                        color: colors.textMuted, fontSize: 12.5, height: 1.5)),
                              ),
                            ],
                          ),
                        )),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.inputFill,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.inputBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Still need help?',
                            style: TextStyle(
                                color: colors.textBody,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.mail_outline_rounded,
                                size: 16, color: AppColors.mauveMagic),
                            const SizedBox(width: 8),
                            Text('support@fintrack.app',
                                style: TextStyle(color: colors.textMuted, fontSize: 12.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}