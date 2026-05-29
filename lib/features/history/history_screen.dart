import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../widgets/glass_card.dart';
import '../../../models/history_item.dart';
import '../../../providers/history_provider.dart';
import '../../../providers/browser_provider.dart';
import '../../screens/main_hub.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUrlInBrowser(String url) {
    ref.read(browserProvider.notifier).setUrl(url);
    ref.read(browserProvider.notifier).clearDetectedMedia();
    ref.read(currentTabProvider.notifier).state = 1; // Swap tab to Browser
    Navigator.of(context).popUntil((route) => route.isFirst); // Slide back to Hub
  }

  void _clearAllHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear History', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.redAccent)),
        content: const Text('Are you sure you want to delete all browsing history and downloading logs? This cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
            onPressed: () {
              ref.read(historyProvider.notifier).clearAll();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = ref.watch(historyProvider);

    final browseHistory = history.where((e) => !e.isDownload).toList();
    final downloadLogs = history.where((e) => e.isDownload).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History Logs',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
              onPressed: _clearAllHistory,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onBackground.withOpacity(0.5),
          indicatorColor: theme.colorScheme.primary,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.outfit(fontSize: 14),
          tabs: const [
            Tab(text: 'Browser History'),
            Tab(text: 'Download History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryList(browseHistory, Icons.history_rounded, 'No Browsing History'),
          _buildHistoryList(downloadLogs, Icons.cloud_download_outlined, 'No Download History'),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<HistoryItem> list, IconData emptyIcon, String emptyText) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(emptyIcon, size: 54, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
              const SizedBox(height: 16),
              Text(
                emptyText,
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(18.0),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final item = list[idx];
        final timeStr = DateFormat('MMM dd, hh:mm a').format(item.timestamp);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  item.isDownload ? Icons.download_done_rounded : Icons.link_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InkWell(
                    onTap: () => _loadUrlInBrowser(item.url),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.url,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: theme.colorScheme.onBackground.withOpacity(0.4),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeStr,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: theme.colorScheme.onBackground.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: theme.colorScheme.onBackground.withOpacity(0.4)),
                  onPressed: () {
                    ref.read(historyProvider.notifier).deleteItem(item.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
