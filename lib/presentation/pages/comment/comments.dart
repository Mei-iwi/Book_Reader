import 'package:book_reader/presentation/pages/reader/reader.dart';
import 'package:flutter/material.dart';

class BookDetailPage extends StatefulWidget {
  const BookDetailPage({super.key});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  // State cho phần nội dung mở rộng
  bool _isExpanded = false;

  // State cho phần bình luận của user hiện tại
  double _currentUserRating = 0.0;
  final TextEditingController _commentController = TextEditingController();

  // Dữ liệu giả lập nội dung sách
  final String _mainContent =
      "Harry Potter và Hòn đá Phù thủy là phần đầu tiên của loạt tiểu thuyết. "
      "Truyện kể về cậu bé Harry Potter mồ côi cha mẹ, sống khổ sở dưới gầm cầu thang nhà dì dượng Dursley. "
      "Vào sinh nhật lần thứ 11, cậu nhận được thư mời nhập học từ trường Phù thủy và Pháp sư Hogwarts. "
      "Tại đây, cậu khám phá ra sự thật về cái chết của cha mẹ mình, kết bạn với Ron Weasley, Hermione Granger "
      "và đối đầu với Chúa tể hắc ám Voldemort - kẻ đang tìm kiếm Hòn đá Phù thủy để phục sinh. "
      "Cuốn sách mở ra một thế giới phép thuật vô cùng kỳ diệu và hấp dẫn người đọc ở mọi lứa tuổi.";

  // Dữ liệu giả lập comment
  final List<Map<String, dynamic>> _comments = [
    {
      "name": "Alex Johnson",
      "rating": 4.0,
      "text": "Sách rất hay, mở đầu cho một huyền thoại. Đọc đi đọc lại không chán.",
    },
    {
      "name": "Maria Davis",
      "rating": 5.0,
      "text": "Tuyệt vời! Tuổi thơ của tôi gói gọn trong cuốn sách này.",
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty || _currentUserRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao và nhập bình luận')),
      );
      return;
    }
    
    // Thêm comment mới vào danh sách (đẩy lên đầu)
    setState(() {
      _comments.insert(0, {
        "name": "Tên Của Bạn", // Lấy từ thông tin user đăng nhập
        "rating": _currentUserRating,
        "text": _commentController.text.trim(),
      });
      // Reset form sau khi gửi
      _commentController.clear();
      _currentUserRating = 0.0;
    });
    
    FocusScope.of(context).unfocus(); // Ẩn bàn phím
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // Cấu trúc: Phần trên cuộn được, phần Comment ở dưới cố định
      body: Column(
        children: [
          // Phần cuộn được
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookHeader(),
                  const SizedBox(height: 20),
                  _buildMainContent(),
                  const Divider(height: 30, thickness: 1, color: Colors.grey),
                  _buildCommentList(),
                ],
              ),
            ),
          ),
          
          // Phần nhập comment cố định ở dưới cùng
          _buildFixedBottomCommentArea(),
        ],
      ),
    );
  }

  // --- WIDGET CÁC THÀNH PHẦN ---

  Widget _buildBookHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ảnh bìa sách
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            'https://upload.wikimedia.org/wikipedia/vi/a/a3/Harry_Potter_v%C3%A0_H%C3%B2n_%C4%91%C3%A1_Ph%C3%B9_th%E1%BB%A7y.jpg', // Link ảnh mẫu
            width: 100,
            height: 140,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 100, height: 140, color: Colors.grey[300],
              child: const Icon(Icons.book, size: 40),
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Thông tin sách
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Book title:', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const Text(
                'Harry potter',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Author: J.K. Rowling', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
              const Text('Year: 1997', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('4.5', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Icon(Icons.star_border, size: 16),
                  const SizedBox(width: 8),
                  const Text('400 review', style: TextStyle(decoration: TextDecoration.underline, color: Colors.grey)),
                  const Spacer(),
                  // Nút Read
                  ElevatedButton(
                    onPressed: () {
                      // Chuyển tới trang Reader và truyền dữ liệu sách vào
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Reader(
                            value: 1, 
                            total: 100, 
                            title: '',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6DE4D5),
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Read', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const Text('100 Page', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Main content',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _mainContent,
          maxLines: _isExpanded ? 10 : 2, // Mở rộng tối đa 10 dòng, thu gọn 2 dòng
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
        ),
        Center(
          child: IconButton(
            icon: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 32,
              color: Colors.black54,
            ),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
        )
      ],
    );
  }

  Widget _buildCommentList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true, // Quan trọng để đặt trong SingleChildScrollView
          physics: const NeverScrollableScrollPhysics(), // Tắt cuộn của listview, để cuộn theo trang
          itemCount: _comments.length,
          itemBuilder: (context, index) {
            final comment = _comments[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.purple.withOpacity(0.2),
                    child: const Icon(Icons.person_outline, color: Colors.purple),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment['name'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        // Đánh giá tĩnh (không bấm được)
                        StarRating(
                          rating: comment['rating'],
                          starSize: 18,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          comment['text'],
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFixedBottomCommentArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16, 
        right: 16, 
        top: 12, 
        bottom: MediaQuery.of(context).padding.bottom + 12 // Căn lề an toàn cho iPhone (tai thỏ/home bar)
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.purple.withOpacity(0.2),
            child: const Icon(Icons.person_outline, color: Colors.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tên Của Bạn', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                // Khung nhập comment có border bo tròn giống thiết kế
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Đánh giá động (Bấm được)
                      StarRating(
                        rating: _currentUserRating,
                        starSize: 24,
                        isInteractive: true,
                        onRatingChanged: (rating) {
                          setState(() {
                            _currentUserRating = rating;
                          });
                        },
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              maxLines: 3,
                              minLines: 1,
                              decoration: const InputDecoration(
                                hintText: 'Write comment',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _submitComment,
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.send_outlined, color: Colors.black87),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- CUSTOM WIDGET: Đánh giá Sao ---
// Cho phép tái sử dụng cho cả phần Read-only (bình luận cũ) và Interactive (viết bình luận)
class StarRating extends StatelessWidget {
  final double rating;
  final double starSize;
  final bool isInteractive;
  final Function(double)? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.starSize = 20,
    this.isInteractive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: isInteractive && onRatingChanged != null
              ? () => onRatingChanged!(index + 1.0)
              : null,
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            size: starSize,
            color: Colors.black87,
          ),
        );
      }),
    );
  }
}