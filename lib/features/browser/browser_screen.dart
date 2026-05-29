import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/glass_card.dart';
import '../../../providers/browser_provider.dart';
import '../../../services/browser_sniffer.dart';
import '../../../models/media_item.dart';
import 'widgets/download_popup.dart';

class BrowserScreen extends ConsumerStatefulWidget {
  const BrowserScreen({super.key});

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  InAppWebViewController? _webViewController;
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();
  
  PullToRefreshController? _pullToRefreshController;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    
    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: AppTheme.darkRedPrimary,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          _webViewController?.reload();
        } else if (Platform.isIOS) {
          _webViewController?.loadUrl(
            urlRequest: URLRequest(url: await _webViewController?.getUrl()),
          );
        }
      },
    );
  }

  void _loadUrl(String val) {
    if (val.trim().isEmpty) return;
    
    _urlFocusNode.unfocus();
    String query = val.trim();
    if (!query.startsWith('http://') && !query.startsWith('https://')) {
      query = 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
    }

    _webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(query)),
    );
  }

  void _triggerSniffer(String url) async {
    final pageTitle = await _webViewController?.getTitle() ?? 'Media File';
    final detected = BrowserSniffer.sniffUrl(url, pageTitle);
    
    if (detected != null) {
      ref.read(browserProvider.notifier).setDetectedMedia(detected);
      
      // Notify user with a dynamic toast-snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackbars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Playable Media Detected!',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Text(
                  detected.extension.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.black,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  void _openDownloadPopup(MediaItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DownloadPopup(baseMediaItem: item),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final browserState = ref.watch(browserProvider);

    // Sync input controller value if it hasn't changed inside typing
    if (!_urlFocusNode.hasFocus && _urlController.text != browserState.currentUrl) {
      _urlController.text = browserState.currentUrl;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Input & Back Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              color: theme.scaffoldBackgroundColor,
              child: Row(
                children: [
                  // Back Action
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () async {
                      if (await _webViewController?.canGoBack() ?? false) {
                        _webViewController?.goBack();
                        ref.read(browserProvider.notifier).clearDetectedMedia();
                      }
                    },
                  ),
                  
                  // Forward Action
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                    onPressed: () async {
                      if (await _webViewController?.canGoForward() ?? false) {
                        _webViewController?.goForward();
                        ref.read(browserProvider.notifier).clearDetectedMedia();
                      }
                    },
                  ),
                  
                  const SizedBox(width: 6),
                  
                  // Address Bar Input
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      borderRadius: 16,
                      child: Row(
                        children: [
                          Icon(Icons.lock_rounded, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _urlController,
                              focusNode: _urlFocusNode,
                              style: GoogleFonts.outfit(fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Enter URL or Search query...',
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                              ),
                              onSubmitted: _loadUrl,
                            ),
                          ),
                          if (_urlController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _urlController.clear();
                              },
                              child: Icon(Icons.clear_rounded, size: 16, color: theme.colorScheme.onBackground.withOpacity(0.5)),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),
                  
                  // Refresh Action
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 24),
                    onPressed: () {
                      _webViewController?.reload();
                    },
                  ),
                ],
              ),
            ),
            
            // Linear Progress Loader
            if (_progress < 1.0)
              LinearProgressIndicator(
                value: _progress,
                minHeight: 2,
                color: theme.colorScheme.primary,
                backgroundColor: Colors.transparent,
              ),

            // InAppWebView Container
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(browserState.currentUrl)),
                    pullToRefreshController: _pullToRefreshController,
                    initialSettings: InAppWebViewSettings(
                      useShouldInterceptRequest: true,
                      mediaPlaybackRequiresUserGesture: false,
                      javaScriptEnabled: true,
                      transparentBackground: true,
                      supportZoom: true,
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
                      if (url != null) {
                        final strUrl = url.toString();
                        ref.read(browserProvider.notifier).updatePage(strUrl, 'Loading...');
                        _triggerSniffer(strUrl);
                      }
                    },
                    onLoadStop: (controller, url) async {
                      _pullToRefreshController?.endRefreshing();
                      if (url != null) {
                        final strUrl = url.toString();
                        final title = await controller.getTitle() ?? 'WebView';
                        ref.read(browserProvider.notifier).updatePage(strUrl, title);
                        _triggerSniffer(strUrl);
                      }
                    },
                    onProgressChanged: (controller, progress) {
                      setState(() {
                        _progress = progress / 100;
                      });
                      ref.read(browserProvider.notifier).updateLoading(progress);
                    },
                    shouldInterceptRequest: (controller, request) async {
                      // Live network request sniffing to capture hidden media URLs
                      final reqUrl = request.url.toString();
                      _triggerSniffer(reqUrl);
                      return null;
                    },
                  ),

                  // Sniffed floating indicator bubble
                  if (browserState.detectedMedia != null)
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: FloatingActionButton.large(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 8,
                        onPressed: () => _openDownloadPopup(browserState.detectedMedia!),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_downward_rounded, size: 36),
                            const SizedBox(height: 4),
                            Text(
                              browserState.detectedMedia!.extension.toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.black,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat(reverse: true))
                          .scale(
                            duration: 1200.ms,
                            begin: const Offset(1, 1),
                            end: const Offset(1.1, 1.1),
                            curve: Curves.easeInOut,
                          )
                          .then()
                          .animate()
                          .boxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.5),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
