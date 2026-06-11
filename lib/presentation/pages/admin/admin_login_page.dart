import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/my_images.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/banner.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/button_style.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/form.dart';
import 'package:book_reader/presentation/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (!success) {
      _showMessage(authProvider.errorMessage ?? 'Admin login failed');
      return;
    }

    if (!authProvider.isAdmin) {
      await authProvider.logout();
      if (!mounted) return;
      _showMessage('Only admin accounts can access this page.');
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoute.adminDashboard);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            myBanner(urlBanner: Myimages.myBanner, text: 'Admin Login'),
            const SizedBox(height: 70),
            FormInput(
              text: 'Admin Email',
              icon: Icons.admin_panel_settings,
              isPassword: false,
              controller: _emailController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            FormInput(
              text: 'Password',
              icon: Icons.lock,
              isPassword: true,
              controller: _passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            if (isLoading)
              const CircularProgressIndicator()
            else
              buttonFull(text: 'Login as Admin', func: _login),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoute.login);
              },
              child: const Text('Back to user login'),
            ),
          ],
        ),
      ),
    );
  }
}
