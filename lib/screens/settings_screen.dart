import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_notifier.dart';
import 'about_screen.dart';
import 'help_screen.dart';
import 'auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeProvider = context.watch<ThemeProvider>();
    final user = context.watch<UserProvider>().currentUser;

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
                  Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  if (user != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.mauveMagic,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                                color: AppColors.darkAmethyst, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name,
                                style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            Text(user.email,
                                style: TextStyle(color: colors.textMuted, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.dark_mode_rounded, color: AppColors.mauveMagic),
                    title: Text('Dark mode', style: TextStyle(color: colors.textBody, fontSize: 13)),
                    value: themeProvider.isDarkMode,
                    activeColor: AppColors.mauveMagic,
                    onChanged: (value) => themeProvider.toggleTheme(value),
                  ),
                  Divider(color: colors.divider),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.language_rounded, color: AppColors.mauveMagic),
                    title: Text('Currency · LKR', style: TextStyle(color: colors.textBody, fontSize: 13)),
                    trailing: Icon(Icons.chevron_right, color: colors.textMuted),
                    onTap: () => AppNotifier.info(context, 'Currency settings — coming next'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_outline_rounded, color: AppColors.mauveMagic),
                    title: Text('Change password',
                        style: TextStyle(color: colors.textBody, fontSize: 13)),
                    trailing: Icon(Icons.chevron_right, color: colors.textMuted),
                    onTap: () => AppNotifier.info(context, 'Change password — coming next'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.cloud_upload_outlined, color: AppColors.mauveMagic),
                    title: Text('Backup data', style: TextStyle(color: colors.textBody, fontSize: 13)),
                    trailing: Icon(Icons.chevron_right, color: colors.textMuted),
                    onTap: () => AppNotifier.info(context, 'Backup — coming next'),
                  ),
                  Divider(color: colors.divider),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.help_outline_rounded, color: AppColors.mauveMagic),
                    title: Text('Help & support', style: TextStyle(color: colors.textBody, fontSize: 13)),
                    trailing: Icon(Icons.chevron_right, color: colors.textMuted),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HelpScreen()),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline_rounded, color: AppColors.mauveMagic),
                    title: Text('About', style: TextStyle(color: colors.textBody, fontSize: 13)),
                    trailing: Icon(Icons.chevron_right, color: colors.textMuted),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    ),
                  ),
                  Divider(color: colors.divider),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.logout_rounded, color: colors.negative),
                    title: Text('Log out', style: TextStyle(color: colors.negative, fontSize: 13)),
                    onTap: () {
                      context.read<UserProvider>().logout();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}