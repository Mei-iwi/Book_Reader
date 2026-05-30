import 'dart:io';

import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/services/http/api_client.dart';
import 'package:book_reader/data/datasources/local/dao/bookmark_dao.dart';
import 'package:book_reader/data/datasources/local/dao/reading_progress_dao.dart';
import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/remote/api/bookmark_api.dart';
import 'package:book_reader/data/datasources/remote/api/reading_progress_api.dart';
import 'package:book_reader/presentation/pages/comment/comments.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Reader extends StatefulWidget {
  final int value;
  final int total;
  final String title;
  final String? bookId;

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

  const Reader({
    super.key,
    required this.value,
    required this.total,
    required this.title,
    this.bookId,
    this.localFilePath,
    this.assetPath,
    this.contentText,
    this.webReaderLink,
    this.previewLink,
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

  String get _onlineLink {
    final webReaderLink = widget.webReaderLink?.trim() ?? '';
    final previewLink = widget.previewLink?.trim() ?? '';

    if (webReaderLink.isNotEmpty) return webReaderLink;
    if (previewLink.isNotEmpty) return previewLink;

    return '';
  }

  bool get _hasOnlineLink => _onlineLink.isNotEmpty;

  bool get _hasLocalTextFile {
    final localPath = widget.localFilePath?.trim() ?? '';
    return localPath.toLowerCase().endsWith('.txt');
  }

  bool get _shouldUseWebView {
    final localPath = widget.localFilePath?.trim() ?? '';

    if (_hasLocalTextFile) return false;

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
          return 'File PDF đã được tải xuống:\n$localPath\n\nReader hiện tại chưa render PDF trực tiếp. Bạn nên tạo thêm PdfReaderPage bằng package đọc PDF.';
        }

        if (lowerPath.endsWith('.epub')) {
          return 'File EPUB đã được tải xuống:\n$localPath\n\nReader hiện tại chưa render EPUB trực tiếp. Bạn cần thêm thư viện đọc EPUB.';
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
    if (backendBookId == null) return;

    try {
      await _readingProgressApi.saveProgress(
        bookId: backendBookId,
        currentPage: newvalue,
        progressPercent: progressPercent,
        userId: 1,
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
    if (backendBookId == null) return;

    try {
      await _bookmarkApi.addBookmark(
        bookId: backendBookId,
        page: newvalue,
        userId: 1,
      );
    } catch (e) {
      debugPrint('SYNC BOOKMARK ERROR: $e');
    }
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

              showDialog(
                context: parentContext,
                barrierDismissible: false,
                builder: (_) {
                  return const Center(child: CircularProgressIndicator());
                },
              );

              await Future.delayed(const Duration(seconds: 1));

              if (!parentContext.mounted) return;

              Navigator.of(parentContext, rootNavigator: true).pop();

              await _saveProgress();

              if (!parentContext.mounted) return;
              Navigator.pushReplacementNamed(parentContext, AppRoute.home);
            },
            child: const Text('Rời khỏi'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: xử lý lưu bookmark ở đây
              await _saveBookmark();
              await _saveProgress();
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
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
                MaterialPageRoute(builder: (context)=>const BookDetailPage())
                );
            },
            icon: const Icon(Icons.comment, color: Colors.blue),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.blue),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _shouldUseWebView ? _buildWebReader() : _buildTextReader(),
      bottomNavigationBar: _shouldUseWebView
          ? null
          : _buildBottomPageNavigation(totalPage),
    );
  }

  Widget _buildWebReader() {
    final controller = _webViewController;

    if (controller == null) {
      return const Center(child: Text('Không thể khởi tạo màn đọc online.'));
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
