import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:share_plus/share_plus.dart';
import '../services/auth_service.dart';
import '../config/theme.dart';
import 'dart:async';
import 'dart:developer' as developer;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Location _locationService = Location();
  LocationData? _currentLocation;
  bool _isLoadingLocation = true;

  // Sample leaderboard data - in a real app, this would come from a service
  final List<Map<String, dynamic>> _leaderboardData = [
    {'name': 'User1', 'points': 120, 'rank': 1},
    {'name': 'User2', 'points': 105, 'rank': 2},
    {'name': 'User3', 'points': 95, 'rank': 3},
    {'name': 'User4', 'points': 80, 'rank': 4},
    {'name': 'User5', 'points': 75, 'rank': 5},
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        return;
      }
    }

    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() => _isLoadingLocation = false);
        return;
      }
    }

    final locationData = await _locationService.getLocation();
    if (mounted) {
      setState(() {
        _currentLocation = locationData;
        _isLoadingLocation = false;
      });
    }
  }

  void _shareLocation() {
    if (_currentLocation != null) {
      final lat = _currentLocation!.latitude;
      final lng = _currentLocation!.longitude;
      Share.share(
        'Check out my location on Waste2Ways! https://maps.google.com/?q=$lat,$lng',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not available for sharing')),
      );
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
        child:
            user == null
                ? _buildNotLoggedInView(context)
                : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/profile');
                              },
                              child: CircleAvatar(
                                backgroundColor: AppTheme.primaryColor
                                    .withOpacity(0.2),
                                child: Icon(
                                  Icons.person,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.logout, color: Colors.black54),
                              onPressed: () async {
                                await authService.logout();
                                // ignore: use_build_context_synchronously
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20.0),

                        // Welcome message
                        Center(
                          child: ShaderMask(
                            shaderCallback:
                                (bounds) => LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor,
                                    AppTheme.secondaryColor,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                            child: Text(
                              'Welcome, ${user.name}!',
                              style: TextStyle(
                                fontSize: 26.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20.0),

                        // Map section with share button
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  top: 12.0,
                                  right: 16.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Your Location',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.share,
                                        color: AppTheme.primaryColor,
                                      ),
                                      onPressed: _shareLocation,
                                      tooltip: 'Share your location',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 180,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  child:
                                      _isLoadingLocation
                                          ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                          : _currentLocation == null
                                          ? Center(
                                            child: Text('Location unavailable'),
                                          )
                                          : GoogleMap(
                                            mapType: MapType.normal,
                                            initialCameraPosition:
                                                CameraPosition(
                                                  target: LatLng(
                                                    _currentLocation!.latitude!,
                                                    _currentLocation!
                                                        .longitude!,
                                                  ),
                                                  zoom: 15.0,
                                                ),
                                            myLocationEnabled: true,
                                            myLocationButtonEnabled: false,
                                            zoomControlsEnabled: false,
                                            onMapCreated: (
                                              GoogleMapController controller,
                                            ) {
                                              _controller.complete(controller);
                                            },
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20.0),

                        // Leaderboard section
                        Expanded(
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.emoji_events,
                                        color: Colors.amber,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Leaderboard',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 1),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _leaderboardData.length,
                                    itemBuilder: (context, index) {
                                      final user = _leaderboardData[index];
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: _getLeaderColor(
                                            user['rank'],
                                          ),
                                          child: Text(
                                            '${user['rank']}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(user['name']),
                                        trailing: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            '${user['points']} pts',
                                            style: TextStyle(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Color _getLeaderColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey.shade400; // Silver
      case 3:
        return Colors.brown.shade300; // Bronze
      default:
        return Colors.blue.shade300;
    }
  }

  Widget _buildNotLoggedInView(BuildContext context) {
    return SafeArea(
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
