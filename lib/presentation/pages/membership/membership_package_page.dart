import 'package:book_reader/core/constants/templateImage.dart';
import 'package:book_reader/data/datasources/remote/api/membership_api.dart';
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
      context.read<MembershipProvider>().loadPackages();
    });
  }

  Future<void> _subscribe(List<MembershipPackageModel> packages) async {
    if (packages.isEmpty) return;

    final provider = context.read<MembershipProvider>();
    final success = await provider.subscribe(packages[_selectedIndex].id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Subscribe success'
              : provider.errorMessage ?? 'Subscribe failed',
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
      bottomNavigationBar: _buildBuyButton(provider.packages),
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
          _buildUserInfoCard(),
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

  Widget _buildUserInfoCard() {
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Member',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyButton(List<MembershipPackageModel> packages) {
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
