import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/leaderboard_user_model.dart';
import '../services/game_service.dart';
import '../services/auth_service.dart';
import 'dart:developer' as developer;

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final GameService _gameService = GameService();
  bool _isLoading = false;
  List<LeaderboardUserModel> _leaderboardUsers = [];
  int _currentPage = 1;
  int _totalPages = 1;
  final int _usersPerPage = 10;
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadCurrentUserId();
    _fetchLeaderboard();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadCurrentUserId() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;
    if (user != null) {
      _currentUserId = user.uid;
    }
  }

  void _scrollListener() {
    if (!_isLoading &&
        _currentPage < _totalPages &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _fetchMoreUsers();
    }
  }

  Future<void> _fetchLeaderboard({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _leaderboardUsers = [];
        _currentPage = 1;
        _hasError = false;
        _errorMessage = '';
      }
    });

    try {
      final leaderboardResponse = await _gameService.getLeaderboard(
        _currentPage,
        _usersPerPage,
      );

      if (leaderboardResponse != null) {
        setState(() {
          if (refresh || _currentPage == 1) {
            _leaderboardUsers = leaderboardResponse.users;
          } else {
            _leaderboardUsers.addAll(leaderboardResponse.users);
          }
          _totalPages = leaderboardResponse.totalPages;
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load leaderboard data';
        });
      }
    } catch (e) {
      developer.log('Error in fetchLeaderboard: $e', name: 'LeaderboardScreen');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  Future<void> _fetchMoreUsers() async {
    if (_isLoading || _currentPage >= _totalPages) return;

    setState(() {
      _currentPage++;
      _isLoading = true;
    });

    await _fetchLeaderboard();
  }

  Future<void> _refreshLeaderboard() {
    return _fetchLeaderboard(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.backgroundColor1, AppTheme.backgroundColor2],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child:
                    _hasError
                        ? _buildErrorView()
                        : RefreshIndicator(
                          onRefresh: _refreshLeaderboard,
                          color: AppTheme.primaryColor,
                          child:
                              _leaderboardUsers.isEmpty && _isLoading
                                  ? _buildLoadingView()
                                  : _buildLeaderboardList(),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Animate(
        effects: [
          FadeEffect(duration: 600.ms),
          SlideEffect(
            begin: const Offset(0, -0.2),
            end: Offset.zero,
            duration: 600.ms,
          ),
        ],
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(40),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 24),
            Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 70,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _refreshLeaderboard(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text(
            'Loading leaderboard...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.primaryColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      itemCount:
          _leaderboardUsers.length + (_currentPage < _totalPages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _leaderboardUsers.length) {
          final user = _leaderboardUsers[index];
          final position = index + 1;
          final isCurrentUser =
              _currentUserId != null && user.name == _currentUserId;

          return Animate(
            effects: [
              FadeEffect(
                duration: 400.ms,
                delay: Duration(milliseconds: index * 50),
              ),
              SlideEffect(
                begin: const Offset(0.2, 0),
                end: Offset.zero,
                duration: 400.ms,
                delay: Duration(milliseconds: index * 50),
              ),
            ],
            child: _buildUserItem(user, position, isCurrentUser),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }
      },
    );
  }

  Widget _buildUserItem(
    LeaderboardUserModel user,
    int position,
    bool isCurrentUser,
  ) {
    final backgroundColor =
        isCurrentUser
            ? AppTheme.primaryColor.withOpacity(0.15)
            : Colors.white.withOpacity(position <= 3 ? 0.9 : 0.7);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isCurrentUser
                    ? AppTheme.primaryColor.withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (position <= 3)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getPositionColor(position),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPositionIcon(position),
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getPositionText(position),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _getPositionColor(position).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getPositionColor(position),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    position.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _getPositionColor(position),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.2),
                    image:
                        user.profilePicture != 'default-avatar.png'
                            ? DecorationImage(
                              image: NetworkImage(user.profilePicture),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      user.profilePicture == 'default-avatar.png'
                          ? Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey.withOpacity(0.7),
                          )
                          : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color:
                              isCurrentUser
                                  ? AppTheme.primaryColor
                                  : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user.city}, ${user.state}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getPositionColor(position).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: _getPositionColor(position),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.points.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _getPositionColor(position),
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
    );
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getPositionIcon(int position) {
    switch (position) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.emoji_events;
      case 3:
        return Icons.emoji_events;
      default:
        return Icons.star;
    }
  }

  String _getPositionText(int position) {
    switch (position) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      default:
        return '${position}th';
    }
  }
}
