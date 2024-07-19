import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medipal/models/DependentModel.dart';
import 'package:medipal/models/UserModel.dart';


class FirebaseCred {
  Future<List> getData() async {
    final user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot dependentQuery = await firestore
        .collection('dependent')
        .where('userId', isEqualTo: user?.uid.toString())
        .get();
    QuerySnapshot userQuery = await firestore
        .collection('users')
        .where('userId', isEqualTo: user?.uid.toString())
        .get();
    var role;
    if (dependentQuery.docs.isNotEmpty) {
      role = 'dependent';
    } else {
      for (QueryDocumentSnapshot document in userQuery.docs) {
        Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
        role = userData['role'];
      }
    }
    return ([user, role]);
  }

  getGuardianData(String userId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('dependents', arrayContains: userId)
        .get();
    UserModel userModel;
    Map<String, dynamic> map = {};
    List<Map<String, dynamic>> guardians= [];
    if (snapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot s in snapshot.docs) {
        userModel = UserModel.fromDocumentSnapshot(s);
        map = userModel.toMap();
      }
      guardians.add(map);
    }
    return guardians;
  }

  getDependentData(String userId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('dependent')
        .where('userId', isEqualTo: userId)
        .get();
    DependentModel dependentModel;
    Map<String, dynamic> map = {};
    if (snapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot s in snapshot.docs) {
        dependentModel = DependentModel.fromDocumentSnapshot(s);
        map = dependentModel.toMap();
      }
      return map;
    }
  }
}
