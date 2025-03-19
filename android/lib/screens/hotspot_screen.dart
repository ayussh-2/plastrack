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
  final Set<Circle> _filteredCircles = {};
  final Location _locationService = Location();
  LocationData? _currentLocation;

  List<Hotspot> _hotspots = [];
  bool _isLoading = true;
  String? _errorMessage;

  bool _showLowSeverity = true;
  bool _showMediumSeverity = true;
  bool _showHighSeverity = true;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(22.2587, 84.9034),
    zoom: 18.0,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _getCurrentLocation();
      final hotspots = await _hotspotService.getHotspots();

      if (mounted) {
        setState(() {
          _hotspots = hotspots;
          _isLoading = false;
        });

        _updateCircles();
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

    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

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
          final baseRadius = 2.0;
          final severityMultiplier = hotspot.avgSeverity;
          final countFactor = _getCountFactor(hotspot.reportCount);
          final radius = baseRadius * severityMultiplier * countFactor;

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
      _applyFilters();
    });
  }

  void _applyFilters() {
    final filtered =
        _circles.where((circle) {
          final circleId = circle.circleId.value;
          final parts = circleId.split('_');
          if (parts.length < 3) return false;

          final hotspot = _hotspots.firstWhere(
            (h) => 'hotspot_${h.latGroup}_${h.lngGroup}' == circleId,
            orElse:
                () => Hotspot(
                  latGroup: 0,
                  lngGroup: 0,
                  avgSeverity: 0,
                  reportCount: 0,
                  reports: [],
                ),
          );

          if (hotspot.avgSeverity <= 0) return false;

          if (hotspot.avgSeverity <= 2 && !_showLowSeverity) return false;
          if (hotspot.avgSeverity > 2 &&
              hotspot.avgSeverity <= 3.5 &&
              !_showMediumSeverity)
            return false;
          if (hotspot.avgSeverity > 3.5 && !_showHighSeverity) return false;

          return true;
        }).toSet();

    setState(() {
      _filteredCircles.clear();
      _filteredCircles.addAll(filtered);
    });
  }

  double _getCountFactor(int reportCount) {
    if (reportCount <= 1) return 0.8;
    if (reportCount <= 3) return 0.9;
    if (reportCount <= 5) return 1.0;
    if (reportCount <= 10) return 1.1;
    return 1.2;
  }

  Color _getSeverityColor(double severity) {
    if (severity <= 1) return Colors.green;
    if (severity <= 2) return Colors.lightGreen;
    if (severity <= 3) return Colors.yellow;
    if (severity <= 4) return Colors.orange;
    return Colors.red;
  }

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

  Future<void> _moveToOptimalPosition() async {
    if (_controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;

      if (_hotspots.isEmpty && _currentLocation == null) return;

      if (_hotspots.isEmpty && _currentLocation != null) {
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            18.0,
          ),
        );
        return;
      }

      double minLat = 90.0, maxLat = -90.0, minLng = 180.0, maxLng = -180.0;

      for (final hotspot in _hotspots) {
        minLat = hotspot.latGroup < minLat ? hotspot.latGroup : minLat;
        maxLat = hotspot.latGroup > maxLat ? hotspot.latGroup : maxLat;
        minLng = hotspot.lngGroup < minLng ? hotspot.lngGroup : minLng;
        maxLng = hotspot.lngGroup > maxLng ? hotspot.lngGroup : maxLng;
      }

      if (_currentLocation != null) {
        final userLat = _currentLocation!.latitude!;
        final userLng = _currentLocation!.longitude!;
        minLat = userLat < minLat ? userLat : minLat;
        maxLat = userLat > maxLat ? userLat : maxLat;
        minLng = userLng < minLng ? userLng : minLng;
        maxLng = userLng > maxLng ? userLng : maxLng;
      }

      final centerLat = (minLat + maxLat) / 2;
      final centerLng = (minLng + maxLng) / 2;

      await Future.delayed(const Duration(milliseconds: 300));

      if (_currentLocation != null) {
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            18.0,
          ),
        );
        return;
      }

      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(centerLat, centerLng), 18.0),
      );

      if (_hotspots.length > 1) {
        try {
          await controller.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(minLat, minLng),
                northeast: LatLng(maxLat, maxLng),
              ),
              70.0,
            ),
          );

          final zoomLevel = await controller.getZoomLevel();
          if (zoomLevel < 18.0) {
            await controller.animateCamera(CameraUpdate.zoomTo(18.0));
          }
        } catch (e) {
          await controller.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(centerLat, centerLng), 18.0),
          );
        }
      }
    }
  }

  Future<void> _centerOnUserLocation() async {
    if (_currentLocation != null && _controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          18.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    circles:
                        _filteredCircles.isEmpty ? _circles : _filteredCircles,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    compassEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      Future.delayed(const Duration(milliseconds: 500), () {
                        _moveToOptimalPosition();
                      });
                    },
                  ),

                  if (_currentLocation != null && !_isLoading)
                    Positioned(
                      right: 16,
                      bottom: 170,
                      child: FloatingActionButton(
                        onPressed: _centerOnUserLocation,
                        heroTag: 'centerLocation',
                        child: const Icon(Icons.my_location),
                        tooltip: 'Center on my location',
                      ),
                    ),

                  if (_hotspots.isNotEmpty)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      left: 8.0,
                                      bottom: 4.0,
                                    ),
                                    child: Text(
                                      'Filter by Severity:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _filterButton(
                                        'Low',
                                        Colors.green,
                                        _showLowSeverity,
                                        (value) {
                                          setState(() {
                                            _showLowSeverity = value!;
                                            _applyFilters();
                                          });
                                        },
                                      ),
                                      _filterButton(
                                        'Medium',
                                        Colors.yellow,
                                        _showMediumSeverity,
                                        (value) {
                                          setState(() {
                                            _showMediumSeverity = value!;
                                            _applyFilters();
                                          });
                                        },
                                      ),
                                      _filterButton(
                                        'High',
                                        Colors.red,
                                        _showHighSeverity,
                                        (value) {
                                          setState(() {
                                            _showHighSeverity = value!;
                                            _applyFilters();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _legendItem(Colors.green, 'Low Severity'),
                                  _legendItem(Colors.yellow, 'Medium'),
                                  _legendItem(Colors.red, 'High Severity'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _filterButton(
    String label,
    Color color,
    bool isSelected,
    Function(bool?) onChanged,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: Colors.black87,
      onSelected: onChanged,
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
