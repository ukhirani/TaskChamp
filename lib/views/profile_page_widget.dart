import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_champ/flutter_flow/flutter_flow_theme.dart';
import 'package:task_champ/flutter_flow/flutter_flow_widgets.dart';
import 'package:task_champ/controllers/login_sign_up_controller.dart';
import 'package:task_champ/controllers/health_data_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ProfilePageWidget extends StatefulWidget {
  const ProfilePageWidget({Key? key}) : super(key: key);

  @override
  _ProfilePageWidgetState createState() => _ProfilePageWidgetState();
}

class _ProfilePageWidgetState extends State<ProfilePageWidget> {
  final LoginSignUpController loginController =
      Get.find<LoginSignUpController>();
  final HealthDataController healthController =
      Get.find<HealthDataController>();

  // New variables for location
  String _address = "Fetching location...";
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    // Fetch health data when the page initializes
    healthController.fetchHealthData();

    // Fetch user location
    _fetchUserLocation();

    // Debug print to track initial state
    print('🔍 Initial _address value: $_address');
    print('🔍 Initial _isLoadingLocation value: $_isLoadingLocation');
  }

  Future<void> _fetchUserLocation() async {
    try {
      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _address = "Location permissions denied";
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Use Geoapify API for reverse geocoding
      final apiKey = "2c5da0c9d8b04db9945c9f1d519062cf";
      final url =
          "https://api.geoapify.com/v1/geocode/reverse?lat=${position.latitude}&lon=${position.longitude}&type=street&apiKey=$apiKey";

      print('🌐 Geoapify URL: $url');

      final response = await http.get(Uri.parse(url));
      print('🌐 Response status code: ${response.statusCode}');
      print('🌐 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🗺️ Geocoding response type: ${data.runtimeType}');
        print('🗺️ Geocoding response keys: ${data.keys}');
        print('🗺️ Geocoding response: $data');

        // Detailed error checking
        if (data is Map && data.containsKey('features')) {
          final features = data['features'];
          print('🗺️ Features type: ${features.runtimeType}');
          print('🗺️ Features length: ${features.length}');

          if (features is List && features.isNotEmpty) {
            final firstFeature = features[0];
            print('🗺️ First feature type: ${firstFeature.runtimeType}');
            print('🗺️ First feature keys: ${firstFeature.keys}');

            if (firstFeature is Map && firstFeature.containsKey('properties')) {
              final properties = firstFeature['properties'];
              final address = properties['formatted'] ?? 'No formatted address';

              print('📍 Address properties: $properties');
              print('📍 Formatted Address: $address');

              setState(() {
                _address = address;
                _isLoadingLocation = false;
              });
            } else {
              print('🚫 Unexpected first feature format');
              setState(() {
                _address =
                    "Coordinates: ${position.latitude}, ${position.longitude}";
                _isLoadingLocation = false;
              });
            }
          } else {
            print('🚫 No features in geocoding response');
            setState(() {
              _address =
                  "Coordinates: ${position.latitude}, ${position.longitude}";
              _isLoadingLocation = false;
            });
          }
        } else {
          print('🚫 Unexpected response format');
          setState(() {
            _address =
                "Coordinates: ${position.latitude}, ${position.longitude}";
            _isLoadingLocation = false;
          });
        }
      } else {
        print('🚫 Failed to fetch address from Geoapify');
        setState(() {
          _address = "Coordinates: ${position.latitude}, ${position.longitude}";
          _isLoadingLocation = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error fetching location: $e');
      print('Stacktrace: $stackTrace');
      setState(() {
        _address = "Error fetching location: $e";
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug print to check _address value during build
    print('🖼️ Building profile page with _address: $_address');

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Profile',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Urbanist',
                color: FlutterFlowTheme.of(context).primaryText,
              ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => healthController.fetchHealthData(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture without Gradient
                Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: FlutterFlowTheme.of(context)
                            .primary
                            .withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: FlutterFlowTheme.of(context)
                              .primary
                              .withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.account_circle_rounded,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 100,
                      ),
                    ),
                  ),
                ),

                // User Email
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                  child: Text(
                    FirebaseAuth.instance.currentUser?.email ?? 'No email',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily: 'Urbanist',
                          color: FlutterFlowTheme.of(context).primaryText,
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Health Metrics Section with Obx for real-time updates
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                  child: Obx(() => Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16, 16, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Health Overview',
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              _buildHealthMetricRow(
                                context,
                                'Steps Today',
                                healthController.steps.value.toString(),
                                Icons.directions_walk,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                              _buildHealthMetricRow(
                                context,
                                'Weight',
                                '${healthController.weight.value.toStringAsFixed(1)} kg',
                                Icons.monitor_weight,
                                color: FlutterFlowTheme.of(context).secondary,
                              ),
                              _buildHealthMetricRow(
                                context,
                                'Height',
                                '${healthController.height.value.toStringAsFixed(1)} cm',
                                Icons.height,
                                color: FlutterFlowTheme.of(context).tertiary,
                              ),
                              _buildHealthMetricRow(
                                context,
                                'Active Energy Burned',
                                '${healthController.activeEnergyBurned.value.toStringAsFixed(1)} cal',
                                Icons.local_fire_department,
                                color: FlutterFlowTheme.of(context).error,
                              ),
                            ],
                          ),
                        ),
                      )),
                ),

                // Location Section with forced visibility
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.green,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Location',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                            Text(
                              _address,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Logout Button
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                  child: FFButtonWidget(
                    onPressed: () {
                      loginController.logout();
                    },
                    text: 'Logout',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 50,
                      color: FlutterFlowTheme.of(context).error,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Urbanist',
                                color: Colors.white,
                              ),
                      elevation: 3,
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
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

  Widget _buildHealthMetricRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color color = Colors.grey,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        icon,
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        size: 20,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                    child: Text(
                      label,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
              Text(
                value,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Profile',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            // Add edit profile functionality here
            SizedBox(height: 16),
            FFButtonWidget(
              onPressed: () {
                // Implement profile editing
                Navigator.pop(context);
              },
              text: 'Save Changes',
              options: FFButtonOptions(
                width: double.infinity,
                height: 50,
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'Urbanist',
                      color: Colors.white,
                    ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
