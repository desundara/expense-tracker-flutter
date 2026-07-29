import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

// Global route observer - Dashboard (or any screen) can subscribe to this
// to get notified when it's popped back into view (didPopNext), so it can
// auto-refresh its data without needing a manual pull-to-refresh.
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(const FinTrackApp());
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'FinTrack',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            navigatorObservers: [routeObserver],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}