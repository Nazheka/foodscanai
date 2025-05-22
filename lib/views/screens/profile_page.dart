import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/providers/connectivity_provider.dart';
import 'package:read_the_label/services/auth_service.dart';
import 'package:read_the_label/models/user.dart';
import 'package:read_the_label/viewmodels/auth_view_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isRefreshing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  Future<void> _updateName(User user) async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await context.read<AuthViewModel>().updateUserName(_nameController.text);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated successfully')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update name')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await context.read<AuthViewModel>().updatePassword(
            _currentPasswordController.text,
            _newPasswordController.text,
          );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update password. Please check your current password.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showUpdateNameDialog(User user) {
    _nameController.text = user.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Name'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'New Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _updateName(user),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showUpdatePasswordDialog() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _updatePassword,
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return FutureBuilder<User?>(
      future: authService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.7),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading profile...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/auth');
          });
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.7),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Redirecting to login...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh),
                onPressed: _isRefreshing ? null : _handleRefresh,
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            child: Icon(
                              user.isGuest ? Icons.person_outline : Icons.person,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              if (user.isGuest)
                                const Text(
                                  'Guest User',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Account Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontFamily: 'Poppins',
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 3,
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.98),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
                          child: Column(
                            children: [
                              _infoTile(
                                context,
                                Icons.person,
                                'Name',
                                user.name,
                                onTap: user.isGuest ? null : () => _showUpdateNameDialog(user),
                              ),
                              const Divider(height: 24, thickness: 0.7),
                              _infoTile(context, Icons.email, 'Email', user.email),
                              const Divider(height: 24, thickness: 0.7),
                              _infoTile(context, Icons.badge, 'User ID', user.id ?? 'N/A'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Actions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            if (!user.isGuest)
                              ListTile(
                                leading: const Icon(Icons.lock_reset),
                                title: const Text('Change Password', style: TextStyle(fontFamily: 'Poppins')),
                                onTap: _showUpdatePasswordDialog,
                              ),
                            if (!user.isGuest) const Divider(height: 0),
                            Consumer<ConnectivityProvider>(
                              builder: (context, connectivityProvider, _) {
                                return ListTile(
                                  leading: const Icon(Icons.logout, color: Colors.red),
                                  title: const Text('Log out', style: TextStyle(color: Colors.red, fontFamily: 'Poppins')),
                                  onTap: () async {
                                    if (!connectivityProvider.isConnected) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please connect to the internet to log out.'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      return;
                                    }
                                    await context.read<AuthViewModel>().logout();
                                    if (context.mounted) {
                                      Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _infoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
        ],
      ),
    );
  }
} 