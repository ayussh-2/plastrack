import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

class PermissionService with ChangeNotifier {
  bool _cameraPermissionGranted = false;
  bool _locationPermissionGranted = false;
  bool _permissionsChecked = false;

  bool get cameraPermissionGranted => _cameraPermissionGranted;
  bool get locationPermissionGranted => _locationPermissionGranted;
  bool get allPermissionsGranted =>
      _cameraPermissionGranted && _locationPermissionGranted;
  bool get permissionsChecked => _permissionsChecked;

  Future<void> checkPermissions() async {
    developer.log('Checking permissions', name: 'PermissionService');

    var cameraStatus = await Permission.camera.status;
    var locationStatus = await Permission.location.status;

    _cameraPermissionGranted = cameraStatus.isGranted;
    _locationPermissionGranted = locationStatus.isGranted;
    _permissionsChecked = true;

    notifyListeners();

    developer.log(
      'Camera permission: $_cameraPermissionGranted',
      name: 'PermissionService',
    );
    developer.log(
      'Location permission: $_locationPermissionGranted',
      name: 'PermissionService',
    );
  }

  Future<void> requestPermissions() async {
    developer.log('Requesting permissions', name: 'PermissionService');

    var cameraStatus = await Permission.camera.request();
    var locationStatus = await Permission.location.request();

    _cameraPermissionGranted = cameraStatus.isGranted;
    _locationPermissionGranted = locationStatus.isGranted;
    _permissionsChecked = true;

    notifyListeners();

    developer.log(
      'Camera permission after request: $_cameraPermissionGranted',
      name: 'PermissionService',
    );
    developer.log(
      'Location permission after request: $_locationPermissionGranted',
      name: 'PermissionService',
    );
  }
}
