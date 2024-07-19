import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medipal/Dependent/bottom_navigation_dependent.dart';
import 'package:medipal/models/DependentModel.dart';

class OTPForDependentPage extends StatelessWidget {
  final String verificationId;
  final String name;
  final String phoneNo;

  OTPForDependentPage({
    required this.verificationId,
    required this.name,
    required this.phoneNo,
  });

  final otpController = TextEditingController();

  final auth = FirebaseAuth.instance;

  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('dependent');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 223, 238, 255),
              Color.fromARGB(240, 183, 210, 253),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                  ),
                  controller: otpController,
                ),
              ),
              const SizedBox(height: 48.0),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return _buildLoadingIndicator();
                      },
                    );
                    try {
                      PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                        verificationId: verificationId,
                        smsCode: otpController.text,
                      );

                      await auth.signInWithCredential(credential).then(
                        (value) async {
                          User? user = FirebaseAuth.instance.currentUser;

                          final userDoc =
                              await collectionReference.doc(user?.uid).get();
                          if (!userDoc.exists) {
                            DependentModel dependentModel = DependentModel(
                              userId: user!.uid,
                              name: name,
                              phoneNo: phoneNo,
                              guardians: [],
                              noOfGuardian: 0,
                            );

                            Map<String, dynamic> dependent =
                                dependentModel.toMap();
                            await collectionReference
                                .doc(user.uid)
                                .set(dependent);
                          }

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (builder) =>
                                  const BottomNavigationDependent(),
                            ),
                            (route) => false,
                          );
                        },
                      );
                    } catch (e) {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Invalid OTP'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  child: const Text('Verify'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.fromARGB(255, 150, 161, 170),
            ),
          ),
        ],
      ),
    );
  }
}
