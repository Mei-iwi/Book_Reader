import 'dart:async';
import 'dart:io';

import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/services/http/api_client.dart';
import 'package:book_reader/data/datasources/local/dao/bookmark_dao.dart';
import 'package:book_reader/data/datasources/local/dao/reading_progress_dao.dart';
import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/remote/api/bookmark_api.dart';
import 'package:book_reader/data/datasources/remote/api/reading_progress_api.dart';
import 'package:book_reader/presentation/pages/comment/comments.dart';
import 'package:book_reader/presentation/pages/home/home_book_provider.dart';
import 'package:book_reader/presentation/state/library_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Reader extends StatefulWidget {
  final int value;
  final int total;
  final String title;
  final String coverUrl;
  final String? bookId;
  final int? userId;

  /// File text tải/lưu trong máy.
  /// Ví dụ: /data/user/0/.../book.txt
  final String? localFilePath;

  /// File text có sẵn trong assets.
  /// Ví dụ: assets/sample_data/templatecontentbooks/hoang_tu_be_demo.txt
  final String? assetPath;

  /// Nội dung text truyền trực tiếp nếu có.
  final String? contentText;

  /// Link đọc online từ Google Books.
  final String? webReaderLink;

  /// Link preview từ Google Books.
  final String? previewLink;
  final String? pdfDownloadLink;
  final String? epubDownloadLink;

  const Reader({
    super.key,
    required this.value,
    required this.total,
    required this.title,
    this.coverUrl = '',
    this.bookId,
    this.userId,
    this.localFilePath,
    this.assetPath,
    this.contentText,
    this.webReaderLink,
    this.previewLink,
    this.pdfDownloadLink,
    this.epubDownloadLink,
  });

  @override
  State<StatefulWidget> createState() => _Reader();
}

class _Reader extends State<Reader> {
  late int newvalue = widget.value;
  late int _textPageCount = widget.total <= 0 ? 1 : widget.total;
  late Future<List<String>> _pagesFuture;
  late final PageController _pageController;
  late final ReadingProgressDao _readingProgressDao;
  late final BookmarkDao _bookmarkDao;
  late final ReadingProgressApi _readingProgressApi;
  late final BookmarkApi _bookmarkApi;

  WebViewController? _webViewController;
  int _webProgress = 0;
  bool _webHasError = false;
  bool _isOpeningRemoteFile = false;
  bool _autoOpenedRemoteFile = false;
  String? _webErrorMessage;
  String _readingMode = 'light';
  double _fontScale = 1;
  double _lightLevel = 1;
  Timer? _progressSyncTimer;

  String get _onlineLink {
    final webReaderLink = widget.webReaderLink?.trim() ?? '';
    final previewLink = widget.previewLink?.trim() ?? '';

    if (webReaderLink.isNotEmpty) return webReaderLink;
    if (previewLink.isNotEmpty) return previewLink;

    return '';
  }

  bool get _hasOnlineLink => _onlineLink.isNotEmpty;

  String get _remotePdfLink => widget.pdfDownloadLink?.trim() ?? '';
  String get _remoteEpubLink => widget.epubDownloadLink?.trim() ?? '';
  bool get _hasRemotePdf => _remotePdfLink.isNotEmpty;
  bool get _hasRemoteEpub => _remoteEpubLink.isNotEmpty;
  bool get _usesExternalReader =>
      _hasExternalLocalFile || _hasRemotePdf || _hasRemoteEpub;

  int get _currentTotalPage {
    if (_shouldUseWebView || _hasExternalLocalFile || _hasRemoteEpub) {
      return widget.total <= 0 ? 1 : widget.total;
    }

    return _textPageCount <= 0 ? 1 : _textPageCount;
  }

  double get _progressPercent {
    final totalPage = _currentTotalPage <= 0 ? 1 : _currentTotalPage;
    return ((_safeCurrentPage / totalPage) * 100).clamp(0, 100).toDouble();
  }

  int get _safeCurrentPage {
    final totalPage = _currentTotalPage <= 0 ? 1 : _currentTotalPage;
    return newvalue.clamp(1, totalPage).toInt();
  }

  String get _webViewUrl {
    if (_hasOnlineLink) {
      return _onlineLink.replaceFirst('http://', 'https://');
    }

    if (_hasRemotePdf) {
      final pdfUrl = _remotePdfLink.replaceFirst('http://', 'https://');
      return 'https://docs.google.com/gview?embedded=1&url=${Uri.encodeComponent(pdfUrl)}';
    }

    return '';
  }

