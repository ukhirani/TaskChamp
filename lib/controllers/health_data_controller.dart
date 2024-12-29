import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthDataController extends GetxController {
  // Health data tracking
  final Health _health = Health();
  
  // Observables for different health metrics
  final RxInt steps = 0.obs;
  final RxDouble weight = 0.0.obs;
  final RxDouble height = 0.0.obs;
  final RxDouble activeEnergyBurned = 0.0.obs;

  // List of health data types to request
  List<HealthDataType> get types => [
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  // Permissions for each type
  List<HealthDataAccess> get permissions => types
      .map((type) => 
        // Some types might only allow READ permissions
        [
          HealthDataType.WALKING_HEART_RATE,
          HealthDataType.EXERCISE_TIME,
        ].contains(type)
          ? HealthDataAccess.READ
          : HealthDataAccess.READ_WRITE)
      .toList();

  @override
  void onInit() {
    super.onInit();
    _initHealthTracking();
  }

  Future<void> _initHealthTracking() async {
    try {
      // Configure the health plugin
      _health.configure();

      // Request necessary permissions
      await _requestPermissions();

      // Fetch initial health data
      await fetchHealthData();
    } catch (e) {
      debugPrint('Error initializing health tracking: $e');
    }
  }

  Future<void> _requestPermissions() async {
    // Request activity recognition permission
    await Permission.activityRecognition.request();
    
    // Request location permission (sometimes needed for workouts)
    await Permission.location.request();

    // Request health data authorization
    bool authorized = await _health.requestAuthorization(types, permissions: permissions);

    if (!authorized) {
      debugPrint('Health data authorization denied');
    }
  }

  Future<void> fetchHealthData() async {
    if (types.isEmpty) return;

    try {
      // Get data for today
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // Fetch steps
      int? totalSteps = await _health.getTotalStepsInInterval(midnight, now);
      steps.value = totalSteps ?? 0;

      // Fetch other health data
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: types,
        startTime: midnight,
        endTime: now,
      );

      // Process and update health metrics
      for (var dataPoint in healthData) {
        switch (dataPoint.type) {
          case HealthDataType.WEIGHT:
            if (dataPoint.value is NumericHealthValue) {
              weight.value = (dataPoint.value as NumericHealthValue).numericValue.toDouble();
            }
            break;
          case HealthDataType.HEIGHT:
            if (dataPoint.value is NumericHealthValue) {
              height.value = (dataPoint.value as NumericHealthValue).numericValue.toDouble();
            }
            break;
          case HealthDataType.ACTIVE_ENERGY_BURNED:
            if (dataPoint.value is NumericHealthValue) {
              activeEnergyBurned.value = (dataPoint.value as NumericHealthValue).numericValue.toDouble();
            }
            break;
          default:
            break;
        }
      }
    } catch (e) {
      debugPrint('Error fetching health data: $e');
    }
  }

  // Method to add health data
  Future<bool> addHealthData({
    double? weight,
    double? height,
    double? activeEnergyBurned,
  }) async {
    bool success = true;
    final now = DateTime.now();

    try {
      if (weight != null) {
        success &= await _health.writeHealthData(
          value: weight,
          type: HealthDataType.WEIGHT,
          startTime: now,
          recordingMethod: RecordingMethod.manual,
        );
      }

      if (height != null) {
        success &= await _health.writeHealthData(
          value: height,
          type: HealthDataType.HEIGHT,
          startTime: now,
          endTime: now,
          recordingMethod: RecordingMethod.manual,
        );
      }

      if (activeEnergyBurned != null) {
        success &= await _health.writeHealthData(
          value: activeEnergyBurned,
          type: HealthDataType.ACTIVE_ENERGY_BURNED,
          startTime: now,
          endTime: now,
        );
      }
    } catch (e) {
      debugPrint('Error adding health data: $e');
      success = false;
    }

    // Refresh data after adding
    if (success) {
      await fetchHealthData();
    }

    return success;
  }

  // Method to delete health data
  Future<bool> deleteHealthData() async {
    bool success = true;
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    try {
      for (var type in types) {
        success &= await _health.delete(
          type: type,
          startTime: yesterday,
          endTime: now,
        );
      }
    } catch (e) {
      debugPrint('Error deleting health data: $e');
      success = false;
    }

    // Refresh data after deletion
    if (success) {
      await fetchHealthData();
    }

    return success;
  }

  // Specific method to get steps
  Future<int> getStepCount() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    try {
      int? totalSteps = await _health.getTotalStepsInInterval(midnight, now);
      return totalSteps ?? 0;
    } catch (e) {
      debugPrint('Error getting step count: $e');
      return 0;
    }
  }
}
