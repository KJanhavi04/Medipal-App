import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medipal/main.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddGuardian extends StatefulWidget {
  const AddGuardian({super.key});

  @override
  _AddGuardianState createState() => _AddGuardianState();
}

class _AddGuardianState extends State<AddGuardian> {
  MobileScannerController? _mobileScannerController;

  bool dependentAdded = false;
  bool isProcessingScan = false;

  @override
  void initState() {
    super.initState();

    _mobileScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _mobileScannerController?.dispose();

    super.dispose();
  }

  void onDetect(BarcodeCapture capture) async {
    if (!isProcessingScan) {
      isProcessingScan = true;

      if (!dependentAdded) {
        final List<Barcode> barcodes = capture.barcodes;
        var guardianId;

        for (final barcode in barcodes) {
          guardianId = barcode.rawValue;
        }

        if (guardianId != null) {
          var guardianData = await FirebaseFirestore.instance
              .collection('users')
              .doc(guardianId)
              .get();

          var dependentData = await FirebaseFirestore.instance
              .collection('dependent')
              .doc(FirebaseAuth.instance.currentUser?.uid.toString())
              .get();

          if (guardianData.exists) {
            Map<String, dynamic> guardianMap =
                guardianData.data() as Map<String, dynamic>;

            Map<String, dynamic> dependentMap =
                dependentData.data() as Map<String, dynamic>;

            var dependentList = guardianMap['dependents'];
            var guardianList = dependentMap['guardians'];

            if (dependentList
                .contains(FirebaseAuth.instance.currentUser?.uid.toString())) {
              //toast msg here to indicate that guardian is already added!
              Fluttertoast.showToast(
                msg: 'Guardian is already added!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                textColor: Colors.white,
              );
            } else {
              dependentList
                  .add(FirebaseAuth.instance.currentUser?.uid.toString());

              guardianList.add(guardianId);

              var noOfDependents = guardianMap['noOfDependents'] + 1;
              var noOfGuardian = dependentMap['noOfGuardian'] + 1;

              guardianMap['noOfDependents'] = noOfDependents;
              guardianMap['dependents'] = dependentList;

              dependentMap['noOfGuardian'] = noOfGuardian;
              dependentMap['guardians'] = guardianList;

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(guardianId)
                  .update(guardianMap);

              await FirebaseFirestore.instance
                  .collection('dependent')
                  .doc(FirebaseAuth.instance.currentUser?.uid.toString())
                  .update(dependentMap);
            }
            dependentAdded = true;
            navigatorKey.currentState?.pop();
            isProcessingScan = false;
          } else {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            scaffoldMessenger.showSnackBar(const SnackBar(
              content: Text('Wrong QR Code!!'),
              duration: Duration(seconds: 3),
            ));
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan guardian QR code'),
      ),
      body: MobileScanner(
        fit: BoxFit.contain,
        controller: _mobileScannerController,
        onDetect: onDetect,
      ),
    );
  }
}
