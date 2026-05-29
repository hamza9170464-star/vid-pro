import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/storage_provider.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  // Ensure that dynamic bindings are operational before executing startup loops
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce locked screen orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Load storage dependencies synchronously prior to rendering main layout
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const VidProApp(),
    ),
  );
}

class VidProApp extends ConsumerWidget {
  const VidProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTheme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Vid-Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(activeTheme),
      home: const SplashScreen(),
    );
  }
}
