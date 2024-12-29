import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_champ/flutter_flow/flutter_flow_theme.dart';
import 'package:task_champ/flutter_flow/flutter_flow_widgets.dart';
import 'package:task_champ/controllers/login_sign_up_controller.dart';
import 'package:task_champ/controllers/health_data_controller.dart';

class ProfilePageWidget extends StatelessWidget {
  const ProfilePageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LoginSignUpController loginController =
        Get.find<LoginSignUpController>();
    final HealthDataController healthController =
        Get.find<HealthDataController>();

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
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
                fontFamily: 'Outfit',
                color: FlutterFlowTheme.of(context).primaryText,
              ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).primary,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 80,
                ),
              ),

              // User Email
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                child: Text(
                  loginController.emailController.text,
                  style: FlutterFlowTheme.of(context).titleLarge,
                ),
              ),

              // Health Metrics Section
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Health Overview',
                          style: FlutterFlowTheme.of(context).titleMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildHealthMetricRow(
                          context,
                          'Steps Today',
                          healthController.steps.value.toString(),
                          Icons.directions_walk,
                        ),
                        _buildHealthMetricRow(
                          context,
                          'Weight',
                          '${healthController.weight.value.toStringAsFixed(1)} kg',
                          Icons.monitor_weight,
                        ),
                        _buildHealthMetricRow(
                          context,
                          'Height',
                          '${healthController.height.value.toStringAsFixed(1)} cm',
                          Icons.height,
                        ),
                      ],
                    ),
                  ),
                ),
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
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Outfit',
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
    );
  }

  Widget _buildHealthMetricRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                icon,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 24,
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                child: Text(
                  label,
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
