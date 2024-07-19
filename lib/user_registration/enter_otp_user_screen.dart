import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medipal/models/UserModel.dart';

import '../Individual/bottom_navigation_individual.dart';

class OTPForUserPage extends StatelessWidget {
  final String verificationId;
  final UserModel userModel;

  OTPForUserPage({required this.verificationId, required this.userModel});

  final otpController = TextEditingController();
  final auth = FirebaseAuth.instance;
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('users');

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
        padding: const EdgeInsets.all(20.0), // Added padding for the whole body
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      // Create a PhoneAuthCredential with the code
                      PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                        verificationId: verificationId,
                        smsCode: otpController.text,
                      );

                      User? user = FirebaseAuth.instance.currentUser;

                      await user
                          ?.linkWithCredential(credential)
                          .then((value) async {
                        Map<String, dynamic> userMap = userModel.toMap();
                        await collectionReference
                            .doc(auth.currentUser?.uid)
                            .set(userMap)
                            .then((value) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const BottomNavigationIndividual()),
                            (Route<dynamic> route) => false,
                          );
                        });
                      });
                    } catch (e) {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          duration: const Duration(seconds: 3),
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
