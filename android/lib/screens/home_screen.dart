import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/game_service.dart';
import '../models/rank_model.dart';
import '../config/theme.dart';
import 'dart:developer' as developer;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RankModel? userRank;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserRank();
  }

  Future<void> _fetchUserRank() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.userModel;

    if (user != null) {
      setState(() {
        isLoading = true;
      });

      try {
        final gameService = GameService();
        final auth = authService.user;
        final rank = await gameService.getUserRank(auth!.uid);
        if (mounted) {
          setState(() {
            userRank = rank;
            isLoading = false;
          });
        }
      } catch (e) {
        developer.log('Error fetching rank: $e', name: 'HomeScreen');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

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

          const SizedBox(height: 24.0),

          // Rank information
          if (isLoading)
            CircularProgressIndicator(color: AppTheme.primaryColor)
          else if (userRank != null)
            _buildRankCard(),

          const Spacer(),

          const SizedBox(height: 40.0),
        ],
      ),
    );
  }

  Widget _buildRankCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.7),
            AppTheme.secondaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Text(
                'Your Ranking',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRankItem('Rank', '#${userRank?.rank ?? 0}'),
              _buildRankItem('Points', '${userRank?.points ?? 0}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
