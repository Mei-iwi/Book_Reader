import 'package:book_reader/data/datasources/local/dao/profile_dao.dart';
import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/presentation/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Key để quản lý Form validation
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các trường nhập liệu
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Biến trạng thái ẩn/hiện mật khẩu
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      final dao = ProfileDao(AppDatabase.instance);
      final profile = await dao.getProfile(user.userId.toString());
      if (profile != null) {
        setState(() {
          _nameController.text = profile['full_name'] ?? user.fullName;
          _emailController.text = profile['email'] ?? user.email;
          _phoneController.text = ''; // Add to db if needed
        });
      } else {
        setState(() {
          _nameController.text = user.fullName;
          _emailController.text = user.email;
        });
      }
    }
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi huỷ trang
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSavePressed() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        final dao = ProfileDao(AppDatabase.instance);
        await dao.saveProfile(
          id: user.userId.toString(),
          fullName: _nameController.text,
          email: _emailController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lưu thông tin thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tự động ẩn bàn phím khi chạm ra ngoài vùng textfield
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // --- PHẦN HEADER & AVATAR ---
              SizedBox(
                height: 250,
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    // Background nửa trên màu xanh dương nhạt
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFA5F4FF), Color(0xFF6DE4D5)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Nút Back
                    Positioned(
                      top: 40, // Căn lề an toàn cho tai thỏ
                      left: 10,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.black87,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    // Avatar & Nút Edit
                    Positioned(
                      top: 100, // Căn để avatar đè lên ranh giới 2 màu
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 50,
                              // Dùng ảnh cỏ 4 lá tương tự mockup (bạn thay bằng link thật hoặc Asset)
                              backgroundImage: NetworkImage(
                                'https://cdn.pixabay.com/photo/2013/07/12/17/00/four-leaf-clover-151042_1280.png',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Nút Edit Avatar
                          InkWell(
                            onTap: () {
                              // TODO: Xử lý đổi avatar
                            },
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Edit avatar",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- PHẦN FORM NHẬP LIỆU ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 10.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'Name:',
                        controller: _nameController,
                        validator: (value) =>
                            value!.isEmpty ? 'Vui lòng nhập tên' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Email:',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) return 'Vui lòng nhập email';
                          if (!value.contains('@')) return 'Email không hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Phone:',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Password:',
                        controller: _passwordController,
                        isPassword: true,
                        obscureText: _obscurePassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        hintText: 'Nhập mật khẩu mới (nếu muốn)',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Confirm password:',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        hintText: 'Nhập lại mật khẩu',
                        validator: (value) {
                          if (_passwordController.text.isNotEmpty &&
                              value != _passwordController.text) {
                            return 'Mật khẩu không khớp!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),

                      // --- NÚT SAVE ---
                      ElevatedButton(
                        onPressed: _onSavePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFCBE4F9,
                          ), // Màu xanh nhạt của nút
                          foregroundColor: Colors.black,
                          elevation: 3,
                          shadowColor: Colors.grey.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: const Size(200, 50),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40), // Căn lề dưới
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET CHUẨN HOÁ TEXTFIELD ---
  // Hàm này giúp tạo ra các ô nhập liệu giống nhau mà không phải viết lại code nhiều lần
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.black87, fontSize: 15),
      decoration: InputDecoration(
        // Căn lề chữ bên trong ô
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        // Chữ tiền tố (VD: "Name: ")
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        // Icon con mắt cho password
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        // Viền khi ở trạng thái bình thường
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF5A4FCF),
            width: 1.2,
          ), // Màu viền tím đậm giống ảnh
        ),
        // Viền khi đang click vào để gõ
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF5A4FCF), width: 2.0),
        ),
        // Viền khi báo lỗi
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }
}
