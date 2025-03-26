import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../config/theme.dart';
import 'dart:developer' as developer;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    developer.log(authService.toString(), name: 'HomeScreen');
    final user = authService.userModel;
    developer.log(user.toString(), name: 'HomeScreen');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.backgroundColor1, AppTheme.backgroundColor2],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Settings icon is now shown for all users
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                      child: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                        child: Icon(
                          Icons.settings,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    if (user != null)
                      IconButton(
                        icon: Icon(Icons.logout, color: Colors.black54),
                        onPressed: () async {
                          await authService.logout();
                          // ignore: use_build_context_synchronously
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                  ],
                ),

                user == null
                    ? _buildNotLoggedInContent(context)
                    : _buildLoggedInContent(user),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoggedInContent(user) {
    return Expanded(
      child: Column(
        children: [
          const SizedBox(height: 60.0),

          // Welcome message
          Center(
            child: ShaderMask(
              shaderCallback:
                  (bounds) => LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
              child: Text(
                'Welcome, ${user.name}!',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16.0),

          const Spacer(),

          const SizedBox(height: 40.0),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInContent(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Not logged in',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text(
                'Log In',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
