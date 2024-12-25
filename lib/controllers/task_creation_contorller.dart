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
        final currentDayName = _getDayName(date);

        // Listen to both user-created and routine tasks
        _firestore
            .collection('tasks')
            .doc(userId)
            .collection(formattedDate)
            .snapshots()
            .listen((querySnapshot) async {
          // Fetch active routines to filter routine tasks
          final routinesSnapshot = await _firestore
              .collection('routines')
              .doc(userId)
              .collection('user_routines')
              .where('active', isEqualTo: true)
              .get();

          // Generate routine tasks for the specific date
          for (var routineDoc in routinesSnapshot.docs) {
            final routineId = routineDoc.id;
            final routineColor = routineDoc.data()['routine_color'] ?? Colors.blue.value;

            // Fetch tasks for this routine
            final routineTasksSnapshot = await _firestore
                .collection('routines')
                .doc(userId)
                .collection('user_routines')
                .doc(routineId)
                .collection('tasks')
                .get();

            for (var routineTaskDoc in routineTasksSnapshot.docs) {
              final routineTaskData = routineTaskDoc.data();
              
              dynamic selectedDays;
              const possibleDayFields = [
                'selected_days', 
                'days', 
                'weekdays', 
                'selectedDays'
              ];

              // Try to find a non-null day field
              for (var field in possibleDayFields) {
                selectedDays = routineTaskData[field];
                if (selectedDays != null && selectedDays is List) break;
              }
              
              print('Debug - Routine Task: ${routineTaskData['title']}');
              print('Debug - Selected Days: $selectedDays');
              print('Debug - Current Date: $date');
              print('Debug - Day Match: ${selectedDays != null ? _isDayMatch(selectedDays, date) : "No days found"}');
              
              if (selectedDays != null && _isDayMatch(selectedDays, date)) {
                // Check if task already exists for this date
                final existingTaskQuery = await _firestore
                    .collection('tasks')
                    .doc(userId)
                    .collection(formattedDate)
                    .where('routineId', isEqualTo: routineId)
                    .where('routineTaskId', isEqualTo: routineTaskDoc.id)
                    .get();

                if (existingTaskQuery.docs.isEmpty) {
                  // Generate routine task
                  await _firestore
                      .collection('tasks')
                      .doc(userId)
                      .collection(formattedDate)
                      .add({
                    'title': routineTaskData['title'] ?? 'Routine Task',
                    'description': routineTaskData['description'] ?? '',
                    'dueTime': routineTaskData['due_time'] ?? '',
                    'isCompleted': false,
                    'isRoutine': true,
                    'routineId': routineId,
                    'routineTaskId': routineTaskDoc.id,
                    'routineColor': routineColor.toInt(),
                    'tags': routineTaskData['tags'] ?? [],
                    'selectedDays': selectedDays, // Add selected days for debugging
                    'currentDay': currentDayName, // Add current day for debugging
                  });
                }
              }
            }
          }

          // Fetch tasks again after generating routine tasks
          final updatedQuerySnapshot = await _firestore
              .collection('tasks')
              .doc(userId)
              .collection(formattedDate)
              .get();

          final activeRoutineIds = routinesSnapshot.docs.map((doc) => doc.id).toList();

          tasksForSelectedDate.value = updatedQuerySnapshot.docs
              .map((doc) {
                final taskData = doc.data();
                return {
                  'id': doc.id,
                  'title': taskData['title'] ?? 'Untitled Task',
                  'description': taskData['description'] ?? '',
                  'tags': taskData['tags'] ?? [],
                  'dueDate': taskData['dueDate'],
                  'isCompleted': taskData['isCompleted'] ?? false,
                  'isRoutine': taskData['isRoutine'] ?? false,
                  'routineId': taskData['routineId'] ?? '',
                  'routineColor': taskData['routineColor'] ?? Colors.blue.value,
                };
              })
              .where((task) => 
                // Include non-routine tasks
                !(task['isRoutine'] as bool) || 
                // Include routine tasks only if their routine is active
                ((task['isRoutine'] as bool) && 
                 activeRoutineIds.contains(task['routineId']))
              )
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

  // Helper method to get day name
  String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const abbreviations = ['M', 'T', 'W', 'Th', 'F', 'Sa', 'Su'];
    return days[date.weekday - 1];
  }

  // Helper method to check if day matches
  bool _isDayMatch(List<dynamic> selectedDays, DateTime date) {
    // Comprehensive day mapping
    const dayMappings = {
      'M': ['Monday', 'Mon'],
      'T': ['Tuesday', 'Tue'],
      'W': ['Wednesday', 'Wed'],
      'Th': ['Thursday', 'Thu'],
      'F': ['Friday', 'Fri'],
      'Sa': ['Saturday', 'Sat'],
      'Su': ['Sunday', 'Sun']
    };

    // Get the current day's abbreviations and full names
    final currentDayAbbr = ['M', 'T', 'W', 'Th', 'F', 'Sa', 'Su'][date.weekday - 1];
    final currentDayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][date.weekday - 1];

    print('Debug - Current Day Abbr: $currentDayAbbr');
    print('Debug - Current Day Name: $currentDayName');
    print('Debug - Selected Days: $selectedDays');

    // Check if any of the selected days match the current day
    for (var day in selectedDays) {
      print('Checking day: $day');
      if (day == currentDayAbbr || 
          (dayMappings[day]?.contains(currentDayName) ?? false)) {
        print('Day Match Found!');
        return true;
      }
    }

    print('No Day Match');
    return false;
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
