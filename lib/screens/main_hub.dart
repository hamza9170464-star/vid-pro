import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/theme_option.dart';
import '../providers/theme_provider.dart';
import '../features/home/home_screen.dart';
import '../features/browser/browser_screen.dart';
import '../features/downloads/downloads_screen.dart';
import '../features/files/files_screen.dart';
import '../features/settings/settings_screen.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

class MainHub extends ConsumerStatefulWidget {
  const MainHub({super.key});

  @override
  ConsumerState<MainHub> createState() => _MainHubState();
}

class _MainHubState extends ConsumerState<MainHub> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const BrowserScreen(),
    const DownloadsScreen(),
    const FilesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = ref.watch(currentTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05),
              width: 1.0,
            ),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.85),
              elevation: 0,
              onTap: (index) {
                ref.read(currentTabProvider.notifier).state = index;
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.language_outlined),
                  activeIcon: Icon(Icons.language_rounded),
                  label: 'Browser',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.download_for_offline_outlined),
                  activeIcon: Icon(Icons.download_for_offline_rounded),
                  label: 'Downloads',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.folder_open_outlined),
                  activeIcon: Icon(Icons.folder_rounded),
                  label: 'Files',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
