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
            final routineData = routineDoc.data();
            final routineColor =
                routineData['routine_color'] ?? Colors.blue.value;
            final routineName =
                routineData['routine_name'] ?? 'Unnamed Routine';

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

              if (selectedDays != null && _isDayMatch(selectedDays, date)) {
                // Check if task already exists for this date and routine
                final existingTaskQuery = await _firestore
                    .collection('tasks')
                    .doc(userId)
                    .collection(formattedDate)
                    .where('routineId', isEqualTo: routineId)
                    .where('routineTaskId', isEqualTo: routineTaskDoc.id)
                    .get();

                if (existingTaskQuery.docs.isEmpty) {
                  // Parse due time from routine task
                  String? dueTime = routineTaskData['due_time'];
                  String? dueTimeString;

                  if (dueTime != null) {
                    try {
                      // Try to parse the due time
                      final timeParts = dueTime.toString().split(':');
                      if (timeParts.length >= 2) {
                        final hour = int.parse(timeParts[0]);
                        final minute = int.parse(timeParts[1]);

                        // Create a DateTime with the parsed time
                        final dueDateTime = DateTime(
                            date.year, date.month, date.day, hour, minute);

                        // Convert to ISO8601 string for storage
                        dueTimeString = dueDateTime.toIso8601String();
                      }
                    } catch (e) {
                      print('Error parsing due time: $e');
                    }
                  }

                  // Generate routine task
                  await _firestore
                      .collection('tasks')
                      .doc(userId)
                      .collection(formattedDate)
                      .add({
                    'title': routineTaskData['title'] ?? 'Routine Task',
                    'description': routineTaskData['description'] ?? '',
                    'dueTime': dueTime ?? '',
                    'dueDate': dueTimeString,
                    'isCompleted': false,
                    'isRoutine': true,
                    'routineId': routineId,
                    'routineTaskId': routineTaskDoc.id,
                    'routineColor': routineColor,
                    'routineName': routineName,
                    'tags': routineTaskData['tags'] ?? [],
                    'selectedDays': selectedDays,
                    'currentDay': currentDayName,
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

          final activeRoutineIds =
              routinesSnapshot.docs.map((doc) => doc.id).toList();

          tasksForSelectedDate.value = updatedQuerySnapshot.docs
              .map((doc) {
                final taskData = doc.data();
                final mappedTask = {
                  'id': doc.id,
                  'title': taskData['title'] ?? 'Untitled Task',
                  'description': taskData['description'] ?? '',
                  'tags': taskData['tags'] ?? [],
                  'dueDate': _parseDueDateFromTaskData(date, taskData),
                  'isCompleted': taskData['isCompleted'] ?? false,
                  'isRoutine': taskData['isRoutine'] ?? false,
                  'routineId': taskData['routineId'] ?? '',
                  'routineColor': taskData['routineColor'] ?? Colors.blue.value,
                  'routineName': taskData['routineName'] ?? '',
                };
                return mappedTask;
              })
              .where((task) =>
                  // Include non-routine tasks
                  !(task['isRoutine'] as bool) ||
                  // Include routine tasks only if their routine is active
                  ((task['isRoutine'] as bool) &&
                      activeRoutineIds.contains(task['routineId'])))
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

  /// Parse due date from task data
  DateTime _parseDueDateFromTaskData(
      DateTime date, Map<String, dynamic> taskData) {
    try {
      // First, check if dueDate exists
      dynamic dueDateRaw = taskData['dueDate'];

      // Handle different types of dueDate
      if (dueDateRaw != null) {
        if (dueDateRaw is DateTime) {
          return dueDateRaw;
        } else if (dueDateRaw is String) {
          final parsedDate = DateTime.tryParse(dueDateRaw);
          if (parsedDate != null) {
            return parsedDate;
          }
        }
      }

      // If no valid dueDate, try to parse dueTime
      dynamic dueTimeRaw = taskData['dueTime'];
      if (dueTimeRaw != null) {
        // Convert to string and trim
        String dueTime = dueTimeRaw.toString().trim();

        if (dueTime.isNotEmpty) {
          try {
            // Parse 12-hour time format with AM/PM
            final timeRegex = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*(AM|PM)?\s*$',
                caseSensitive: false);
            final match = timeRegex.firstMatch(dueTime);

            if (match != null) {
              int hour = int.parse(match.group(1)!.trim());
              int minute = int.parse(match.group(2)!.trim());
              String? meridiem = match.group(3)?.trim().toUpperCase();

              // Adjust hour for 12-hour format
              if (meridiem != null) {
                if (meridiem == 'PM' && hour != 12) {
                  hour += 12;
                } else if (meridiem == 'AM' && hour == 12) {
                  hour = 0;
                }
              }

              // Create a DateTime with the parsed time on the given date
              return DateTime(date.year, date.month, date.day, hour, minute);
            }
          } catch (e) {
            print('Error parsing due time: $dueTime - $e');
          }
        }
      }

      // Fallback to the input date if no specific time is found
      return date;
    } catch (e) {
      print('Error in _parseDueDateFromTaskData: $e');
      return date;
    }
  }

  /// Parse due time and combine with the given date
  DateTime _parseDueTime(DateTime date, String dueTime) {
    try {
      final timeParts = dueTime.toString().split(':');
      if (timeParts.length >= 2) {
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        return DateTime(date.year, date.month, date.day, hour, minute);
      }
    } catch (e) {
      print('Error parsing due time: $e');
    }
    return date;
  }

  /// Helper method to get day name
  String _getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
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
    final currentDayAbbr =
        ['M', 'T', 'W', 'Th', 'F', 'Sa', 'Su'][date.weekday - 1];
    final currentDayName = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ][date.weekday - 1];

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
