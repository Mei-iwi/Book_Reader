import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/book_provider.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // Danh sách thể loại bám sát file thiết kế của bạn
  final List<String> categories = [
    "Science books",
    "History book",
    "Educational books",
    "Life skills books",
    "Travel books"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. THANH TÌM KIẾM (Search Bar) - Theo mục 4 & 8.1 trong file Word
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onSubmitted: (value) {
                  // Gọi logic tìm kiếm từ Provider
                  context.read<BookProvider>().search(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  suffixIcon: const Icon(Icons.search, color: Colors.blue),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),

            // 2. NHÓM NÚT LỌC (Category Tabs) - Bám sát giao diện Figma của bạn
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildTabButton("Book", const Color(0xFF91E4FB), isSelected: true),
                  const SizedBox(width: 8),
                  _buildTabButton("Comic", const Color(0xFF91E4FB)),
                  const SizedBox(width: 8),
                  _buildTabButton("Novel", const Color(0xFF91E4FB)),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 3. DANH SÁCH THỂ LOẠI (Category List)
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  return _buildCategoryItem(categories[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tạo nút Tab (Book, Comic, Novel) có viền đỏ nhạt như ảnh thiết kế
  Widget _buildTabButton(String title, Color color, {bool isSelected = false}) {
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.red.withOpacity(0.4), width: 1),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // Widget tạo dòng Thể loại (Science, History...) với bo góc lớn và icon mũi tên
 Widget _buildCategoryItem(String title) {
  // Bạn phải dùng lệnh return và một Widget (ở đây là Container)
  return Container(
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
    decoration: BoxDecoration(
      color: const Color(0xFFE0F7FA), // Màu xanh nhạt bám sát ảnh thiết kế
      borderRadius: BorderRadius.circular(35),
      border: Border.all(
        color: Colors.red.withOpacity(0.2), // Viền đỏ nhạt theo yêu cầu
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios, // Icon mũi tên bên phải
          size: 20,
          color: Colors.black,
        ),
      ],
    ),
  );
}
}