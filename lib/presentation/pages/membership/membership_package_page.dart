import 'package:flutter/material.dart';
import 'package:book_reader/core/constants/templateImage.dart';

class MembershipPackageScreen extends StatefulWidget {
  const MembershipPackageScreen({super.key});

  @override
  State<MembershipPackageScreen> createState() => _MembershipPackageScreenState();
}

class _MembershipPackageScreenState extends State<MembershipPackageScreen> {
  // Tạo biến lưu vết gói đang được chọn (0: 12 tháng, 1: 6 tháng, 2: 3 tháng)
  // Mặc định cho chọn sẵn gói đầu tiên (index 0)
  int _selectedIndex = 0; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'MEMBERSHIP\nPACKAGE',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF007BFF),
            fontWeight: FontWeight.w900,
            fontSize: 22,
            height: 1.1,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Experience over 100 copyrighted\nbooks and content',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // User Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2176FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(Templateimage.avatar), 
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mai Nhật Cường',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'MEMBER ACCOUNT',
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Expired: 26/04/2026',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Package Cards 
            // Truyền thêm trạng thái isSelected và sự kiện onTap
            PackageCard(
              months: '12',
              days: '365',
              price: '449.000 đ',
              originalPrice: '828.000đ',
              isSelected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            const SizedBox(height: 16),
            PackageCard(
              months: '6',
              days: '180',
              price: '269.000 đ',
              originalPrice: '414.000đ',
              isSelected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
            const SizedBox(height: 16),
            PackageCard(
              months: '3',
              days: '90',
              price: '149.000 đ',
              originalPrice: '207.000đ',
              isSelected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
              },
            ),
          ],
        ),
      ),
      
      // Bottom Buy Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Biết user chọn gói nào qua biến _selectedIndex
                  // 0 = Gói 12 tháng, 1 = Gói 6 tháng, 2 = Gói 3 tháng
                  print('User đang muốn mua gói số: $_selectedIndex');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'BUY NOW',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Automatically renew, cancel anytime',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PackageCard extends StatelessWidget {
  final String months;
  final String days;
  final String price;
  final String originalPrice;
  final bool isSelected; 
  final VoidCallback onTap; // Hàm được gọi khi người dùng bấm vào thẻ

  const PackageCard({
    super.key,
    required this.months,
    required this.days,
    required this.price,
    required this.originalPrice,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Bao bọc Container bằng GestureDetector để nhận diện thao tác bấm
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer( 
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB2F2BB) : const Color(0xFFD5F7E6), 
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF00BFA5) : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] 
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$months MONTHS',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$days days of use',
                  style: const TextStyle(
                    color: Color(0xFF00BFA5), 
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xFFAA00FF), 
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  originalPrice,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}