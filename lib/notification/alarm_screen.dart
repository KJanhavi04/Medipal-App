import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medipal/credentials/firebase_cred.dart';
import 'package:medipal/models/AlarmModel.dart';
import 'package:medipal/models/MedicationModel.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../credentials/twilio_cred.dart';

class AlarmScreen extends StatefulWidget {
  final String alarmId;

  AlarmScreen({required this.alarmId});

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  late AlarmModel alarm;
  late MedicationModel medication;

  Map<String, dynamic> alarmMap = {};
  Map<String, dynamic> medicationMap = {};
  Map<String, dynamic> userMap = {};

  var user;
  var role = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<void>(
        future: loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error.toString()}'),
            );
          } else {
            return buildUI();
          }
        },
      ),
    );
  }

  Future<void> loadData() async {
    alarmMap = await loadAlarmData();
    medicationMap = await loadMedicationData();
    var userList = await FirebaseCred().getData();
    role = userList[1];
    user = userList[0];
  }

  Future<Map<String, dynamic>> loadMedicationData() async {
    QuerySnapshot medicationSnapshot = await FirebaseFirestore.instance
        .collection('medications')
        .where('medicationId', isEqualTo: alarmMap['medicationId'])
        .get();
    for (QueryDocumentSnapshot s in medicationSnapshot.docs) {
      medication = MedicationModel.fromDocumentSnapshot(s);
      medicationMap = medication.toMap();
    }
    return medicationMap;
  }

  Future<Map<String, dynamic>> loadAlarmData() async {
    QuerySnapshot alarmSnapshot = await FirebaseFirestore.instance
        .collection('alarms')
        .where('alarmId', isEqualTo: widget.alarmId)
        .get();
    for (QueryDocumentSnapshot s in alarmSnapshot.docs) {
      alarm = AlarmModel.fromDocumentSnapshot(s);
      alarmMap = alarm.toMap();
    }
    return alarmMap;
  }

  Widget buildUI() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Alarm Icon positioned at top-left
            // Align(
            //   alignment: Alignment.topRight,
            //   child: Padding(
            //     padding: const EdgeInsets.only(top: 0.0, left: 320.0),
            AlarmIcon(
              medicineType: medicationMap['type'] ?? 'Pills',
              medicinceImg: medicationMap['medicationImg'],
            ),
            //   ),
            // ),
            const SizedBox(height: 16),
            // Displaying alarm time
            Text(
              alarmMap['time']
                  .toString()
                  .split(' ')
                  .last
                  .split(':')
                  .sublist(0, 2)
                  .join(':') ??
                  'No time available',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Medicine Type Icon with specified size
            Container(
              // width: 300, // Set width as needed
              // height: 300, // Set height as needed
              child: MedicineTypeIcon(
                medicineType: medicationMap['type'] ?? 'Pills',
                medicinceImg: medicationMap['medicationImg'],
              ),
            ),
            const SizedBox(height: 10),

            // Medicine Name
            Text(
              medicationMap['name'] ?? 'No medication name available',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            // Add some space below the Medicine Name
            const SizedBox(height: 10),

            // Medicine Description
            MedicineDescription(
              description:
              medicationMap['description'] ?? 'No description available',
            ),
            // Add some space below the Medicine Description
            const SizedBox(height: 10),

            // Quantity of Medicine
            Text(
              'Quantity: ${medicationMap['dosage'] ?? 0}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 100),

            // Action Buttons
            ActionButtons(
              alarmId: widget.alarmId,
              alarmMap: alarmMap,
              medicationMap: medicationMap,
              userId: user.uid,
              role: role,
            ),
          ],
        ),
      ),
    );
  }
}

class MedicineDescription extends StatelessWidget {
  final String description;

