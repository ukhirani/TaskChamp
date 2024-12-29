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

  /// Prevent multiple task generations in a short time window
  DateTime? _lastTaskGenerationTime;
  static const Duration _taskGenerationCooldown = Duration(milliseconds: 100);

  /// Track generated tasks to prevent duplicates within the same generation cycle
  final Set<String> _generatedTaskUniqueIds = {};

  /// Generate routine tasks for a specific date with debounce and duplicate prevention
  Future<List<Map<String, dynamic>>> generateRoutineTasks(
      DateTime targetDate) async {
    // Clear previous generated task tracking
    _generatedTaskUniqueIds.clear();

    // Prevent frequent task generation for the exact same call
    if (_lastTaskGenerationTime != null) {
      final timeSinceLastGeneration =
          DateTime.now().difference(_lastTaskGenerationTime!);
      if (timeSinceLastGeneration < _taskGenerationCooldown) {
        print('🛑 [TaskController] Task generation too frequent. Skipping.');
        return [];
      }
    }

    // Update last generation time
    _lastTaskGenerationTime = DateTime.now();

    final user = _auth.currentUser;
    if (user == null) {
      print('🚨 [TaskController] No authenticated user found');
      return [];
    }

    final userId = user.uid;
    final formattedDate = targetDate.toIso8601String().split('T')[0];
    final currentDayName = _getDayName(targetDate);

    print('🔍 [TaskController] Generating Routine Tasks');
    print('🕒 Target Date: $formattedDate (${currentDayName})');

    // Fetch active routines
    final routinesSnapshot = await _firestore
        .collection('routines')
        .doc(userId)
        .collection('user_routines')
        .where('active', isEqualTo: true)
        .get();

    print('📊 Active Routines Found: ${routinesSnapshot.docs.length}');

    List<Map<String, dynamic>> generatedTasks = [];

    // Process each active routine
    for (var routineDoc in routinesSnapshot.docs) {
      final routineId = routineDoc.id;
      final routineData = routineDoc.data();
      final routineName = routineData['routine_name'] ?? 'Unnamed Routine';
      final routineColor = routineData['routine_color'] ?? Colors.blue.value;
      final routineSelectedDays = routineData['selected_days'] ?? [];

      print('\n📋 Processing Routine: $routineName (ID: $routineId)');
      print('🗓️ Routine Selected Days: $routineSelectedDays');

      // Fetch tasks for this routine
      final routineTasksSnapshot = await _firestore
          .collection('routines')
          .doc(userId)
          .collection('user_routines')
          .doc(routineId)
          .collection('tasks')
          .get();

      print('📝 Tasks in Routine: ${routineTasksSnapshot.docs.length}');

      // Process each routine task
      for (var routineTaskDoc in routineTasksSnapshot.docs) {
        final routineTaskData = routineTaskDoc.data();
        final routineTaskId = routineTaskDoc.id;
        final taskUniqueId = routineTaskData['task_unique_id'];

        // Determine selected days, prioritize task-specific days over routine days
        final selectedDays =
            _extractSelectedDays(routineTaskData) ?? routineSelectedDays;

        print('\n🔬 Task Details:');
        print('📌 Title: ${routineTaskData['title']}');
        print('📆 Task Selected Days: $selectedDays');
        print('🆔 Task Unique ID: $taskUniqueId');

        // Check if task should be generated for this date
        if (selectedDays != null && _isDayMatch(selectedDays, targetDate)) {
          // More comprehensive existing task check
          final existingTaskQuery = await _firestore
              .collection('tasks')
              .doc(userId)
              .collection(formattedDate)
              .where('task_unique_id', isEqualTo: taskUniqueId)
              .get();

          print(
              '🕵️ Existing Tasks for this date: ${existingTaskQuery.docs.length}');

          // Generate task if no existing task with the same unique ID
          if (existingTaskQuery.docs.isEmpty) {
            final taskToGenerate = _prepareRoutineTask(
                routineTaskData,
                routineId,
                routineTaskId,
                routineName,
                routineColor,
                targetDate,
                currentDayName);

            generatedTasks.add(taskToGenerate);
            print('✅ New Task Generated: ${taskToGenerate['title']}');
          } else {
            print('❌ Task with Unique ID Already Exists, Skipping');
          }
        } else {
          print('❌ Task Not Matched for this Date');
        }
      }
    }

    // Persist generated tasks to Firestore
    await _persistGeneratedTasks(userId, formattedDate, generatedTasks);

    print('📊 Total Tasks Generated: ${generatedTasks.length}');
    return generatedTasks;
  }

  /// Reset last task generation time (useful for testing)
  void resetLastTaskGenerationTime() {
    _lastTaskGenerationTime = null;
    _generatedTaskUniqueIds.clear();
  }

  /// Extract selected days from various possible fields
  List<String>? _extractSelectedDays(Map<String, dynamic> routineTaskData) {
    const possibleDayFields = [
      'selected_days',
      'days',
      'weekdays',
      'selectedDays'
    ];

    for (var field in possibleDayFields) {
      final days = routineTaskData[field];
      if (days != null && days is List) {
        return days.map((day) => day.toString()).toList();
      }
    }

    return null;
  }

  /// Prepare routine task data
  Map<String, dynamic> _prepareRoutineTask(
    Map<String, dynamic> routineTaskData,
    String routineId,
    String routineTaskId,
    String routineName,
    int routineColor,
    DateTime targetDate,
    String currentDayName,
  ) {
    // Parse due time
    String? dueTime = routineTaskData['due_time'] ?? routineTaskData['dueTime'];
    DateTime? dueDateTime;

    if (dueTime != null) {
      try {
        final timeParts = dueTime.toString().split(':');
        if (timeParts.length >= 2) {
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          dueDateTime = DateTime(
              targetDate.year, targetDate.month, targetDate.day, hour, minute);
        }
      } catch (e) {
        print('Error parsing due time: $e');
      }
    }

    return {
      'title': routineTaskData['title'] ?? 'Routine Task',
      'description': routineTaskData['description'] ?? '',
      'dueTime': dueTime ?? '',
      'dueDate': dueDateTime?.toIso8601String(),
      'isCompleted': false,
      'isRoutine': true,
      'routineId': routineId,
      'routineTaskId': routineTaskId,
      'routineColor': routineColor,
      'routineName': routineName,
      'tags': routineTaskData['tags'] ?? [],
      'selectedDays': routineTaskData['selected_days'] ?? [],
      'currentDay': currentDayName,
      'task_unique_id': routineTaskData['task_unique_id'],
    };
  }

  /// Persist generated tasks to Firestore
  Future<void> _persistGeneratedTasks(
    String userId,
    String formattedDate,
    List<Map<String, dynamic>> tasks,
  ) async {
    for (var task in tasks) {
      await _firestore
          .collection('tasks')
          .doc(userId)
          .collection(formattedDate)
          .add(task);
    }
  }

  /// Existing day matching method
  bool _isDayMatch(List<dynamic> selectedDays, DateTime date) {
    // Precise day mappings with strict matching
    const dayMappings = {
      'M': ['Monday', 'Mon'],
      'T': ['Tuesday', 'Tue'],
      'W': ['Wednesday', 'Wed'],
      'Th': ['Thursday', 'Thu'],
      'F': ['Friday', 'Fri'],
      'Sa': ['Saturday', 'Sat'],
      'Su': ['Sunday', 'Sun']
    };

    // Day abbreviations and their corresponding day numbers
    const dayNumberMappings = {
      'M': 1, // Monday
      'T': 2, // Tuesday
      'W': 3, // Wednesday
      'Th': 4, // Thursday
      'F': 5, // Friday
      'Sa': 6, // Saturday
      'Su': 7 // Sunday
    };

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

    print('Day Matching Debug:');
    print('Current Day Abbreviation: $currentDayAbbr');
    print('Current Day Name: $currentDayName');
    print('Selected Days: $selectedDays');

    final matchResult = selectedDays.any((day) {
      // Convert to string to handle potential non-string inputs
      final normalizedDay = day.toString().trim();

      // Strict matching logic
      bool isMatch = false;

      // Exact match with current day abbreviation or name
      if (normalizedDay.toLowerCase() == currentDayAbbr.toLowerCase() ||
          normalizedDay.toLowerCase() == currentDayName.toLowerCase()) {
        isMatch = true;
      }

      // Check against predefined day mappings
      else if (dayMappings[normalizedDay]?.contains(currentDayName) ?? false) {
        isMatch = true;
      }

      // Additional checks for specific day variations
      else if (normalizedDay.toLowerCase() == 's' &&
          currentDayName.toLowerCase() == 'sunday' &&
          !selectedDays.contains('Su')) {
        isMatch = true;
      } else if (normalizedDay.toLowerCase() == 'sa' &&
          currentDayName.toLowerCase() == 'saturday') {
        isMatch = true;
      }

      print('Checking Day: $normalizedDay, Match: $isMatch');
      return isMatch;
    });

    print('Final Match Result: $matchResult');
    return matchResult;
  }

  /// Existing method to get day name
  String _getDayName(DateTime date) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[date.weekday - 1];
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
            .listen((querySnapshot) async {
          // Generate routine tasks for the date
          await generateRoutineTasks(date);

          // Fetch tasks again after generating routine tasks
          final updatedQuerySnapshot = await _firestore
              .collection('tasks')
              .doc(userId)
              .collection(formattedDate)
              .get();

          // Fetch active routines to filter tasks
          final routinesSnapshot = await _firestore
              .collection('routines')
              .doc(userId)
              .collection('user_routines')
              .where('active', isEqualTo: true)
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

        // Update task completion status
        await taskDoc.reference.update({
          'isCompleted': !isCompleted,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Regenerate routine tasks to ensure consistency
        await generateRoutineTasks(dueDate);

        // Fetch updated tasks for the date
        final updatedQuerySnapshot =
            await tasksCollection.collection(dateStr).get();

        // Fetch active routines to filter tasks
        final routinesSnapshot = await _firestore
            .collection('routines')
            .doc(userId)
            .collection('user_routines')
            .where('active', isEqualTo: true)
            .get();

        final activeRoutineIds =
            routinesSnapshot.docs.map((doc) => doc.id).toList();

        // Process tasks
        var processedTasks = updatedQuerySnapshot.docs
            .map((doc) {
              final taskData = doc.data();
              return {
                'id': doc.id,
                'title': taskData['title'] ?? 'Untitled Task',
                'description': taskData['description'] ?? '',
                'tags': taskData['tags'] ?? [],
                'dueDate': _parseDueDateFromTaskData(dueDate, taskData),
                'isCompleted': taskData['isCompleted'] ?? false,
                'isRoutine': taskData['isRoutine'] ?? false,
                'routineId': taskData['routineId'] ?? '',
                'routineColor': taskData['routineColor'] ?? Colors.blue.value,
                'routineName': taskData['routineName'] ?? '',
              };
            })
            .where((task) =>
                // Include non-routine tasks
                !(task['isRoutine'] as bool) ||
                // Include routine tasks only if their routine is active
                ((task['isRoutine'] as bool) &&
                    activeRoutineIds.contains(task['routineId'])))
            .toList();

        // Update tasks with processed list
        tasksForSelectedDate.value = processedTasks;

        // Sort tasks
        sortTasks();

        print('Task updated successfully');
      } else {
        print('User is not logged in');
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  void sortTasks() {
    if (tasksForSelectedDate.value.isNotEmpty) {
      tasksForSelectedDate.value.sort((a, b) {
        // First, prioritize incomplete tasks
        if (a['isCompleted'] == false && b['isCompleted'] == true) {
          return -1;
        }
        if (a['isCompleted'] == true && b['isCompleted'] == false) {
          return 1;
        }

        // If both have the same completion status, sort by due date
        DateTime? dateA = a['dueDate'] is DateTime ? a['dueDate'] : null;
        DateTime? dateB = b['dueDate'] is DateTime ? b['dueDate'] : null;

        // If both dates are null, maintain original order
        if (dateA == null && dateB == null) return 0;

        // If one date is null, prioritize the non-null date
        if (dateA == null) return 1;
        if (dateB == null) return -1;

        // Compare dates
        return dateA.compareTo(dateB);
      });
    }
  }
}
