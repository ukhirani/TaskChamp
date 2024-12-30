import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_champ/flutter_flow/flutter_flow_theme.dart';
import 'package:task_champ/flutter_flow/flutter_flow_widgets.dart';
import 'package:task_champ/controllers/login_sign_up_controller.dart';
import 'package:task_champ/controllers/health_data_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  void initState() {
    super.initState();
    // Fetch health data when the page initializes
    healthController.fetchHealthData();
  }

  @override
  Widget build(BuildContext context) {
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
        // Removed edit button
      ),
      body: RefreshIndicator(
        onRefresh: () => healthController.fetchHealthData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture without Gradient
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          FlutterFlowTheme.of(context).primary.withOpacity(0.5),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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

                // Logout Button
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                  child: FFButtonWidget(
                    onPressed: () => loginController.logout(),
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
                      borderRadius: BorderRadius.circular(12),
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
