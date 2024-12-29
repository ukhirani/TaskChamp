import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthDataController extends GetxController {
  // Health data tracking
  final Health _health = Health();

  // Platform channel for Health Connect
  static const _healthConnectChannel =
      MethodChannel('com.taskchamp.health_connect');

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
    try {
      // Request activity recognition permission
      await Permission.activityRecognition.request();

      // Request location permission (sometimes needed for workouts)
      await Permission.location.request();

      // Request health data authorization
      bool authorized =
          await _health.requestAuthorization(types, permissions: permissions);

      if (!authorized) {
        debugPrint('Health data authorization denied');
      }

      // Additional Android-specific Health Connect permissions
      if (Platform.isAndroid) {
        await _requestHealthConnectPermissions();
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
  }

  Future<void> _requestHealthConnectPermissions() async {
    try {
      // Check Health Connect availability first
      final isAvailable = await checkHealthConnectAvailability();
      debugPrint('Health Connect Available: $isAvailable');

      if (!isAvailable) {
        debugPrint('Health Connect is not available on this device');
        return;
      }

      // Request Health Connect permissions via platform channel
      final result =
          await _healthConnectChannel.invokeMethod('requestPermissions');
      debugPrint('Health Connect Permissions Result: $result');
    } catch (e) {
      debugPrint('Error requesting Health Connect permissions: $e');
    }
  }

  // Check Health Connect availability
  Future<bool> checkHealthConnectAvailability() async {
    try {
      if (!Platform.isAndroid) return false;

      final result = await _healthConnectChannel
          .invokeMethod<bool>('checkHealthConnectAvailability');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking Health Connect availability: $e');
      return false;
    }
  }

  Future<void> fetchHealthData() async {
    if (types.isEmpty) return;

    try {
      // Get data for today
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // Fetch steps from device
      int? deviceSteps = await _fetchDeviceSteps(midnight, now);
      debugPrint('Total Steps Fetched: $deviceSteps');
      steps.value = deviceSteps ?? 0;

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
              weight.value = (dataPoint.value as NumericHealthValue)
                  .numericValue
                  .toDouble();
            }
            break;
          case HealthDataType.HEIGHT:
            if (dataPoint.value is NumericHealthValue) {
              height.value = (dataPoint.value as NumericHealthValue)
                  .numericValue
                  .toDouble();
            }
            break;
          case HealthDataType.ACTIVE_ENERGY_BURNED:
            if (dataPoint.value is NumericHealthValue) {
              activeEnergyBurned.value = (dataPoint.value as NumericHealthValue)
                  .numericValue
                  .toDouble();
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

  // Fetch device steps with platform-specific fallback
  Future<int?> _fetchDeviceSteps(DateTime startTime, DateTime endTime) async {
    try {
      // First, try to get steps from health package
      int? healthPackageSteps =
          await _health.getTotalStepsInInterval(startTime, endTime);
      debugPrint('Health Package Steps: $healthPackageSteps');

      if (healthPackageSteps != null && healthPackageSteps > 0) {
        return healthPackageSteps;
      }

      // Platform-specific step tracking
      if (Platform.isAndroid) {
        return await _getAndroidSteps(startTime, endTime);
      } else if (Platform.isIOS) {
        return await _getiOSSteps(startTime, endTime);
      }

      return 0;
    } catch (e) {
      debugPrint('Error fetching device steps: $e');
      return 0;
    }
  }

  // Android-specific step tracking via platform channel
  Future<int> _getAndroidSteps(DateTime startTime, DateTime endTime) async {
    try {
      // Invoke platform channel method to get steps
      final steps = await _healthConnectChannel.invokeMethod<int>('getSteps', {
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime.millisecondsSinceEpoch,
      });

      debugPrint('Android Platform Channel Steps: $steps');
      return steps ?? 0;
    } catch (e) {
      debugPrint('Error getting Android steps via platform channel: $e');
      return 0;
    }
  }

  // iOS-specific step tracking (placeholder)
  Future<int> _getiOSSteps(DateTime startTime, DateTime endTime) async {
    try {
      // TODO: Implement iOS step tracking
      debugPrint('Fetching iOS steps');
      return 0;
    } catch (e) {
      debugPrint('Error getting iOS steps: $e');
      return 0;
    }
  }

  // Method to manually refresh health data
  Future<void> refreshHealthData() async {
    await fetchHealthData();
  }
}

class HealthConnectDataController {
  static const MethodChannel _channel = MethodChannel('com.taskchamp.health_connect');

  Future<bool> checkHealthConnectAvailability() async {
    try {
      final bool isAvailable = await _channel.invokeMethod('checkHealthConnectAvailability');
      print('Health Connect Availability: $isAvailable');
      return isAvailable;
    } on PlatformException catch (e) {
      print('Error checking Health Connect availability');
      print(e);
      return false;
    }
  }

  Future<bool> requestHealthConnectPermissions() async {
    try {
      final bool permissionsGranted = await _channel.invokeMethod('requestPermissions');
      print('Health Connect Permissions Requested: $permissionsGranted');
      return permissionsGranted;
    } on PlatformException catch (e) {
      print('Error requesting Health Connect permissions');
      print(e);
      return false;
    }
  }

  Future<int> getSteps({
    required DateTime startTime, 
    required DateTime endTime
  }) async {
    try {
      final int steps = await _channel.invokeMethod('getSteps', {
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime.millisecondsSinceEpoch,
      });
      
      print('Steps fetched: $steps');
      
      return steps;
    } on PlatformException catch (e) {
      print('Error fetching steps');
      print(e);
      return 0;
    }
  }
}
