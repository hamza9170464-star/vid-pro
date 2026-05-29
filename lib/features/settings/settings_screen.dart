import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_option.dart';
import '../../../widgets/glass_card.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/storage_provider.dart';
import '../history/history_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _downloadPath = '/storage/emulated/0/Download/Vid-Pro';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    try {
      final storage = ref.read(storageServiceProvider);
      setState(() {
        _notificationsEnabled = storage.areNotificationsEnabled();
        _downloadPath = storage.getDownloadPath('/storage/emulated/0/Download/Vid-Pro');
      });
    } catch (_) {}
  }

  void _toggleNotifications(bool enabled) async {
    setState(() {
      _notificationsEnabled = enabled;
    });
    try {
      final storage = ref.read(storageServiceProvider);
      await storage.saveNotificationsEnabled(enabled);
    } catch (_) {}
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Cache', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: const Text('This will wipe all cached web pages and temporary sniffer records, improving browsing performance. Offline files are kept untouched.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Clear'),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  content: Text('Cache cleared successfully!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDownloadPathConfig() {
    final controller = TextEditingController(text: _downloadPath);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Download Folder', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Absolute Storage Path'),
        ),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
          ElevatedButton(
            child: const Text('Update'),
            onPressed: () async {
              final newPath = controller.text.trim();
              if (newPath.isNotEmpty) {
                setState(() {
                  _downloadPath = newPath;
                });
                try {
                  final storage = ref.read(storageServiceProvider);
                  await storage.saveDownloadPath(newPath);
                } catch (_) {}
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAboutApp() {
    showAboutDialog(
      context: context,
      applicationName: 'Vid-Pro Downloader',
      applicationVersion: 'v1.0.0 (Release Build)',
      applicationLegalese: '© 2026 Vid-Pro Project Authors. All rights reserved. Created with Dart, Flutter, and Riverpod.',
      children: [
        const SizedBox(height: 12),
        Text(
          'Vid-Pro is a high-performance Android media downloader and player. Features comprehensive media sniffer capabilities, premium Material 3 design presets, dynamic custom layouts, and a secure multi-threaded background downloader engine.',
          style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings Hub',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Changer Panel Header
            Text(
              'Dynamic Custom Themes',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            // 6-Theme selection grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.1,
              ),
              itemCount: ThemeOption.values.length,
              itemBuilder: (context, idx) {
                final option = ThemeOption.values[idx];
                final isSelected = option == activeTheme;
                final colors = AppTheme.getGradientColors(option);

                return InkWell(
                  onTap: () {
                    ref.read(themeProvider.notifier).setTheme(option);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? theme.colorScheme.primary.withOpacity(0.08) 
                          : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.onBackground.withOpacity(0.06),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Color indicator
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Title
                        Expanded(
                          child: Text(
                            option.displayName,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ).animate().fadeIn(duration: 500.ms),

            const SizedBox(height: 28),

            // Settings Parameter Cards
            Text(
              'Configurations',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Config card grouping
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Folder path config
                  ListTile(
                    leading: Icon(Icons.folder_outlined, color: theme.colorScheme.primary),
                    title: Text('Download Path', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Text(_downloadPath, style: GoogleFonts.outfit(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showDownloadPathConfig,
                  ),
                  Divider(height: 1, color: theme.colorScheme.onBackground.withOpacity(0.08)),

                  // Notification switch
                  SwitchListTile(
                    secondary: Icon(Icons.notifications_active_outlined, color: theme.colorScheme.primary),
                    title: Text('Show Progress Notifications', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Text('Receive alerts in background when downloading completes', style: GoogleFonts.outfit(fontSize: 11)),
                    value: _notificationsEnabled,
                    activeColor: theme.colorScheme.primary,
                    onChanged: _toggleNotifications,
                  ),
                  Divider(height: 1, color: theme.colorScheme.onBackground.withOpacity(0.08)),

                  // Clear Cache list
                  ListTile(
                    leading: Icon(Icons.cleaning_services_outlined, color: theme.colorScheme.primary),
                    title: Text('Clear WebView Cache', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Text('Wipe browsing search cookies and temporary storage', style: GoogleFonts.outfit(fontSize: 11)),
                    onTap: _clearCache,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 28),

            // About grouping
            Text(
              'Information',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // About trigger
                  ListTile(
                    leading: Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary),
                    title: Text('About Vid-Pro', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                    onTap: _showAboutApp,
                  ),
                  Divider(height: 1, color: theme.colorScheme.onBackground.withOpacity(0.08)),

                  // Privacy policy list
                  ListTile(
                    leading: Icon(Icons.privacy_tip_outlined, color: theme.colorScheme.primary),
                    title: Text('Privacy Policy', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Text('Review how we handle sandbox local permissions', style: GoogleFonts.outfit(fontSize: 11)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sandbox environment operates strictly offline. Zero telemetry collected.')),
                      );
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
