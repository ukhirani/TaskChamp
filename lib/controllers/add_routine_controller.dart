import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddRoutineController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to add a routine
  Future<void> addRoutine(
      String routineName, List<Map<String, dynamic>> tasks) async {
    try {
      // Get current user ID
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) {
        print('🚨 [AddRoutineController] ERROR: No authenticated user found');
        throw Exception('No authenticated user found');
      }

      // Generate a unique routine ID
      String routineId = _firestore.collection('routines').doc().id;

      print('🔹 [AddRoutineController] Adding New Routine');
      print('🔹 Routine Name: $routineName');
      print('🔹 Routine ID: $routineId');
      print('🔹 Number of Tasks: ${tasks.length}');

      // Create/get the user's document in routines collection
      final userDocRef = _firestore.collection('routines').doc(uid);
      final userDocSnapshot = await userDocRef.get();

      if (!userDocSnapshot.exists) {
        // Create user document if it doesn't exist
        await userDocRef.set({
          'uid': uid,
          'created_at': FieldValue.serverTimestamp(),
        });
        print('🔹 Created new user document in routines collection');
      }

      // Add routine data
      await userDocRef.collection('user_routines').doc(routineId).set({
        'routine_name': routineName,
        'routine_id': routineId,
        'date_added': FieldValue.serverTimestamp(),
        'active': true,
      });
      print('🔹 Routine document created in user_routines');

      // Add tasks collection under the routine
      for (var task in tasks) {
        // Convert selectedDays to selected_days for consistency
        if (task.containsKey('selectedDays')) {
          task['selected_days'] = task['selectedDays'];
          task.remove('selectedDays');
        }

        // Ensure due_time is stored correctly
        if (task.containsKey('dueTime')) {
          task['due_time'] = task['dueTime'];
          task.remove('dueTime');
        }

        // Generate a unique task identifier
        final uniqueTaskId = _firestore.collection('routines').doc().id;
        task['task_unique_id'] = uniqueTaskId;

        print('🔹 Adding Task to Routine:');
        print('   - Title: ${task['title']}');
        print('   - Selected Days: ${task['selected_days']}');
        print('   - Unique Task ID: $uniqueTaskId');

        await userDocRef
            .collection('user_routines')
            .doc(routineId)
            .collection('tasks')
            .doc(uniqueTaskId) // Use the unique ID as the document ID
            .set(task);
      }

      print('✅ [AddRoutineController] Routine and Tasks Added Successfully');
    } catch (e) {
      print('🚨 [AddRoutineController] Error adding routine: $e');
      throw e;
    }
  }

  // Extract selected days from various possible fields
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
}
