import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:waste2ways/models/hotspot_model.dart';
import 'package:waste2ways/services/hotspot_service.dart';
import 'package:intl/intl.dart';

class HotspotScreen extends StatefulWidget {
  const HotspotScreen({Key? key}) : super(key: key);

  @override
  State<HotspotScreen> createState() => _HotspotScreenState();
}

class _HotspotScreenState extends State<HotspotScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final HotspotService _hotspotService = HotspotService();

  final Set<Circle> _circles = {};
  final Location _locationService = Location();
  LocationData? _currentLocation;

  List<Hotspot> _hotspots = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Initial camera position (will be updated with user location)
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(22.2587, 84.9034), // Default position (can be changed)
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Get user's current location
      await _getCurrentLocation();

      // Fetch hotspots from the backend
      final hotspots = await _hotspotService.getHotspots();

      if (mounted) {
        setState(() {
          _hotspots = hotspots;
          _isLoading = false;
          _updateCircles();
        });

        // Determine best camera position
        _moveToOptimalPosition();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check if permission is granted
    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Get location
    final locationData = await _locationService.getLocation();
    if (mounted) {
      setState(() {
        _currentLocation = locationData;
      });
    }
  }

  void _updateCircles() {
    final circles =
        _hotspots.map((hotspot) {
          // Calculate circle radius based on severity and report count
          // Radius in meters, scaled by severity (1-5) and reportCount
          final baseRadius = 100.0; // Base radius in meters
          final severityMultiplier = hotspot.avgSeverity; // 1-5
          final countFactor = _getCountFactor(hotspot.reportCount);
          final radius = baseRadius * severityMultiplier * countFactor;

          // Color based on severity
          final color = _getSeverityColor(hotspot.avgSeverity);

          return Circle(
            circleId: CircleId(
              'hotspot_${hotspot.latGroup}_${hotspot.lngGroup}',
            ),
            center: LatLng(hotspot.latGroup, hotspot.lngGroup),
            radius: radius,
            fillColor: color.withOpacity(0.5),
            strokeColor: color,
            strokeWidth: 2,
            onTap: () => _showHotspotInfo(hotspot),
          );
        }).toSet();

    setState(() {
      _circles.clear();
      _circles.addAll(circles);
    });
  }

  // Get a scaling factor based on report count
  double _getCountFactor(int reportCount) {
    if (reportCount <= 1) return 0.8;
    if (reportCount <= 3) return 1.0;
    if (reportCount <= 5) return 1.2;
    if (reportCount <= 10) return 1.4;
    return 1.6; // For very large clusters
  }

  // Get color based on severity
  Color _getSeverityColor(double severity) {
    if (severity <= 1) return Colors.green;
    if (severity <= 2) return Colors.lightGreen;
    if (severity <= 3) return Colors.yellow;
    if (severity <= 4) return Colors.orange;
    return Colors.red;
  }

  // Show info when a hotspot is tapped
  void _showHotspotInfo(Hotspot hotspot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            expand: false,
            builder:
                (_, scrollController) => SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trash Hotspot',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Location: ${hotspot.latGroup.toStringAsFixed(4)}, ${hotspot.lngGroup.toStringAsFixed(4)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Average Severity: ${hotspot.avgSeverity.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Report Count: ${hotspot.reportCount}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Reports:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...hotspot.reports
                            .map(
                              (report) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Type: ${report.trashType}',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                      Text(
                                        'Severity: ${report.severity}',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                      Text(
                                        'Date: ${DateFormat('MMM dd, yyyy HH:mm').format(report.timestamp)}',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  // Find the optimal camera position to show both user location and hotspots
  Future<void> _moveToOptimalPosition() async {
    if (_controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;

      // If no hotspots or no current location, just return
      if (_hotspots.isEmpty && _currentLocation == null) return;

      // If we have the user location but no hotspots, center on user
      if (_hotspots.isEmpty && _currentLocation != null) {
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            14.0,
          ),
        );
        return;
      }

      // Calculate bounds that include all hotspots and user location
      double minLat = 90.0, maxLat = -90.0, minLng = 180.0, maxLng = -180.0;

      // Include hotspots in bounds
      for (final hotspot in _hotspots) {
        minLat = hotspot.latGroup < minLat ? hotspot.latGroup : minLat;
        maxLat = hotspot.latGroup > maxLat ? hotspot.latGroup : maxLat;
        minLng = hotspot.lngGroup < minLng ? hotspot.lngGroup : minLng;
        maxLng = hotspot.lngGroup > maxLng ? hotspot.lngGroup : maxLng;
      }

      // Include user location in bounds if available
      if (_currentLocation != null) {
        final userLat = _currentLocation!.latitude!;
        final userLng = _currentLocation!.longitude!;
        minLat = userLat < minLat ? userLat : minLat;
        maxLat = userLat > maxLat ? userLat : maxLat;
        minLng = userLng < minLng ? userLng : minLng;
        maxLng = userLng > maxLng ? userLng : maxLng;
      }

      // Add padding to bounds
      final latPadding = (maxLat - minLat) * 0.2;
      final lngPadding = (maxLng - minLng) * 0.2;

      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat - latPadding, minLng - lngPadding),
            northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
          ),
          50.0, // padding in pixels
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash Hotspots'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _loadData();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading hotspots',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
              : Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _initialCameraPosition,
                    circles: _circles,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      // Once map is created, position it optimally
                      _moveToOptimalPosition();
                    },
                  ),
                  if (_hotspots.isNotEmpty)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _legendItem(Colors.green, 'Low Severity'),
                              _legendItem(Colors.yellow, 'Medium'),
                              _legendItem(Colors.red, 'High Severity'),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            border: Border.all(color: color, width: 1),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
