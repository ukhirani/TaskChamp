import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/navbar_widget.dart';

class TaskController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var tasks = <Map<String, dynamic>>[].obs; // All tasks
  var tasksForSelectedDate =
      <Map<String, dynamic>>[].obs; // Tasks for specific date
  var isLoading = false.obs; // Loading state
  var errorMessage = ''.obs; // Error message

  /// Initialize Firebase
  Future<void> initFirebase() async {
    try {
      await Firebase.initializeApp();
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }

  /// Add a new task
  void addTask({
    required String title,
    required String description,
    required String? tags,
    required DateTime? dueDate,
    required bool isCompleted,
    required bool isRoutine,
  }) async {
    if (title.length > 20) {
      Get.snackbar(
        'Error',
        'Please keep the title less than 15 characters.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

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
          'dueDate': dueDate?.toIso8601String(),
          'isCompleted': isCompleted,
          'isRoutine': isRoutine,
        });

        print('Task added successfully');
        Get.snackbar(
          'Success',
          'Task added successfully!',
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

  /// Listen for real-time updates for tasks on a specific date
  void listenToTasksForDate(DateTime date) {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = _auth.currentUser;
      if (user != null) {
        final userId = user.uid;
        final formattedDate = date.toIso8601String().split('T')[0];

        _firestore
            .collection('tasks')
            .doc(userId)
            .collection(formattedDate)
            .snapshots()
            .listen((querySnapshot) {
          tasksForSelectedDate.value = querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
          isLoading.value = false;
        });
      } else {
        errorMessage.value = 'User is not logged in';
        isLoading.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to listen to tasks: $e';
      isLoading.value = false;
    }
  }

  /// Update a task's completion status
  void updateTaskInDatabase(
      DateTime dueDate, String title, bool isCompleted) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userId = user.uid;
        final tasksCollection = _firestore.collection('tasks').doc(userId);
        final dateStr = dueDate.toIso8601String().split('T')[0];

        final querySnapshot = await tasksCollection.collection(dateStr).get();
        final taskDoc =
            querySnapshot.docs.firstWhere((doc) => doc['title'] == title);

        await taskDoc.reference.update({'isCompleted': !isCompleted});
        print('Task updated successfully');
      } else {
        print('User is not logged in');
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }
}
