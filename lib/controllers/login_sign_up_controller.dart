import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_champ/components/navbar_widget.dart';
import 'package:task_champ/controllers/health_data_controller.dart';
import 'package:task_champ/flutter_flow/flutter_flow_util.dart';
import 'package:task_champ/views/login_sign_up_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:task_champ/flutter_flow/nav/nav.dart';
import 'package:task_champ/main.dart';

class LoginSignUpController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var isLoading = false.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Health data tracking
  HealthDataController get healthDataController =>
      Get.find<HealthDataController>();

  // Example method to use health data
  Future<void> logHealthMetrics() async {
    // Fetch health data
    await healthDataController.fetchHealthData();

    // Access health metrics
    print('Steps today: ${healthDataController.steps.value}');
    print('Weight: ${healthDataController.weight.value}');
    print('Height: ${healthDataController.height.value}');
    print(
        'Active Energy Burned: ${healthDataController.activeEnergyBurned.value}');
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm Password is required';
    } else if (value != password.value) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> signupUser() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    isLoading.value = true;

    try {
      // Request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
              'Permissions Required', 'Location access is needed to continue');
          isLoading.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Permissions Blocked',
            'Please enable location permissions in app settings');
        isLoading.value = false;
        return;
      }

      // Create user in Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // Get current location
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10));
      } catch (locationError) {
        print('Location retrieval error: $locationError');
        // Continue signup even if location can't be retrieved
        position = null;
      }

      // Prepare user data
      Map<String, dynamic> userData = {
        'UID': uid,
        'date_joined': FieldValue.serverTimestamp(),
        'name': 'Umang', // Consider adding a name input during signup
        'permissions': {
          'location': position != null,
          'notifications': false, // Add more permissions as needed
        }
      };

      // Add location if available
      if (position != null) {
        userData['location'] = GeoPoint(position.latitude, position.longitude);
      }

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);

      // Send verification email
      await sendMail(userCredential.user!.email!);

      Get.snackbar('Success', 'Signup Successful. Please verify your email.');
    } on FirebaseAuthException catch (authError) {
      // More specific error handling for authentication
      handleAuthError(authError.code);
    } catch (e) {
      Get.snackbar('Error', 'Signup failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMail(String toEmail) async {
    final subject = 'Account Creation Acknowledgement';
    final body = 'Dear $toEmail,\n\n'
        'Thank you for creating an account with us. We are excited to have you on board.\n\n'
        'Best regards,\n'
        'Your App Name';

    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      Get.snackbar('Success', 'Acknowledgement email sent successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send acknowledgement email');
    }
  }

  Future<void> login() async {
    if (email.value.trim().isEmpty || password.value.trim().isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.value.trim(),
        password: password.value.trim(),
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.reload();
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          Get.snackbar(
            'Info',
            'Please verify your email first.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
          return;
        }
      }

      // Set the login status to true in shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      Get.snackbar(
        'Success',
        'Login successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAll(() => NavBarPage(initialPage: 'HomePage'));
    } on FirebaseAuthException catch (e) {
      handleAuthError(e.code);
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void handleAuthError(String code) {
    String errorMessage;
    switch (code) {
      case 'invalid-email':
        errorMessage = 'The email address is not valid.';
        break;
      case 'user-not-found':
        errorMessage = 'No user found for that email.';
        break;
      case 'wrong-password':
        errorMessage = 'Incorrect password.';
        break;
      case 'user-disabled':
        errorMessage = 'This user account has been disabled.';
        break;
      case 'too-many-requests':
        errorMessage = 'Too many requests. Please try again later.';
        break;
      case 'operation-not-allowed':
        errorMessage = 'Email/password accounts are not enabled.';
        break;
      default:
        errorMessage = 'Login failed. Please try again.';
    }

    Get.snackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Get.offAll(() => const MyApp(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut);
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
