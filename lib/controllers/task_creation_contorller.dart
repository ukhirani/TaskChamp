export '../models/task_creation_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../components/navbar_widget.dart';

class TaskController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initFirebase() async {
    try {
      await Firebase.initializeApp();
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }

  void addTask({
    required String title,
    required String description,
    required String? tags,
    required DateTime? dueDate,
    required bool isCompleted,
    required bool isRoutine,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userId = user.uid;
        final tasksCollection = _firestore.collection('tasks').doc(userId);
        final date = dueDate?.toIso8601String().split('T')[0] ??
            DateTime.now().toIso8601String().split('T')[0];

        await tasksCollection.collection(date).doc().set({
          'title': title,
          'description': description,
          'tags': tags,
          'dueDate': dueDate,
          'isCompleted': isCompleted,
          'isRoutine': isRoutine,
        });
        print('Task added successfully');
        Get.snackbar(
          'Success',
          'Login successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAll(() => NavBarPage(initialPage: 'HomePage'));
      } else {
        print('User is not logged in');
      }
    } catch (e) {
      print('Error adding task: $e');
    }
  }
}
