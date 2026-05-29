import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/glass_card.dart';
import '../../screens/main_hub.dart';
import '../../browser/browser_screen.dart';
import '../../browser/widgets/download_popup.dart';
import '../../../providers/browser_provider.dart';
import '../../../providers/download_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../models/media_item.dart';
import '../history/history_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _recommendedSites = [
    {'name': 'Google', 'url': 'https://www.google.com', 'icon': Icons.search, 'color': Colors.blue},
    {'name': 'Vimeo', 'url': 'https://vimeo.com', 'icon': Icons.video_library, 'color': Colors.lightBlueAccent},
    {'name': 'Instagram', 'url': 'https://www.instagram.com', 'icon': Icons.camera_alt_outlined, 'color': Colors.pink},
    {'name': 'Soundcloud', 'url': 'https://soundcloud.com', 'icon': Icons.music_note, 'color': Colors.orange},
    {'name': 'TikTok', 'url': 'https://www.tiktok.com', 'icon': Icons.audiotrack, 'color': Colors.cyan},
    {'name': 'Dailymotion', 'url': 'https://www.dailymotion.com', 'icon': Icons.play_circle_filled, 'color': Colors.blueAccent},
  ];

  final List<Map<String, dynamic>> _trendingMedia = [
    {
      'title': 'Synthwave Retro Mix 2026',
      'url': 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_5mb.mp4', // Safe sample URL
      'category': 'Music',
      'duration': '12:45',
      'ext': 'mp4',
      'size': 45 * 1024 * 1024,
      'resolution': '720p',
    },
    {
      'title': 'Stunning Cyber Cities & Neon Lights',
      'url': 'https://www.w3schools.com/html/mov_bbb.mp4',
      'category': 'Vlog / Cinematic',
      'duration': '04:20',
      'ext': 'mp4',
      'size': 18 * 1024 * 1024,
      'resolution': '480p',
    },
    {
      'title': 'Deep Ambient Focus Tracks',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      'category': 'Audio',
      'duration': '06:12',
      'ext': 'mp3',
      'size': 6 * 1024 * 1024,
      'resolution': '320kbps',
    }
  ];

  void _handleSearchOrNavigate(String query) {
    if (query.trim().isEmpty) return;

    String targetUrl = query.trim();
    if (!targetUrl.startsWith('http://') && !targetUrl.startsWith('https://')) {
      targetUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(targetUrl)}';
    }

    ref.read(browserProvider.notifier).setUrl(targetUrl);
    ref.read(currentTabProvider.notifier).state = 1; // Swipe to WebView tab!
  }

  void _triggerDownloadSheet(Map<String, dynamic> media) {
    final baseItem = MediaItem(
      id: 'trending_${media['title'].hashCode}',
      url: media['url'],
      title: media['title'],
      extension: media['ext'],
      resolution: media['resolution'],
      sizeBytes: media['size'],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DownloadPopup(baseMediaItem: baseItem),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeOption = ref.watch(themeProvider);
    final downloadTasks = ref.watch(downloadProvider);
    final activeDownloads = downloadTasks
        .where((t) => t.status == DownloadStatus.downloading || t.status == DownloadStatus.enqueued)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VID-PRO',
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.black,
                          letterSpacing: 2.0,
                          color: theme.colorScheme.primary,
                          shadows: themeOption.isDark ? [
                            Shadow(
                              color: theme.colorScheme.primary.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ] : null,
                        ),
                      ),
                      Text(
                        'Premium Media Downloader',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: theme.colorScheme.onBackground.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.history_rounded, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HistoryScreen()),
                      );
                    },
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 24),

              // Search Box
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.primary,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.outfit(fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Search or enter website URL...',
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: _handleSearchOrNavigate,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_rounded, color: theme.colorScheme.primary),
                      onPressed: () => _handleSearchOrNavigate(_searchController.text),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 28),

              // Quick Portals Grid
              Text(
                'Recommended Sites',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: _recommendedSites.length,
                itemBuilder: (context, index) {
                  final site = _recommendedSites[index];
                  return InkWell(
                    onTap: () => _handleSearchOrNavigate(site['url']),
                    borderRadius: BorderRadius.circular(20),
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      borderRadius: 20,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: site['color'].withOpacity(0.12),
                            ),
                            child: Icon(
                              site['icon'],
                              color: site['color'],
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            site['name'],
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onBackground.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

              const SizedBox(height: 28),

              // Active downloads preview (Show only if there's active downloading state)
              if (activeDownloads.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Downloading (${activeDownloads.length})',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(currentTabProvider.notifier).state = 2; // Switch to Downloads screen
                      },
                      child: Text('View All', style: GoogleFonts.outfit(color: theme.colorScheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeDownloads.length > 2 ? 2 : activeDownloads.length,
                  itemBuilder: (context, idx) {
                    final t = activeDownloads[idx];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.downloading, color: theme.colorScheme.primary),
                            ),
                            const SizedBox(width: 14),
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
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: t.progress / 100,
                                      minHeight: 4,
                                      color: theme.colorScheme.primary,
                                      backgroundColor: theme.colorScheme.onBackground.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              '${t.progress}%',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 16),
              ],

              // Trending Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trending Downloads',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.whatshot, color: theme.colorScheme.primary),
                ],
              ),
              const SizedBox(height: 14),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _trendingMedia.length,
                itemBuilder: (context, index) {
                  final media = _trendingMedia[index];
                  final isAudio = media['ext'] == 'mp3';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: InkWell(
                      onTap: () => _triggerDownloadSheet(media),
                      borderRadius: BorderRadius.circular(20),
                      child: GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Visual Mock Thumbnail
                            Container(
                              width: 90,
                              height: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: AppTheme.getGradientColors(themeOption),
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  isAudio ? Icons.music_note_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      media['category'],
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    media['title'],
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Duration: ${media['duration']}  |  ${media['resolution']}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Quick Action Button
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_downward_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              onPressed: () => _triggerDownloadSheet(media),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
