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
      // Query to find the routine across all users
      final querySnapshot = await _firestore.collection('routines').get();

      print('Total users in routines collection: ${querySnapshot.docs.length}');

      // Iterate through all users
      for (var userDoc in querySnapshot.docs) {
        print('Checking user: ${userDoc.id}');

        // Check user's user_routines collection for the specific routine
        final userRoutinesQuery = await _firestore
            .collection('routines')
            .doc(userDoc.id)
            .collection('user_routines')
            .where('routine_id', isEqualTo: routineId)
            .get();

        print(
            'Routines found for user ${userDoc.id}: ${userRoutinesQuery.docs.length}');

        // If routine found, return the first matching document
        if (userRoutinesQuery.docs.isNotEmpty) {
          print('Routine found: ${userRoutinesQuery.docs.first.data()}');
          return userRoutinesQuery.docs.first;
        }
      }

      // No routine found
      print('No routine found with ID: $routineId');
      return null;
    } catch (e) {
      print('Error fetching routine: $e');
      rethrow;
    }
  }

  Future<void> importRoutine(String routineId) async {
    try {
      // Fetch the routine document
      final routineDoc = await fetchRoutineById(routineId);
    } catch (e) {
      print('Error importing routine: $e');
      rethrow;
    }
  }
}