  bool get _hasLocalTextFile {
    final localPath = widget.localFilePath?.trim() ?? '';
    return localPath.toLowerCase().endsWith('.txt');
  }

  bool get _hasExternalLocalFile {
    final localPath = widget.localFilePath?.trim().toLowerCase() ?? '';
    return localPath.endsWith('.pdf') || localPath.endsWith('.epub');
  }

  bool get _shouldUseWebView {
    final localPath = widget.localFilePath?.trim() ?? '';

    if (_hasLocalTextFile) return false;

    // Uu tien doc online/PDF remote ngay trong app neu co link.
    if (_hasOnlineLink) return true;
    if (_hasRemotePdf) return true;

    // Nếu là PDF/EPUB local thì Reader này chưa render trực tiếp.
    // Có thể mở bằng màn PDF/EPUB riêng sau.
    if (localPath.toLowerCase().endsWith('.pdf')) return false;
    if (localPath.toLowerCase().endsWith('.epub')) return false;

    return false;
  }

  @override
  void initState() {
    super.initState();

    final appDatabase = AppDatabase.instance;
    final apiClient = ApiClient();
    _pageController = PageController();
    _readingProgressDao = ReadingProgressDao(appDatabase);
    _bookmarkDao = BookmarkDao(appDatabase);
    _readingProgressApi = ReadingProgressApi(apiClient);
    _bookmarkApi = BookmarkApi(apiClient);
    _pagesFuture = _loadPages();

    if (_shouldUseWebView) {
      _initWebView();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_shouldUseWebView || _hasExternalLocalFile || _hasRemoteEpub) {
        await _loadSavedProgress();
        await _saveProgress();
      }
      _autoOpenRemoteFileIfNeeded();
    });
  }

  @override
  void dispose() {
    _progressSyncTimer?.cancel();
    _saveProgress(syncNow: true);
    _pageController.dispose();
    super.dispose();
  }

  void _autoOpenRemoteFileIfNeeded() {
    if (_autoOpenedRemoteFile || _shouldUseWebView || !_hasRemoteEpub) return;
    _autoOpenedRemoteFile = true;
    _openRemoteFileExternal(url: _remoteEpubLink, extension: 'epub');
  }

  void _initWebView() {
    final fixedUrl = _webViewUrl;
    if (fixedUrl.isEmpty) return;

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;

            setState(() {
              _webProgress = progress;
            });
          },
          onPageStarted: (_) {
            if (!mounted) return;

            setState(() {
              _webProgress = 0;
              _webHasError = false;
              _webErrorMessage = null;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;

            setState(() {
              _webProgress = 100;
            });
          },
          onWebResourceError: (error) {
            debugPrint('WEBVIEW ERROR: ${error.description}');
            if (!mounted) return;
            setState(() {
              _webHasError = true;
              _webErrorMessage = error.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(fixedUrl));
  }

  Future<String> _loadContent() async {
    final directContent = widget.contentText?.trim() ?? '';
    if (directContent.isNotEmpty) {
      return widget.contentText!;
    }

    final localPath = widget.localFilePath?.trim() ?? '';

    if (!kIsWeb && localPath.isNotEmpty) {
      final file = File(localPath);

      if (await file.exists()) {
        final lowerPath = localPath.toLowerCase();

        if (lowerPath.endsWith('.txt')) {
          return file.readAsString();
        }

        if (lowerPath.endsWith('.pdf')) {
          return 'File PDF da duoc luu tren thiet bi:\n$localPath\n\nBan co the mo file bang ung dung doc PDF ben ngoai.';
        }

        if (lowerPath.endsWith('.epub')) {
          return 'File EPUB da duoc luu tren thiet bi:\n$localPath\n\nBan co the mo file bang ung dung doc EPUB ben ngoai.';
        }

        return 'File đã được tải xuống:\n$localPath\n\nĐịnh dạng này chưa được Reader hỗ trợ đọc trực tiếp.';
      }
    }

    final assetPath = widget.assetPath?.trim() ?? '';
    if (assetPath.isNotEmpty) {
      return rootBundle.loadString(assetPath);
    }

    if (_hasOnlineLink) {
      return '';
    }

    return 'Sách này chưa có nội dung để đọc.';
  }

  Future<List<String>> _loadPages() async {
    final content = await _loadContent();
    final pages = _paginateContent(content);

    if (mounted && !_hasExternalLocalFile && !_shouldUseWebView) {
      setState(() {
        _textPageCount = pages.length;
      });
      await _loadSavedProgress(totalPageOverride: pages.length);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _jumpToCurrentTextPage();
      });
      await _saveProgress();
    }

    return pages;
  }

  List<String> _paginateContent(String content) {
    final normalized = _cleanBookText(content);
    if (normalized.trim().isEmpty || _hasExternalLocalFile) {
      return [normalized];
    }

    const maxChars = 1700;
    final paragraphs = normalized
        .split(RegExp(r'\n\s*\n'))
        .map((paragraph) => paragraph.trim())
        .where((paragraph) => paragraph.isNotEmpty);

    final pages = <String>[];
    final buffer = StringBuffer();

    void flushPage() {
      final page = buffer.toString().trim();
      if (page.isNotEmpty) pages.add(page);
      buffer.clear();
    }

    for (final paragraph in paragraphs) {
      if (paragraph.length > maxChars) {
        if (buffer.isNotEmpty) flushPage();
        for (var start = 0; start < paragraph.length; start += maxChars) {
          final end = (start + maxChars).clamp(0, paragraph.length).toInt();
          pages.add(paragraph.substring(start, end).trim());
        }
        continue;
      }

      final nextLength = buffer.length + paragraph.length + 2;
      if (nextLength > maxChars && buffer.isNotEmpty) {
        flushPage();
      }
      buffer.writeln(paragraph);
      buffer.writeln();
    }

    if (buffer.isNotEmpty) flushPage();
    return pages.isEmpty ? [normalized] : pages;
  }

  String _cleanBookText(String content) {
    var text = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
    text = text.replaceFirst('\uFEFF', '');

    final startMarker = RegExp(
      r'\*\*\*\s*START OF (THE|THIS) PROJECT GUTENBERG EBOOK.*?\*\*\*',
      caseSensitive: false,
      dotAll: true,
    );
    final endMarker = RegExp(
      r'\*\*\*\s*END OF (THE|THIS) PROJECT GUTENBERG EBOOK.*',
      caseSensitive: false,
      dotAll: true,
    );

    text = text.replaceFirst(startMarker, '').replaceFirst(endMarker, '');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return text.trim();
  }

  Future<void> _loadSavedProgress({int? totalPageOverride}) async {
    final bookId = widget.bookId;
    if (bookId == null || bookId.trim().isEmpty) return;

    final progress = await _readingProgressDao.getProgress(
      bookId,
      userId: widget.userId,
    );
    if (!mounted || progress == null) return;

    final savedPage =
        (progress['current_page'] as num?)?.toInt() ?? widget.value;
    final totalPage = totalPageOverride ?? _currentTotalPage;
    setState(() {
      newvalue = savedPage.clamp(1, totalPage).toInt();
    });
    _jumpToCurrentTextPage();
  }

  void _jumpToCurrentTextPage() {
    if (!_pageController.hasClients ||
        _shouldUseWebView ||
        _usesExternalReader) {
      return;
    }
    final pageIndex = (newvalue - 1).clamp(0, _currentTotalPage - 1).toInt();
    _pageController.jumpToPage(pageIndex);
  }

  Future<void> _saveProgress({bool syncNow = false}) async {
    final bookId = widget.bookId;
    if (bookId == null || bookId.trim().isEmpty) return;

    final totalPage = _currentTotalPage;
    final currentPage = _safeCurrentPage;
    final progressPercent = _progressPercent;

    await _readingProgressDao.saveProgress(
      bookId: bookId,
      currentPage: currentPage,
      totalPage: totalPage,
      progressPercent: progressPercent,
      bookTitle: widget.title,
      coverUrl: widget.coverUrl,
      userId: widget.userId,
    );

    if (mounted) {
      await _refreshReadingConsumers();
    }

    final backendBookId = int.tryParse(bookId);
    final userId = widget.userId;
    if (backendBookId == null || userId == null) return;

    if (syncNow) {
      _progressSyncTimer?.cancel();
      await _syncProgressToBackend(
        bookId: backendBookId,
        currentPage: currentPage,
        progressPercent: progressPercent,
        userId: userId,
      );
      return;
    }

    _scheduleProgressSync(
      bookId: backendBookId,
      currentPage: currentPage,
      progressPercent: progressPercent,
      userId: userId,
    );
  }

  void _scheduleProgressSync({
    required int bookId,
    required int currentPage,
    required double progressPercent,
    required int userId,
  }) {
    _progressSyncTimer?.cancel();
    _progressSyncTimer = Timer(const Duration(milliseconds: 800), () {
      _syncProgressToBackend(
        bookId: bookId,
        currentPage: currentPage,
        progressPercent: progressPercent,
        userId: userId,
      );
    });
  }

  Future<void> _syncProgressToBackend({
    required int bookId,
    required int currentPage,
    required double progressPercent,
    required int userId,
  }) async {
    try {
      await _readingProgressApi.saveProgress(
        bookId: bookId,
        currentPage: currentPage,
        progressPercent: progressPercent,
        userId: userId,
      );
    } catch (e) {
      debugPrint('SYNC PROGRESS ERROR: $e');
    }
  }

  Future<void> _saveBookmark() async {
    final bookId = widget.bookId;
    if (bookId == null || bookId.trim().isEmpty) return;
    final note = _bookmarkNote();
    final page = _safeCurrentPage;

    await _bookmarkDao.addBookmark(
      bookId: bookId,
      page: page,
      note: note,
      userId: widget.userId,
    );

    final backendBookId = int.tryParse(bookId);
    final userId = widget.userId;
    if (backendBookId == null || userId == null) return;

    try {
      await _bookmarkApi.addBookmark(
        bookId: backendBookId,
        page: page,
        note: note,
        userId: userId,
      );
    } catch (e) {
      debugPrint('SYNC BOOKMARK ERROR: $e');
    }
  }

  Future<void> _saveBookmarkFromToolbar() async {
    final bookId = widget.bookId;
    if (bookId == null || bookId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sách này chưa có mã sách để bookmark.')),
      );
      return;
    }

    if (_shouldUseWebView || _usesExternalReader) {
      final updated = await _showProgressDialog(
        title: 'Chọn mốc bookmark',
        saveText: 'Lưu mốc',
      );
      if (!updated) return;
    }

    await _saveBookmark();
    await _saveProgress(syncNow: true);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã lưu bookmark trang $_safeCurrentPage')),
    );
  }

  String _bookmarkNote() {
    return 'Trang $_safeCurrentPage';
  }

  Future<void> _showBookmarksDialog() async {
    final bookId = widget.bookId;
    if (bookId == null || bookId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sách này chưa có mã sách để lưu bookmark.'),
        ),
      );
      return;
    }

    final bookmarks = await _bookmarkDao.getBookmarks(
      bookId,
      userId: widget.userId,
    );
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        if (bookmarks.isEmpty) {
          return AlertDialog(
            title: const Text('Bookmark'),
            content: const Text('Chưa có bookmark nào cho sách này.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Dong'),
              ),
            ],
          );
        }

        return AlertDialog(
          title: const Text('Bookmark'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: bookmarks.length,
              itemBuilder: (_, index) {
                final bookmark = bookmarks[index];
                final id = bookmark['id'] as int;
                final page = bookmark['page'] as int? ?? 1;
                final note = bookmark['note']?.toString() ?? '';

                return ListTile(
                  title: Text(note.isNotEmpty ? note : 'Trang $page'),
                  subtitle: note.isEmpty
                      ? null
                      : Text('Trang tham chiếu $page'),
                  trailing: IconButton(
                    tooltip: 'Xóa bookmark',
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      await _bookmarkDao.deleteBookmark(
                        id,
                        userId: widget.userId,
                      );
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      await _showBookmarksDialog();
                    },
                  ),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _goToTextPage(page);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Dong'),
            ),
          ],
        );
      },
    );
  }

  void _showExitDialog() {
    final parentContext = context;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Rời khỏi trang',
          style: TextStyle(
            color: Colors.purple,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Ban co muon roi khoi trang hien tai? Neu muon luu dau trang, hay bam bieu tuong bookmark truoc khi roi trang.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _leaveReader(parentContext);
            },
            child: const Text('Rời khỏi'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Ở lại trang'),
          ),
        ],
      ),
    );
  }

  Future<void> _leaveReader(BuildContext parentContext) async {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (_) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    await _saveProgress(syncNow: true);

    if (!parentContext.mounted) return;
    Navigator.of(parentContext, rootNavigator: true).pop();

    if (!parentContext.mounted) return;
    Navigator.pushReplacementNamed(parentContext, AppRoute.home);
  }

  void _previousPage() {
    final totalPage = _currentTotalPage;
    final nextPage = newvalue - 1 <= 0 ? totalPage : newvalue - 1;
    _goToTextPage(nextPage);
  }

  void _nextPage() {
    final totalPage = _currentTotalPage;
    final nextPage = newvalue + 1 > totalPage ? 1 : newvalue + 1;
    _goToTextPage(nextPage);
  }

  void _goToTextPage(int page) {
    final targetPage = page.clamp(1, _currentTotalPage).toInt();
    if (_pageController.hasClients &&
        !_shouldUseWebView &&
        !_usesExternalReader) {
      _pageController.animateToPage(
        targetPage - 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
      return;
    }

    setState(() {
      newvalue = targetPage;
    });
    _saveProgress();
  }

  Future<void> _goBackWebView() async {
    final controller = _webViewController;

    if (controller == null) return;

    if (await controller.canGoBack()) {
      await controller.goBack();
    }
  }

  Future<void> _reloadWebView() async {
    final controller = _webViewController;

    if (controller == null) return;

    await controller.reload();
  }

  Future<void> _refreshReadingConsumers() async {
    if (!mounted) return;
    try {
      await context.read<HomeBookProvider>().refreshLocalData(
        userId: widget.userId,
      );
    } catch (_) {}

    if (!mounted) return;
    try {
      await context.read<LibraryProvider>().refreshLocalBooks(
        userId: widget.userId,
      );
    } catch (_) {}
  }

  Future<bool> _showProgressDialog({
    String title = 'Cập nhật tiến độ đọc',
    String saveText = 'Lưu',
  }) async {
    final totalPage = _currentTotalPage;
    var selectedPage = _safeCurrentPage;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Text('Trang $selectedPage / $totalPage'),
                  Slider(
                    value: selectedPage.toDouble(),
                    min: 1,
                    max: totalPage.toDouble(),
                    divisions: totalPage > 1 ? totalPage - 1 : null,
                    label: 'Trang $selectedPage',
                    onChanged: (value) {
                      setDialogState(() {
                        selectedPage = value.round().clamp(1, totalPage);
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      newvalue = selectedPage;
                    });
                    await _saveProgress(syncNow: true);
                    if (!dialogContext.mounted) return;
                    Navigator.pop(dialogContext, true);
                  },
                  child: Text(saveText),
                ),
              ],
            );
          },
        );
      },
    );
    return saved ?? false;
  }

  Future<void> _showReadingModeSheet() async {
    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chế độ đọc',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Nền đọc'),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'light', label: Text('Trắng')),
                      ButtonSegment(value: 'sepia', label: Text('Giấy')),
                      ButtonSegment(value: 'dark', label: Text('Tối')),
                    ],
                    selected: {_readingMode},
                    onSelectionChanged: (values) {
                      final value = values.first;
                      setSheetState(() => _readingMode = value);
                      setState(() => _readingMode = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Ánh sáng: ${(_lightLevel * 100).toStringAsFixed(0)}%'),
                  Slider(
                    value: _lightLevel,
                    min: 0.65,
                    max: 1.35,
                    divisions: 14,
                    label: '${(_lightLevel * 100).toStringAsFixed(0)}%',
                    onChanged: (value) {
                      setSheetState(() => _lightLevel = value);
                      setState(() => _lightLevel = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Cỡ chữ: ${(_fontScale * 100).toStringAsFixed(0)}%'),
                  Slider(
                    value: _fontScale,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    onChanged: (value) {
                      setSheetState(() => _fontScale = value);
                      setState(() => _fontScale = value);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPage = _currentTotalPage;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          onPressed: _showExitDialog,
          icon: const Icon(
            Icons.keyboard_arrow_down_outlined,
            size: 30,
            color: Colors.blue,
          ),
        ),
        actions: [
          if (_shouldUseWebView)
            IconButton(
              tooltip: 'Quay lại trang trước',
              onPressed: _goBackWebView,
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
            ),
          if (_shouldUseWebView)
            IconButton(
              tooltip: 'Tải lại',
              onPressed: _reloadWebView,
              icon: const Icon(Icons.refresh, color: Colors.blue),
            ),
          if (_shouldUseWebView || _usesExternalReader)
            IconButton(
              tooltip: 'Cap nhat trang doc',
              onPressed: _showProgressDialog,
              icon: const Icon(Icons.menu_book_outlined, color: Colors.blue),
            ),
          IconButton(
            tooltip: 'Chế độ đọc',
            onPressed: _showReadingModeSheet,
            icon: const Icon(Icons.tune, color: Colors.blue),
          ),
          IconButton(
            tooltip: 'Bình luận',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentPage(
                    bookId: widget.bookId ?? '',
                    title: widget.title,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.comment, color: Colors.blue),
          ),
          IconButton(
            tooltip: 'Lưu bookmark',
            onPressed: _saveBookmarkFromToolbar,
            icon: const Icon(Icons.bookmark_add_outlined, color: Colors.blue),
          ),
          IconButton(
            tooltip: 'Danh sách bookmark',
            onPressed: _showBookmarksDialog,
            icon: const Icon(Icons.bookmarks_outlined, color: Colors.blue),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _shouldUseWebView
          ? _buildWebReader()
          : (_hasRemotePdf || _hasRemoteEpub)
          ? _buildRemoteFileReader()
          : _buildTextReader(),
      bottomNavigationBar: (_shouldUseWebView || _usesExternalReader)
          ? null
          : _buildBottomPageNavigation(totalPage),
    );
  }

  Future<void> _openLocalFileExternal() async {
    final localPath = widget.localFilePath?.trim() ?? '';
    if (localPath.isEmpty) return;

    final result = await OpenFilex.open(localPath);
    if (!mounted) return;

    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở file: ${result.message}')),
      );
    }
  }

  Future<void> _openRemoteFileExternal({
    required String url,
    required String extension,
  }) async {
    if (url.trim().isEmpty || _isOpeningRemoteFile) return;

    setState(() {
      _isOpeningRemoteFile = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final safeBookId = (widget.bookId ?? widget.title).replaceAll(
        RegExp(r'[^a-zA-Z0-9_-]'),
        '_',
      );
      final filePath = p.join(
        directory.path,
        'books',
        '$safeBookId.$extension',
      );
      final file = File(filePath);
      await file.parent.create(recursive: true);

      if (!await file.exists() || await file.length() == 0) {
        await Dio().download(url.replaceFirst('http://', 'https://'), filePath);
      }

      final result = await OpenFilex.open(filePath);
      if (!mounted) return;

      if (result.type != ResultType.done) {
        final launched = await launchUrl(
          Uri.parse(url.replaceFirst('http://', 'https://')),
          mode: LaunchMode.externalApplication,
        );
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể mở file: ${result.message}')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể tải/mở file: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningRemoteFile = false;
        });
      }
    }
  }

  Future<void> _openOnlineLinkExternal(String url) async {
    if (url.trim().isEmpty) return;
    final launched = await launchUrl(
      Uri.parse(url.replaceFirst('http://', 'https://')),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở link đọc sách.')),
      );
    }
  }

  Widget _buildRemoteFileReader() {
    final isPdf = _hasRemotePdf;
    final link = isPdf ? _remotePdfLink : _remoteEpubLink;
    final extension = isPdf ? 'pdf' : 'epub';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isPdf ? Icons.picture_as_pdf : Icons.menu_book, size: 64),
            const SizedBox(height: 16),
            Text(
              isPdf
                  ? 'Sach nay co ban PDF. Tai ve va mo bang trinh doc PDF tren may.'
                  : 'Sach nay co ban EPUB. Tai ve va mo bang trinh doc EPUB tren may.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isOpeningRemoteFile
                  ? null
                  : () => _openRemoteFileExternal(
                      url: link,
                      extension: extension,
                    ),
              icon: _isOpeningRemoteFile
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.open_in_new),
              label: Text(
                _isOpeningRemoteFile ? 'Đang mở...' : 'Mở $extension',
              ),
            ),
            if (_hasOnlineLink) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _openOnlineLinkExternal(_onlineLink),
                child: const Text('Mở bản đọc online'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWebReader() {
    final controller = _webViewController;

    if (controller == null) {
      return const Center(child: Text('Không thể khởi tạo màn đọc online.'));
    }

    if (_webHasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _webErrorMessage ?? 'Không thể mở sách bằng WebView.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_hasRemotePdf)
                ElevatedButton.icon(
                  onPressed: _isOpeningRemoteFile
                      ? null
                      : () => _openRemoteFileExternal(
                          url: _remotePdfLink,
                          extension: 'pdf',
                        ),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Mở PDF'),
                ),
              if (_hasRemoteEpub)
                ElevatedButton.icon(
                  onPressed: _isOpeningRemoteFile
                      ? null
                      : () => _openRemoteFileExternal(
                          url: _remoteEpubLink,
                          extension: 'epub',
                        ),
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Mở EPUB'),
                ),
              TextButton(
                onPressed: () => _openOnlineLinkExternal(_onlineLink),
                child: const Text('Mở bằng trình duyệt'),
              ),
              TextButton(
                onPressed: _reloadWebView,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final lightOverlayColor = _readerLightOverlayColor();

    return Column(
      children: [
        if (_webProgress < 100)
          LinearProgressIndicator(value: _webProgress / 100),
        Expanded(
          child: Stack(
            children: [
              WebViewWidget(controller: controller),
              if (lightOverlayColor != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(color: lightOverlayColor),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextReader() {
    if (_hasExternalLocalFile) {
      return FutureBuilder<List<String>>(
        future: _pagesFuture,
        builder: (context, snapshot) {
          final message = snapshot.data?.first ?? 'File chưa sẵn sàng để mở.';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.insert_drive_file, size: 64),
                  const SizedBox(height: 16),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _openLocalFileExternal,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Mở bằng ứng dụng khác'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    final backgroundColor = _readerBackgroundColor();
    final textColor = _readerTextColor();
    final lightOverlayColor = _readerLightOverlayColor();

    return ColoredBox(
      color: backgroundColor,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: FutureBuilder<List<String>>(
              future: _pagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Không thể tải nội dung sách:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final pages = snapshot.data ?? const <String>[''];
                final totalPages = pages.isEmpty ? 1 : pages.length;
                return PageView.builder(
                  controller: _pageController,
                  itemCount: totalPages,
                  onPageChanged: (index) {
                    final page = index + 1;
                    if (newvalue == page) return;
                    setState(() {
                      newvalue = page;
                    });
                    _saveProgress();
                  },
                  itemBuilder: (context, index) {
                    final content = pages.isEmpty ? '' : pages[index];
                    return SingleChildScrollView(
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            content,
                            style: TextStyle(
                              fontSize: 18 * _fontScale,
                              height: 1.6,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          if (lightOverlayColor != null)
            Positioned.fill(
              child: IgnorePointer(child: ColoredBox(color: lightOverlayColor)),
            ),

          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 13),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(100),
                  bottomLeft: Radius.circular(100),
                ),
              ),
              child: Text(
                'Page $_safeCurrentPage of $_currentTotalPage',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),

          Positioned(
            top: 10,
            left: 0,
            child: Container(
              padding: const EdgeInsets.only(
                top: 5,
                bottom: 5,
                left: 0,
                right: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.blue[200],
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(100),
                          bottomRight: Radius.circular(100),
                        ),
                      ),
                      child: const Icon(Icons.menu, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 5),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.blue[200],
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Icon(Icons.text_format, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 50,
            right: 20,
            child: InkWell(
              onTap: _showReadingModeSheet,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(Icons.light_mode, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _readerBackgroundColor() {
    if (_readingMode == 'dark') return const Color(0xFF151515);
    if (_readingMode == 'sepia') return const Color(0xFFF4ECD8);
    return Colors.white;
  }

  Color _readerTextColor() {
    if (_readingMode == 'dark') return const Color(0xFFEDEDED);
    return const Color(0xFF202124);
  }

  Color? _readerLightOverlayColor() {
    final delta = _lightLevel - 1;
    if (delta.abs() < 0.01) return null;

    if (delta > 0) {
      final alpha = ((delta / 0.35) * 0.28).clamp(0, 0.28).toDouble();
      return Colors.white.withValues(alpha: alpha);
    }

    final alpha = (((-delta) / 0.35) * 0.32).clamp(0, 0.32).toDouble();
    return Colors.black.withValues(alpha: alpha);
  }

  Widget _buildBottomPageNavigation(int totalPage) {
    return Container(
      height: 70,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _previousPage,
            icon: const Icon(
              Icons.keyboard_arrow_left,
              size: 30,
              color: Colors.grey,
            ),
          ),
          Flexible(
            child: Text(
              'Page $_safeCurrentPage of $totalPage',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
          ),
          IconButton(
            onPressed: _nextPage,
            icon: const Icon(
              Icons.keyboard_arrow_right,
              size: 30,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
