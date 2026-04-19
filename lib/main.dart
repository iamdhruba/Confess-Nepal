import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'features/confession/providers/confession_provider.dart';
import 'features/ask_nepal/providers/ask_nepal_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/admin/providers/admin_provider.dart';
import 'features/profile/providers/notification_provider.dart';
import 'shell/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiClient.instance.init();

  runApp(const ConfessNepalApp());
}

class ConfessNepalApp extends StatelessWidget {
  const ConfessNepalApp({super.key});

  void _updateSystemUI(ThemeMode themeMode) {
    final isDark = themeMode == ThemeMode.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()..init()),
        ChangeNotifierProvider(create: (_) => ConfessionProvider()),
        ChangeNotifierProvider(create: (_) => AskNepalProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          _updateSystemUI(profileProvider.themeMode);
          return MaterialApp(
            title: 'ConfessNepal',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: profileProvider.themeMode,
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
