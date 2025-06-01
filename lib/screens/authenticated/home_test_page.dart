import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../models/auth/user_model.dart';
import '../../screens/auth/sign_in_page.dart';
import '../../widgets/common/page_transition.dart';

class HomeTestPage extends StatelessWidget {
  const HomeTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Test Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Logout
              await authProvider.logout();

              // Redirect to login page
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  AppPageTransition.fade(
                    const SignInPage(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'User connected successfully!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // User information
            if (user != null) ...[
              _buildUserInfoCard(context, user),
            ] else ...[
              const Text('User information not available'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, UserModel user) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blueAccent),
            title: const Text('Username'),
            subtitle: Text(user.username),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.blueAccent),
            title: const Text('Email'),
            subtitle: Text(user.email),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.access_time, color: Colors.blueAccent),
            title: const Text('Last login'),
            subtitle: Text(user.lastLogin.toString()),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.stars, color: Colors.blueAccent),
            title: const Text('Points'),
            subtitle: Text(user.points.toString()),
          ),
        ],
      ),
    );
  }
}
