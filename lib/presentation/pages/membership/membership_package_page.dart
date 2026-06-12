import 'package:book_reader/core/constants/templateImage.dart';
import 'package:book_reader/data/datasources/remote/api/membership_api.dart';
import 'package:book_reader/presentation/state/auth_provider.dart';
import 'package:book_reader/presentation/state/membership_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembershipPackageScreen extends StatefulWidget {
  const MembershipPackageScreen({super.key});

  @override
  State<MembershipPackageScreen> createState() =>
      _MembershipPackageScreenState();
}

class _MembershipPackageScreenState extends State<MembershipPackageScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.userId;
      _loadMembership(userId);
    });
  }

  Future<void> _loadMembership(int? userId) async {
    final provider = context.read<MembershipProvider>();
    await provider.loadPackages(userId: userId);
    if (!mounted || provider.currentPlan == null) return;
    final index = provider.packages.indexWhere(
      (package) => package.id == provider.currentPlan!.membershipPackageId,
    );
    if (index >= 0) {
      setState(() => _selectedIndex = index);
    }
  }

  Future<void> _subscribe(List<MembershipPackageModel> packages) async {
    if (packages.isEmpty) return;

    final provider = context.read<MembershipProvider>();
    final userId = context.read<AuthProvider>().currentUser?.userId;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập lại.')));
      return;
    }

    final success = await provider.subscribe(
      packages[_selectedIndex].id,
      userId: userId,
    );

    if (!mounted) return;
    if (success) {
      final index = provider.packages.indexWhere(
        (package) => package.id == provider.currentPlan?.membershipPackageId,
      );
      if (index >= 0) {
        setState(() => _selectedIndex = index);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đăng ký hội viên thành công'
              : provider.errorMessage ?? 'Đăng ký hội viên thất bại',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MembershipProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
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
      body: _buildBody(provider),
      bottomNavigationBar: _buildBuyButton(provider),
    );
  }

  Widget _buildBody(MembershipProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.packages.isEmpty) {
      return Center(child: Text(provider.errorMessage!));
    }

    return SingleChildScrollView(
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
          _buildUserInfoCard(provider),
          const SizedBox(height: 16),
          _buildBenefitCard(provider),
          const SizedBox(height: 24),
          for (var i = 0; i < provider.packages.length; i++) ...[
            PackageCard(
              package: provider.packages[i],
              isSelected: _selectedIndex == i,
              onTap: () => setState(() => _selectedIndex = i),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(MembershipProvider provider) {
    final currentPlan = provider.currentPlan;
    final endDate = currentPlan?.endDate;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2176FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(Templateimage.avatar),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        currentPlan?.packageName.isNotEmpty == true
                            ? currentPlan!.packageName
                            : 'Độc giả miễn phí',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _PlanBadge(isActive: provider.hasActivePlan),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  provider.hasActivePlan
                      ? 'Còn ${provider.remainingDays} ngày - đến ${endDate == null ? 'N/A' : '${endDate.day}/${endDate.month}/${endDate.year}'}'
                      : 'Tài khoản miễn phí - nâng cấp để mở khóa Reading Pass',
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: provider.hasActivePlan ? provider.planProgress : 0,
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.cyanAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(MembershipProvider provider) {
    final limitText = provider.hasActivePlan
        ? 'Lưu sách offline không giới hạn'
        : 'Tài khoản miễn phí lưu tối đa ${MembershipProvider.freeOfflineBookLimit} sách offline';
    final benefits = [
      limitText,
      'Giao diện đọc Premium Focus',
      'Mua lại gói sẽ cộng thêm ngày sử dụng',
      'Hiển thị huy hiệu hội viên trong hồ sơ',
      'Cache gói hội viên để dùng khi mất mạng',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E9FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quyền lợi Reading Pass',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 10),
          for (final benefit in benefits)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF00BFA5), size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(benefit)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBuyButton(MembershipProvider provider) {
    final packages = provider.packages;
    final selectedPackage = packages.isEmpty ? null : packages[_selectedIndex];
    final isCurrent = provider.currentPlan?.membershipPackageId ==
        selectedPackage?.id && provider.hasActivePlan;

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: packages.isEmpty ? null : () => _subscribe(packages),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E5FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: Text(
            isCurrent ? 'GIA HẠN GÓI' : 'MUA NGAY',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  final bool isActive;

  const _PlanBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.greenAccent : Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'ĐANG DÙNG' : 'MIỄN PHÍ',
        style: TextStyle(
          color: isActive ? Colors.black87 : Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class PackageCard extends StatelessWidget {
  final MembershipPackageModel package;
  final bool isSelected;
  final VoidCallback onTap;

  const PackageCard({
    super.key,
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${package.durationDays} days of use',
                    style: const TextStyle(
                      color: Color(0xFF00BFA5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (package.description.isNotEmpty)
                    Text(
                      package.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Text(
              package.price.toStringAsFixed(0),
              style: const TextStyle(
                color: Color(0xFFAA00FF),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
