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
        throw Exception('No authenticated user found');
      }

      // Generate a unique routine ID
      String routineId = _firestore.collection('routines').doc().id;

      // Create/get the user's document in routines collection
      final userDocRef = _firestore.collection('routines').doc(uid);
      final userDocSnapshot = await userDocRef.get();

      if (!userDocSnapshot.exists) {
        // Create user document if it doesn't exist
        await userDocRef.set({
          'uid': uid,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      // Add routine data
      await userDocRef.collection('user_routines').doc(routineId).set({
        'routine_name': routineName,
        'routine_id': routineId,
        'date_added': FieldValue.serverTimestamp(),
        'active': true,
      });

      // Add tasks collection under the routine
      for (var task in tasks) {
        // Ensure consistent key for selected days
        if (task.containsKey('selectedDays')) {
          task['selected_days'] = task['selectedDays'];
          task.remove('selectedDays');
        }

        await userDocRef
            .collection('user_routines')
            .doc(routineId)
            .collection('tasks')
            .add(task);
      }
    } catch (e) {
      print('Error adding routine: $e');
      throw e;
    }
  }
}
