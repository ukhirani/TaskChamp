import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'add_routine_controller.dart';

class RoutineImportController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AddRoutineController _addRoutineController =
      Get.find<AddRoutineController>();

  Future<QueryDocumentSnapshot?> fetchRoutineById(String routineId) async {
    try {
      // Validate input
      if (routineId.trim().isEmpty) {
        throw Exception('Routine ID cannot be empty');
      }

      // Query to find the routine across all users
      final querySnapshot = await _firestore.collection('routines').get();

      // Iterate through all users
      for (var userDoc in querySnapshot.docs) {
        // Check user's user_routines collection for the specific routine
        final userRoutinesQuery = await _firestore
            .collection('routines')
            .doc(userDoc.id)
            .collection('user_routines')
            .where('routine_id', isEqualTo: routineId)
            .get();

        // If routine found, return the first matching document
        if (userRoutinesQuery.docs.isNotEmpty) {
          return userRoutinesQuery.docs.first;
        }
      }

      // No routine found
      return null;
    } catch (e) {
      print('Error fetching routine: $e');
      rethrow;
    }
  }

  Future<void> importRoutine(String routineId) async {
    try {
      // Validate input
      if (routineId.trim().isEmpty) {
        throw Exception('Routine ID cannot be empty');
      }

      // Fetch the routine document
      final routineDoc = await fetchRoutineById(routineId);

      if (routineDoc == null) {
        throw Exception('Routine not found');
      }

      // Fetch tasks for this routine
      final tasksSnapshot =
          await routineDoc.reference.collection('tasks').get();

      // Check if tasks exist
      if (tasksSnapshot.docs.isEmpty) {
        throw Exception('No tasks found in the routine');
      }

      // Convert tasks to the format expected by addRoutine
      List<Map<String, dynamic>> tasks = tasksSnapshot.docs.map((taskDoc) {
        var taskData = taskDoc.data();

        // Ensure the task data matches the expected format
        return {
          'title': taskData['title'] ?? 'Untitled Task',
          'dueTime': taskData['due_time'] ?? '',
          'selectedDays': taskData['selected_days'] ?? [],
        };
      }).toList();

      // Use existing addRoutine method to import the routine
      await _addRoutineController.addRoutine(
          routineDoc['routine_name'] ?? 'Imported Routine', tasks);
    } catch (e) {
      print('Error importing routine: $e');
      rethrow;
    }
  }
}
