import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/permission_service.dart';
import '../config/theme.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final permissionService = Provider.of<PermissionService>(context);

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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo or icon
                Icon(
                  Icons.eco_outlined,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Plastrack',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                const Text(
                  'To use all features of this app, we need permission to access your camera and location.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Permission status
                PermissionStatusCard(
                  icon: Icons.camera_alt,
                  title: 'Camera',
                  isGranted: permissionService.cameraPermissionGranted,
                  onRequestPermission: () async {
                    await Permission.camera.request();
                    permissionService.checkPermissions();
                  },
                ),

                const SizedBox(height: 16),

                PermissionStatusCard(
                  icon: Icons.location_on,
                  title: 'Location',
                  isGranted: permissionService.locationPermissionGranted,
                  onRequestPermission: () async {
                    await Permission.location.request();
                    permissionService.checkPermissions();
                  },
                ),

                const SizedBox(height: 48),

                // Continue button
                ElevatedButton(
                  onPressed:
                      permissionService.allPermissionsGranted
                          ? () {
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                          : () async {
                            await permissionService.requestPermissions();
                            if (permissionService.allPermissionsGranted) {
                              Navigator.pushReplacementNamed(context, '/home');
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    permissionService.allPermissionsGranted
                        ? 'Continue'
                        : 'Grant Permissions',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                // if (!permissionService.allPermissionsGranted) ...[
                //   const SizedBox(height: 16),
                //   TextButton(
                //     onPressed: () {
                //       Navigator.pushReplacementNamed(context, '/home');
                //     },
                //     child: const Text('Continue with Limited Features'),
                //   ),
                // ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PermissionStatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isGranted;
  final VoidCallback onRequestPermission;

  const PermissionStatusCard({
    super.key,
    required this.icon,
    required this.title,
    required this.isGranted,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: isGranted ? Colors.green : Colors.grey, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  isGranted ? 'Permission granted' : 'Permission required',
                  style: TextStyle(
                    color: isGranted ? Colors.green : Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (!isGranted)
            TextButton(
              onPressed: onRequestPermission,
              child: const Text('Grant'),
            ),
        ],
      ),
    );
  }
}
