import 'package:book_reader/config/routes.dart';
import 'package:book_reader/data/models/admin_user_model.dart';
import 'package:book_reader/presentation/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final authProvider = context.read<AuthProvider>();
    final hasSession = await authProvider.loadSession();
    if (!mounted) return;

    if (!hasSession || !authProvider.isAdmin) {
      Navigator.pushReplacementNamed(context, AppRoute.adminLogin);
      return;
    }

    final success = await authProvider.loadAdminUsers();
    if (!mounted || success) return;
    _showMessage(authProvider.errorMessage ?? 'Cannot load users');
  }

  List<AdminUserModel> _filteredUsers(List<AdminUserModel> users) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return users;
    return users.where((user) {
      return user.fullName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoute.adminLogin);
  }

  Future<void> _deleteUser(AdminUserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa người dùng'),
        content: Text('Xóa ${user.email}? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.deleteAdminUser(user.userId);
    if (!mounted) return;
    _showMessage(
      success
          ? 'User deleted.'
          : authProvider.errorMessage ?? 'Cannot delete user',
    );
  }

  Future<void> _toggleActive(AdminUserModel user) async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateAdminUser(
      userId: user.userId,
      fullName: user.fullName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      avatarUrl: user.avatarUrl,
      role: user.role,
      isActive: !user.isActive,
    );
    if (!mounted) return;
    _showMessage(
      success
          ? (user.isActive ? 'User locked.' : 'User unlocked.')
          : authProvider.errorMessage ?? 'Cannot update user',
    );
  }

  Future<void> _openUserDialog([AdminUserModel? user]) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _AdminUserDialog(user: user),
    );
    if (result != true || !mounted) return;
    _showMessage(user == null ? 'User created.' : 'User updated.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final users = _filteredUsers(authProvider.adminUsers);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: authProvider.isLoading ? null : _load,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: authProvider.isLoading ? null : () => _openUserDialog(),
        icon: const Icon(Icons.person_add),
        label: const Text('Add user'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage accounts',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Search name, email or role',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (authProvider.isLoading)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: users.isEmpty
                  ? const Center(child: Text('No users found.'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return _AdminUserTile(
                            user: user,
                            onEdit: () => _openUserDialog(user),
                            onToggleActive: () => _toggleActive(user),
                            onDelete: () => _deleteUser(user),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminUserTile extends StatelessWidget {
  final AdminUserModel user;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _AdminUserTile({
    required this.user,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roleColor = user.role.toLowerCase() == 'admin'
        ? Colors.blue
        : theme.colorScheme.onSurfaceVariant;
    final statusColor = user.isActive ? Colors.green : Colors.red;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withValues(alpha: 0.12),
          child: Text(
            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
            style: TextStyle(color: roleColor, fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(
          user.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(user.role),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(color: roleColor.withValues(alpha: 0.25)),
                ),
                Chip(
                  label: Text(user.isActive ? 'Active' : 'Locked'),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(color: statusColor.withValues(alpha: 0.25)),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'toggle':
                onToggleActive();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
              value: 'toggle',
              child: Text(user.isActive ? 'Lock account' : 'Unlock account'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

class _AdminUserDialog extends StatefulWidget {
  final AdminUserModel? user;

  const _AdminUserDialog({this.user});

  @override
  State<_AdminUserDialog> createState() => _AdminUserDialogState();
}

class _AdminUserDialogState extends State<_AdminUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late String _role;
  late bool _isActive;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _role = user?.role == 'Admin' ? 'Admin' : 'User';
    _isActive = user?.isActive ?? true;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = context.read<AuthProvider>();
    final success = _isEditing
        ? await authProvider.updateAdminUser(
            userId: widget.user!.userId,
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            avatarUrl: widget.user!.avatarUrl,
            password: _passwordController.text.trim().isEmpty
                ? null
                : _passwordController.text,
            confirmPassword: _confirmPasswordController.text.trim().isEmpty
                ? null
                : _confirmPasswordController.text,
            role: _role,
            isActive: _isActive,
          )
        : await authProvider.createAdminUser(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
            role: _role,
            isActive: _isActive,
          );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(authProvider.errorMessage ?? 'Lưu thất bại')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return AlertDialog(
      title: Text(_isEditing ? 'Edit user' : 'Add user'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: _required,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: _required,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'User', child: Text('User')),
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _role = value);
                },
              ),
              SwitchListTile(
                value: _isActive,
                contentPadding: EdgeInsets.zero,
                title: const Text('Active account'),
                onChanged: (value) => setState(() => _isActive = value),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: _isEditing
                      ? 'New password (optional)'
                      : 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (!_isEditing && (value == null || value.isEmpty)) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: _isEditing
                      ? 'Confirm new password'
                      : 'Confirm password',
                ),
                obscureText: true,
                validator: (value) {
                  final password = _passwordController.text;
                  if (!_isEditing && (value == null || value.isEmpty)) {
                    return 'Confirm password is required';
                  }
                  if (password.isNotEmpty && value != password) {
                    return 'Confirm password does not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: isLoading ? null : _save,
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}