  MedicineDescription({required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        description,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class AlarmIcon extends StatelessWidget {
  final String medicineType;
  final String medicinceImg;

  @override
  AlarmIcon({required this.medicineType, required this.medicinceImg});

  Widget build(BuildContext context) {
    if (medicinceImg == '') {
      return Image.asset(
        'assets/images/medipal.png',
        width: 130,
        height: 130,
      );
    } else {
      return Image.asset(
        'assets/images/medipal.png',
        width: 50,
        height: 50,
      );
    }
  }
}

class MedicineTypeIcon extends StatelessWidget {
  final String medicineType;
  final String medicinceImg;

  MedicineTypeIcon({required this.medicineType, required this.medicinceImg});

  @override
  Widget build(BuildContext context) {
    String imagePath;
    double width, height;
    if (medicinceImg == '') {
      width = 64;
      height = 64;
      if (medicineType == 'Pills') {
        imagePath =
        'https://firebasestorage.googleapis.com/v0/b/medipal-61348.appspot.com/o/medication_icons%2Fpill_icon.png?alt=media&token=8967025a-597f-4d82-8b39-d705e2e051b4';
      } else if (medicineType == 'Liquid') {
        imagePath =
        'https://firebasestorage.googleapis.com/v0/b/medipal-61348.appspot.com/o/medication_icons%2Fliquid_icon.png?alt=media&token=0541a72d-b74c-439e-8d40-2851bbc421aa';
      } else {
        imagePath =
        'https://firebasestorage.googleapis.com/v0/b/medipal-61348.appspot.com/o/medication_icons%2Finjection_icon.png?alt=media&token=95b4de3d-4cc3-41c1-b254-f4552d5d4545';
      }
      return Image.network(
        imagePath,
        width: width, // Adjust the width as needed
        height: height, // Adjust the height as needed
      );
    } else {
      imagePath = medicinceImg;
      width = 128;
      height = 128;
      return ClipOval(
        child: Image.network(
          imagePath,
          width: width, // Adjust the width as needed
          height: height, // Adjust the height as needed
          fit: BoxFit.cover, // Adjust the fit property as needed
        ),
      );
    }
  }
}

class ActionButtons extends StatelessWidget {
  final String alarmId;
  final String userId;
  final String role;
  Map<String, dynamic> alarmMap;
  Map<String, dynamic> medicationMap;

  ActionButtons({required this.alarmId,
    required this.alarmMap,
    required this.medicationMap,
    required this.userId,
    required this.role});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularButton(
          icon: Icons.cancel,
          label: 'Cancel',
          onPressed: () {
            // Show Cancel Popup
            _showCancelDialog(context);
          },
          color: Colors.red,
        ),
        const SizedBox(width: 60), // Add space between icons
        CircularButton(
          icon: Icons.snooze,
          label: 'Snooze',
          onPressed: () async {
            alarmMap['status'] = 'snoozed';
            await FirebaseFirestore.instance.collection('alarms')
                .doc(alarmId)
                .update(alarmMap).then((value) => Navigator.of(context).pop()
            );
          },
          color: Color.fromARGB(255, 244, 174, 54),
        ),
        const SizedBox(width: 60),
        CircularButton(
          icon: Icons.check,
          label: 'Take',
          onPressed: () async {
            alarmMap['status'] = 'taken';
            medicationMap['inventory']['quantity'] = medicationMap['inventory']
            ['quantity'] -
                medicationMap['dosage'];

            if (medicationMap['inventory']['quantity'] <= 0) {
              medicationMap['inventory']['quantity'] = 0;
            }
            var quantity = medicationMap['inventory']['quantity'];
            var name = medicationMap['name'];
            await FirebaseFirestore.instance
                .collection('alarms')
                .doc(alarmId)
                .update(alarmMap)
                .then((value) async {
              await FirebaseFirestore.instance
                  .collection('medications')
                  .doc(medicationMap['medicationId'])
                  .update(medicationMap)
                  .then((value) async {
                if (medicationMap['inventory']['quantity'] <=
                    medicationMap['inventory']['reorderLevel']) {
                  TwilioFlutter twilioFlutter;
                  final cred = await TwilioCred().readCred();
                  if (role == 'dependent') {
                    final guardians =
                    await FirebaseCred().getGuardianData(userId);

                    final dependent =
                    await FirebaseCred().getDependentData(userId);

                    String dependentName = dependent['name'];

                    twilioFlutter = TwilioFlutter(
                      accountSid: cred[0],
                      authToken: cred[1],
                      twilioNumber: cred[2],
                    );

                    for (Map guardian in guardians) {
                      twilioFlutter.sendSMS(
                        toNumber: '+91' + guardian['phoneNo'],
                        messageBody:
                        "$quantity units of medicine: $name remaining of your dependent: $dependentName!",
                      );
                    }
                  } else {
                    final userData = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .get();
                    final userMap = userData.data() as Map<String, dynamic>;
                    twilioFlutter = TwilioFlutter(
                      accountSid: cred[0],
                      authToken: cred[1],
                      twilioNumber: cred[2],
                    );

                    twilioFlutter.sendSMS(
                      toNumber: '+91' + userMap['phoneNo'],
                      messageBody:
                      "$quantity units of medicine $name remaining!",
                    );
                  }
                }
                Navigator.of(context).pop();
              });
            });
          },
          color: Colors.green,
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Medication'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Why are you canceling this medication?'),
                TextFormField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Enter reason here',
                  ),
                  controller: reasonController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a reason';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  String reason = reasonController.text.trim();
                  alarmMap['skipReason'] = reason;
                  alarmMap['status'] = 'Skipped';
                  await FirebaseFirestore.instance
                      .collection('alarms')
                      .doc(alarmId)
                      .update(alarmMap)
                      .then((value) async {
                    if (role == 'dependent') {
                      final cred = await TwilioCred().readCred();
                      final guardians =
                      await FirebaseCred().getGuardianData(userId);
                      TwilioFlutter twilioFlutter;
                      if (guardians != null) {
                        twilioFlutter = TwilioFlutter(
                          accountSid: cred[0],
                          authToken: cred[1],
                          twilioNumber: cred[2],
                        );

                        final dependent =
                        await FirebaseCred().getDependentData(userId);

                        String dependentName = dependent['name'];

                        for (Map guardian in guardians) {
                          twilioFlutter.sendSMS(
                            toNumber: '+91' + guardian['phoneNo'],
                            messageBody:
                            "Your dependent $dependentName did not take the medicine! \nReason: $reason",
                          );
                        }
                      } else {
                        // Handle the case where guardian is null (e.g., show an error message).
                        Fluttertoast.showToast(
                          msg: 'Guardian data not available.',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor:
                          const Color.fromARGB(255, 240, 91, 91),
                          textColor: const Color.fromARGB(255, 255, 255, 255),
                        );
                      }
                    }
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  });
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}

class CircularButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  CircularButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          child: CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(
              icon,
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}
