import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../../widgets/glass_card.dart';
import '../../../providers/download_provider.dart';
import '../player/player_screen.dart';

class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key});

  @override
  ConsumerState<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  List<FileSystemEntity> _files = [];
  List<FileSystemEntity> _filteredFiles = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPhysicalFiles();
  }

  Future<void> _loadPhysicalFiles() async {
    setState(() {
      _loading = true;
    });

    try {
      final service = ref.read(downloadServiceProvider);
      final dirPath = await service.getDefaultDownloadDirectory();
      final dir = Directory(dirPath);

      if (await dir.exists()) {
        final list = dir.listSync().where((entity) {
          final path = entity.path.toLowerCase();
          return path.endsWith('.mp4') || path.endsWith('.mp3') || path.endsWith('.webm');
        }).toList();
        
        setState(() {
          _files = list;
          _filteredFiles = list;
          _loading = false;
        });
      } else {
        setState(() {
          _files = [];
          _filteredFiles = [];
          _loading = false;
        });
      }
    } catch (_) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _filterFiles(String query) {
    setState(() {
      _searchQuery = query;
      _filteredFiles = _files.where((f) {
        final filename = f.path.split('/').last.split('\\').last.toLowerCase();
        return filename.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _playFile(FileSystemEntity file) {
    final title = file.path.split('/').last.split('\\').last;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          videoPath: file.path,
          videoTitle: title,
        ),
      ),
    );
  }

  void _shareFile(FileSystemEntity file) {
    Share.shareXFiles([XFile(file.path)], text: 'Sharing media file downloaded via Vid-Pro');
  }

  Future<void> _renameFile(FileSystemEntity file) async {
    final titleController = TextEditingController(
      text: file.path.split('/').last.split('\\').last,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename File', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'New Name'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Rename'),
            onPressed: () async {
              final newName = titleController.text.trim();
              if (newName.isNotEmpty) {
                try {
                  final dirPath = file.parent.path;
                  final newPath = '$dirPath/$newName';
                  await file.rename(newPath);
                  Navigator.pop(context);
                  _loadPhysicalFiles();
                } catch (_) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to rename file. Check format constraints.')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _deleteFile(FileSystemEntity file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete File', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.redAccent)),
        content: const Text('Are you sure you want to permanently delete this media file from local storage? This action is irreversible.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              try {
                await file.delete();
                Navigator.pop(context);
                _loadPhysicalFiles();
              } catch (_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete resource file.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  String _getFileSize(FileSystemEntity file) {
    try {
      final stat = file.statSync();
      final kb = stat.size / 1024;
      final mb = kb / 1024;
      if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
      return '${kb.toStringAsFixed(1)} KB';
    } catch (_) {
      return 'Unknown Size';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Media Files Hub',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            onPressed: _loadPhysicalFiles,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : Column(
              children: [
                // Search Input Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    borderRadius: 16,
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            style: GoogleFonts.outfit(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Search offline files...',
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            onChanged: _filterFiles,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // File List
                Expanded(
                  child: _filteredFiles.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(18.0),
                          itemCount: _filteredFiles.length,
                          itemBuilder: (context, idx) {
                            final file = _filteredFiles[idx];
                            final path = file.path;
                            final isAudio = path.toLowerCase().endsWith('.mp3');
                            final name = path.split('/').last.split('\\').last;
                            final size = _getFileSize(file);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GlassCard(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Visual File badge
                                    Container(
                                      width: 62,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          isAudio ? Icons.music_note_rounded : Icons.video_collection_rounded,
                                          color: theme.colorScheme.primary,
                                          size: 24,
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
                                            name,
                                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            size,
                                            style: GoogleFonts.outfit(
                                              fontSize: 11,
                                              color: theme.colorScheme.onBackground.withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Play Action
                                    IconButton(
                                      icon: Icon(Icons.play_arrow_rounded, color: theme.colorScheme.primary, size: 26),
                                      onPressed: () => _playFile(file),
                                    ),

                                    // Dropdown Menu
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert_rounded, size: 20),
                                      onSelected: (val) {
                                        if (val == 'share') {
                                          _shareFile(file);
                                        } else if (val == 'rename') {
                                          _renameFile(file);
                                        } else if (val == 'delete') {
                                          _deleteFile(file);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'share',
                                          child: Row(
                                            children: [
                                              Icon(Icons.share_outlined, size: 18),
                                              SizedBox(width: 8),
                                              Text('Share'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'rename',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit_note_rounded, size: 18),
                                              SizedBox(width: 8),
                                              Text('Rename'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                                              SizedBox(width: 8),
                                              Text('Delete file', style: TextStyle(color: Colors.redAccent)),
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
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
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
                Icons.folder_copy_outlined,
                size: 58,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Media Files Found',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'No local downloads matched: "$_searchQuery"' 
                  : 'Files you download will accumulate in local storage folders and display here.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: theme.colorScheme.onBackground.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
