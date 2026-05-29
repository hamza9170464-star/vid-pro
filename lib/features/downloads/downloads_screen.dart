import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/glass_card.dart';
import '../../../models/download_task.dart';
import '../../../providers/download_provider.dart';
import '../../../providers/theme_provider.dart';
import '../player/player_screen.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> with SingleTickerProviderStateMixin {
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

  void _shareFile(AppDownloadTask task) {
    final file = File(task.filePath);
    if (file.existsSync()) {
      Share.shareXFiles([XFile(task.filePath)], text: 'Sharing ${task.filename} via Vid-Pro');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Source file not found on disk. It may have been relocated.')),
      );
    }
  }

  void _playVideo(AppDownloadTask task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          videoPath: task.filePath,
          videoTitle: task.filename,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = ref.watch(downloadProvider);

    final activeTasks = tasks
        .where((t) => t.status != DownloadStatus.completed)
        .toList();
        
    final completedTasks = tasks
        .where((t) => t.status == DownloadStatus.completed)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Downloads Manager',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onBackground.withOpacity(0.5),
          indicatorColor: theme.colorScheme.primary,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
          unselectedLabelStyle: GoogleFonts.outfit(fontSize: 15),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active List
          _buildActiveList(activeTasks),
          // Completed List
          _buildCompletedList(completedTasks),
        ],
      ),
    );
  }

  Widget _buildActiveList(List<AppDownloadTask> list) {
    if (list.isEmpty) {
      return _buildEmptyState(
        Icons.cloud_download_outlined,
        'No Active Downloads',
        'Browser media files and download them in a single tap!',
      );
    }

    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(18.0),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final t = list[idx];
        final isDownloading = t.status == DownloadStatus.downloading;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        t.filename,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        t.status.displayName,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Progress Bar Slider
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: t.progress / 100,
                    minHeight: 6,
                    color: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.onBackground.withOpacity(0.08),
                  ),
                ),
                const SizedBox(height: 10),

                // Specs Line: speed + remaining details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${t.progress}% completed  |  ${t.formattedSpeed}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: theme.colorScheme.onBackground.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (t.formattedTimeRemaining.isNotEmpty)
                      Text(
                        t.formattedTimeRemaining,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Control panel buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Retry Button if failed
                    if (t.status == DownloadStatus.failed)
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: () {
                          ref.read(downloadProvider.notifier).retryDownload(t.id);
                        },
                      ),
                      
                    // Pause/Resume Actions
                    if (t.status == DownloadStatus.downloading)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.pause_rounded, size: 16),
                        label: const Text('Pause', style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          ref.read(downloadProvider.notifier).pauseDownload(t.id);
                        },
                      )
                    else if (t.status == DownloadStatus.paused)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 16),
                        label: const Text('Resume', style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          ref.read(downloadProvider.notifier).resumeDownload(t.id);
                        },
                      ),

                    const SizedBox(width: 10),

                    // Cancel Trigger
                    IconButton(
                      icon: Icon(
                        Icons.cancel_outlined,
                        color: theme.colorScheme.onBackground.withOpacity(0.4),
                        size: 22,
                      ),
                      onPressed: () {
                        ref.read(downloadProvider.notifier).cancelDownload(t.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletedList(List<AppDownloadTask> list) {
    if (list.isEmpty) {
      return _buildEmptyState(
        Icons.cloud_done_outlined,
        'No Completed Downloads',
        'Queue items in browser and finished records will reside here.',
      );
    }

    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(18.0),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final t = list[idx];
        final isAudio = t.filename.toLowerCase().endsWith('.mp3');

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Completed visual card
                Container(
                  width: 68,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary.withOpacity(0.2), theme.colorScheme.primary.withOpacity(0.04)],
                    ),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Icon(
                      isAudio ? Icons.music_note_rounded : Icons.video_collection_rounded,
                      color: theme.colorScheme.primary,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Descriptions
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.filename,
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Downloaded successfully',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: theme.colorScheme.onBackground.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Menu
                IconButton(
                  icon: Icon(Icons.play_arrow_rounded, color: theme.colorScheme.primary, size: 28),
                  onPressed: () => _playVideo(t),
                ),
                
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  onSelected: (val) {
                    if (val == 'share') {
                      _shareFile(t);
                    } else if (val == 'delete') {
                      ref.read(downloadProvider.notifier).removeDownload(t.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Share file'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                          SizedBox(width: 8),
                          Text('Remove log', style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.08),
              ),
              child: Icon(
                icon,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: theme.colorScheme.onBackground.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 350.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
