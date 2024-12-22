import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Routine {
  final String id;
  final String name;
  final bool active;
  final DateTime dateAdded;

  Routine({
    required this.id,
    required this.name,
    required this.active,
    required this.dateAdded,
  });

  factory Routine.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Routine(
      id: doc.id,
      name: data['routine_name'] ?? '',
      active: data['active'] ?? true,
      dateAdded: (data['date_added'] as Timestamp).toDate(),
    );
  }
}

class ShowRoutinesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<Routine> activeRoutines = <Routine>[].obs;
  final RxList<Routine> inactiveRoutines = <Routine>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRoutines();
  }

  Future<void> fetchRoutines() async {
    try {
      isLoading.value = true;
      final String? uid = _auth.currentUser?.uid;

      if (uid == null) {
        throw Exception('No authenticated user found');
      }

      // Listen to routine changes in real-time
      _firestore
          .collection('routines')
          .doc(uid)
          .collection('user_routines')
          .snapshots()
          .listen((snapshot) {
        List<Routine> active = [];
        List<Routine> inactive = [];

        for (var doc in snapshot.docs) {
          final routine = Routine.fromFirestore(doc);
          if (routine.active) {
            active.add(routine);
          } else {
            inactive.add(routine);
          }
        }

        // Sort routines by date added
        active.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        inactive.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

        activeRoutines.value = active;
        inactiveRoutines.value = inactive;
        isLoading.value = false;
      });
    } catch (e) {
      print('Error fetching routines: $e');
      isLoading.value = false;
    }
  }

  // Method to toggle routine active status
  Future<void> toggleRoutineStatus(String routineId, bool currentStatus) async {
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('No authenticated user found');

      await _firestore
          .collection('routines')
          .doc(uid)
          .collection('user_routines')
          .doc(routineId)
          .update({'active': !currentStatus});
    } catch (e) {
      print('Error toggling routine status: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getRoutineTasks(String routineId) async {
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('No authenticated user found');

      final tasksSnapshot = await _firestore
          .collection('routines')
          .doc(uid)
          .collection('user_routines')
          .doc(routineId)
          .collection('tasks')
          .get();

      return tasksSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching routine tasks: $e');
      return [];
    }
  }
}
