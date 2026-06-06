import 'dart:io';

import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/services/http/api_client.dart';
import 'package:book_reader/data/datasources/local/dao/bookmark_dao.dart';
import 'package:book_reader/data/datasources/local/dao/reading_progress_dao.dart';
import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/remote/api/bookmark_api.dart';
import 'package:book_reader/data/datasources/remote/api/reading_progress_api.dart';
import 'package:book_reader/presentation/pages/comment/comments.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Reader extends StatefulWidget {
  final int value;
  final int total;
  final String title;
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
  late Future<String> _contentFuture;
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
    if (_hasRemotePdf || _hasRemoteEpub) return false;

    // Nếu chưa có file local đọc được, ưu tiên hiển thị Google Books trong app.
    if (_hasOnlineLink) return true;

    // Nếu là PDF/EPUB local thì Reader này chưa render trực tiếp.
    // Có thể mở bằng màn PDF/EPUB riêng sau.
    if (localPath.toLowerCase().endsWith('.pdf')) return false;
    if (localPath.toLowerCase().endsWith('.epub')) return false;

    return false;
  }

  @override
  void initState() {
    super.initState();

    _contentFuture = _loadContent();
    final appDatabase = AppDatabase.instance;
    final apiClient = ApiClient();
    _readingProgressDao = ReadingProgressDao(appDatabase);
    _bookmarkDao = BookmarkDao(appDatabase);
    _readingProgressApi = ReadingProgressApi(apiClient);
    _bookmarkApi = BookmarkApi(apiClient);

    if (_shouldUseWebView) {
      _initWebView();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedProgress();
      _saveProgress();
      _autoOpenRemoteFileIfNeeded();
    });
  }

  void _autoOpenRemoteFileIfNeeded() {
    if (_autoOpenedRemoteFile || (!_hasRemotePdf && !_hasRemoteEpub)) return;
    _autoOpenedRemoteFile = true;
    final isPdf = _hasRemotePdf;
    _openRemoteFileExternal(
      url: isPdf ? _remotePdfLink : _remoteEpubLink,
      extension: isPdf ? 'pdf' : 'epub',
    );
  }

  void _initWebView() {
    final fixedUrl = _onlineLink.replaceFirst('http://', 'https://');

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

  Future<void> _loadSavedProgress() async {
    final bookId = widget.bookId;
    if (bookId == null || bookId.trim().isEmpty) return;

    final progress = await _readingProgressDao.getProgress(bookId);
    if (!mounted || progress == null) return;

    final savedPage = progress['current_page'] as int? ?? widget.value;
    final totalPage = widget.total <= 0 ? 1 : widget.total;
    setState(() {
      newvalue = savedPage.clamp(1, totalPage);
    });
  }

  Future<void> _saveProgress() async {
    final bookId = widget.bookId;
    if (bookId == null || bookId.trim().isEmpty) return;

    final totalPage = widget.total <= 0 ? 1 : widget.total;
    final progressPercent = (newvalue / totalPage) * 100;

    await _readingProgressDao.saveProgress(
      bookId: bookId,
      currentPage: newvalue,
      progressPercent: progressPercent,
    );

    final backendBookId = int.tryParse(bookId);
    final userId = widget.userId;
    if (backendBookId == null || userId == null) return;

    try {
      await _readingProgressApi.saveProgress(
        bookId: backendBookId,
        currentPage: newvalue,
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

    await _bookmarkDao.addBookmark(bookId: bookId, page: newvalue);

    final backendBookId = int.tryParse(bookId);
    final userId = widget.userId;
    if (backendBookId == null || userId == null) return;

    try {
      await _bookmarkApi.addBookmark(
        bookId: backendBookId,
        page: newvalue,
        userId: userId,
      );
    } catch (e) {
      debugPrint('SYNC BOOKMARK ERROR: $e');
    }
  }

  Future<void> _showBookmarksDialog() async {
    final bookId = widget.bookId;
    if (bookId == null || bookId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sach nay chua co ma sach de luu bookmark.'),
        ),
      );
      return;
    }

    final bookmarks = await _bookmarkDao.getBookmarks(bookId);
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        if (bookmarks.isEmpty) {
          return AlertDialog(
            title: const Text('Bookmark'),
            content: const Text('Chua co bookmark nao cho sach nay.'),
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
                  title: Text('Trang $page'),
                  subtitle: note.isEmpty ? null : Text(note),
                  trailing: IconButton(
                    tooltip: 'Xoa bookmark',
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      await _bookmarkDao.deleteBookmark(id);
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      await _showBookmarksDialog();
                    },
                  ),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    if (!_shouldUseWebView) {
                      setState(() {
                        newvalue = page;
                      });
                    }
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
        content: const Text('Bạn có muốn rời khỏi trang hiện tại?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _leaveReader(parentContext);
            },
            child: const Text('Rời khỏi'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: xử lý lưu bookmark ở đây
              Navigator.pop(dialogContext);
              await _leaveReader(parentContext, saveBookmark: true);
            },
            child: const Text('Lưu bookmark rời khỏi'),
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

  Future<void> _leaveReader(
    BuildContext parentContext, {
    bool saveBookmark = false,
  }) async {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (_) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    if (saveBookmark) {
      await _saveBookmark();
    }
    await _saveProgress();

    if (!parentContext.mounted) return;
    Navigator.of(parentContext, rootNavigator: true).pop();

    if (!parentContext.mounted) return;
    Navigator.pushReplacementNamed(parentContext, AppRoute.home);
  }

  void _previousPage() {
    setState(() {
      newvalue - 1 <= 0 ? newvalue = widget.total : newvalue -= 1;
    });
    _saveProgress();
  }

  void _nextPage() {
    setState(() {
      newvalue + 1 > widget.total ? newvalue = 1 : newvalue += 1;
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

  @override
  Widget build(BuildContext context) {
    final totalPage = widget.total <= 0 ? 1 : widget.total;

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
            tooltip: 'Bookmark',
            onPressed: _showBookmarksDialog,
            icon: const Icon(Icons.more_vert, color: Colors.blue),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _shouldUseWebView
          ? _buildWebReader()
          : (_hasRemotePdf || _hasRemoteEpub)
          ? _buildRemoteFileReader()
          : _buildTextReader(),
      bottomNavigationBar: _shouldUseWebView
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
        SnackBar(content: Text('Khong the mo file: ${result.message}')),
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
      final filePath = p.join(directory.path, 'books', '$safeBookId.$extension');
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
            SnackBar(content: Text('Khong the mo file: ${result.message}')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Khong the tai/mo file: $e')),
      );
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
        const SnackBar(content: Text('Khong the mo link doc sach.')),
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
              label: Text(_isOpeningRemoteFile ? 'Dang mo...' : 'Mo $extension'),
            ),
            if (_hasOnlineLink) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _openOnlineLinkExternal(_onlineLink),
                child: const Text('Mo ban doc online'),
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
                _webErrorMessage ?? 'Khong the mo sach bang WebView.',
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
                  label: const Text('Mo PDF'),
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
                  label: const Text('Mo EPUB'),
                ),
              TextButton(
                onPressed: () => _openOnlineLinkExternal(_onlineLink),
                child: const Text('Mo bang trinh duyet'),
              ),
              TextButton(
                onPressed: _reloadWebView,
                child: const Text('Thu lai'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_webProgress < 100)
          LinearProgressIndicator(value: _webProgress / 100),
        Expanded(child: WebViewWidget(controller: controller)),
      ],
    );
  }

  Widget _buildTextReader() {
    if (_hasExternalLocalFile) {
      return FutureBuilder<String>(
        future: _contentFuture,
        builder: (context, snapshot) {
          final message = snapshot.data ?? 'File chua san sang de mo.';
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
                    label: const Text('Mo bang ung dung khac'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: FutureBuilder<String>(
            future: _contentFuture,
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

              final content = snapshot.data ?? '';

              return SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      content,
                      style: const TextStyle(fontSize: 18, height: 1.6),
                    ),
                  ),
                ),
              );
            },
          ),
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
              'Page $newvalue',
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
            onTap: () {
              // TODO: xử lý chế độ bảo vệ mắt
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[200],
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(Icons.remove_red_eye, color: Colors.white),
            ),
          ),
        ),
      ],
    );
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
          Text(
            'Page $newvalue of $totalPage',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 18,
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
