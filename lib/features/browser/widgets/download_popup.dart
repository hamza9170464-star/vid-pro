import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/glass_card.dart';
import '../../../models/media_item.dart';
import '../../../services/browser_sniffer.dart';
import '../../../providers/download_provider.dart';
import '../../../providers/theme_provider.dart';

class DownloadPopup extends ConsumerStatefulWidget {
  final MediaItem baseMediaItem;

  const DownloadPopup({
    super.key,
    required this.baseMediaItem,
  });

  @override
  ConsumerState<DownloadPopup> createState() => _DownloadPopupState();
}

class _HomeScreenState {}

class _DownloadPopupState extends ConsumerState<DownloadPopup> {
  late TextEditingController _titleController;
  late List<MediaItem> _qualityOptions;
  late MediaItem _selectedOption;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.baseMediaItem.title);
    _qualityOptions = BrowserSniffer.getQualityOptions(widget.baseMediaItem);
    _selectedOption = _qualityOptions.isNotEmpty ? _qualityOptions.first : widget.baseMediaItem;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _triggerDownload() {
    final cleanTitle = _titleController.text.trim().isEmpty 
        ? 'Media File' 
        : _titleController.text.trim();
        
    final downloadItem = MediaItem(
      id: _selectedOption.id,
      url: _selectedOption.url,
      title: cleanTitle,
      extension: _selectedOption.extension,
      mimeType: _selectedOption.mimeType,
      sizeBytes: _selectedOption.sizeBytes,
      resolution: _selectedOption.resolution,
    );

    ref.read(downloadProvider.notifier).startDownload(downloadItem);
    Navigator.pop(context);

    // Prompt user with visual feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.download_done_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Download queued successfully!',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeOption = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
            width: 1.5,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 24.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.onBackground.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Dialog Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.baseMediaItem.extension == 'mp3' 
                      ? Icons.music_note_rounded 
                      : Icons.video_collection_rounded,
                  color: theme.colorScheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Download Media',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Select quality and configure parameters',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: theme.colorScheme.onBackground.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Visual Card with format and renaming option
          GlassCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Media Thumbnail placeholder matching current theme palette
                Container(
                  width: 74,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: AppTheme.getGradientColors(themeOption),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.baseMediaItem.extension.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Renaming Field
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'File Name',
                      labelStyle: GoogleFonts.outfit(fontSize: 12),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      suffixIcon: Icon(Icons.edit, size: 16, color: theme.colorScheme.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Quality Option Picker Header
          Text(
            'Select Resolution / Quality',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 10),

          // Picker List
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 210),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _qualityOptions.length,
              itemBuilder: (context, idx) {
                final option = _qualityOptions[idx];
                final isSelected = option.id == _selectedOption.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedOption = option;
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? theme.colorScheme.primary.withOpacity(0.08) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected 
                              ? theme.colorScheme.primary.withOpacity(0.4) 
                              : theme.colorScheme.onBackground.withOpacity(0.08),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.4),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                option.resolution ?? 'Default',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            option.formattedSize,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              // Cancel Trigger
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 14),
              // Start Download Trigger
              Expanded(
                child: ElevatedButton(
                  onPressed: _triggerDownload,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_downward_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Download',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
