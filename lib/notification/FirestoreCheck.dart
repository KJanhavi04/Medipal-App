import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medipal/credentials/twilio_cred.dart';
import 'package:medipal/models/DependentModel.dart';
import 'package:medipal/models/UserModel.dart';
import 'package:medipal/notification/notification_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

import '../credentials/firebase_cred.dart';

class FireStoreCheck {
  Future<void> checkFirestore() async {
    await Firebase.initializeApp();
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    print('we');

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('alarms')
          .where('userId', isEqualTo: user?.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          var time = data['time'];
          var name = data['message'];
          var status = data['status'];
          var alarmId = data['alarmId'];

          DateTime timestamp = DateTime.parse(time);
          DateTime timestamp2 = DateTime.now();

          if (timestamp.isBefore(timestamp2) && status == 'pending') {
            await NotificationService.showNotification(
                title: 'Medipal',
                body: 'This is a reminder',
                payload: {
                  "open": "true",
                  "alarmId": alarmId,
                },
                actionButtons: [
                  NotificationActionButton(
                      key: 'key', label: 'Open', actionType: ActionType.Default)
                ]);
          }
        }
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Error retrieving documents',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 240, 91, 91),
        textColor: const Color.fromARGB(255, 255, 255, 255),
      );
    }

    try {
      QuerySnapshot appointmentSnapshot = await firestore
          .collection('appointments')
          .where('userId', isEqualTo: user?.uid)
          .get();
      if (appointmentSnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in appointmentSnapshot.docs) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          var time = data['appointmentTime'];

          DateTime timestamp = DateTime.parse(time);
          DateTime currentTime = DateTime.now();

          Duration difference = timestamp.difference(currentTime);
          if (difference.inHours <= 24 && data['status']== 'pending') {
            final cred = await TwilioCred().readCred();
            TwilioFlutter twilioFlutter = TwilioFlutter(accountSid: cred[0],
                authToken: cred[1],
                twilioNumber: cred[2]);

            final user= await FirebaseCred().getData();
            String role= user[1];

            Map<String, dynamic> userData={};

            DateTime appointmentDateTime= DateTime.parse(data['appointmentTime']);

            String doctorName= data['doctorName'];
            String location= data['location'];
            String description= data['description'];
            String date= DateFormat('d MMM yyyy').format(appointmentDateTime).toString();
            String time= DateFormat.Hm().format(appointmentDateTime).toString();

            String msg= 'This is a reminder of your upcoming appointment: \nDoctor: $doctorName \nLocation: $location \nDescription: $description \nDate: $date \nTime: $time \n\nPlease ensure that you arrive on time. \nBest regards, \nMediPal : Your Own Reminder App';

            if(role== 'dependent'){
              QuerySnapshot snapshots= await FirebaseFirestore.instance.collection('dependent').where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid.toString()).get();
              if(snapshots.docs.isNotEmpty){
                for(QueryDocumentSnapshot snapshot in snapshots.docs){
                  DependentModel dependentModel= DependentModel.fromDocumentSnapshot(snapshot);
                  userData= dependentModel.toMap();
                }
              }
              var guardians= await FirebaseCred().getGuardianData(userData['userId']);
              String msgForGuardian= 'This is a reminder of your dependent $userData["name"]\'s upcoming appointment: \nDoctor: $doctorName \nLocation: $location \nDescription: $description \nDate: $date \nTime: $time \n\nPlease ensure that you arrive on time. \nBest regards, \nMediPal : Your Own Reminder App';

              for(Map<String, dynamic> guardian in guardians){
                await twilioFlutter.sendSMS(toNumber: "+91" + guardian['phoneNo'], messageBody: msgForGuardian);
              }
              await twilioFlutter.sendSMS(toNumber: "+91" + userData['phoneNo'], messageBody: msg);

              data['status']= 'sent';

              await FirebaseFirestore.instance
              .collection('appointments')
              .doc(data['appointmentId'])
              .update(data).then((value) => print('updated'));

            }else{
              QuerySnapshot snapshots= await FirebaseFirestore.instance.collection('users').where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid.toString()).get();
              if(snapshots.docs.isNotEmpty){
                for(QueryDocumentSnapshot snapshot in snapshots.docs){
                  UserModel userModel= UserModel.fromDocumentSnapshot(snapshot);
                  userData= userModel.toMap();
                }
              }
              await twilioFlutter.sendSMS(toNumber: "+91" + userData['phoneNo'], messageBody: msg);

              data['status']= 'sent';

              await FirebaseFirestore.instance
                  .collection('appointments')
                  .doc(data['appointmentId'])
                  .update(data).then((value) => print('updated'));
            }

          }
        }
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 240, 91, 91),
        textColor: const Color.fromARGB(255, 255, 255, 255),
      );
    }
  }

  Future<void> checkFirestoreForSnooze() async{
    await Firebase.initializeApp();
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    print('goooo');

    try{
      QuerySnapshot querySnapshot = await firestore
          .collection('alarms')
          .where('userId', isEqualTo: user?.uid)
          .get();
      if(querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs){
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          var time = data['time'];
          var name = data['message'];
          var status = data['status'];
          var alarmId = data['alarmId'];

          DateTime timestamp = DateTime.parse(time);
          DateTime timestamp2 = DateTime.now();

          if (timestamp.isBefore(timestamp2) && status == 'snoozed') {
            await NotificationService.showNotification(
                title: 'Medipal',
                body: 'This is a reminder',
                payload: {
                  "open": "true",
                  "alarmId": alarmId,
                },
                actionButtons: [
                  NotificationActionButton(
                      key: 'key', label: 'Open', actionType: ActionType.Default)
                ]);
          }

        }
      }
    }catch(e){
      Fluttertoast.showToast(
        msg: 'Error retrieving documents',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 240, 91, 91),
        textColor: const Color.fromARGB(255, 255, 255, 255),
      );
    }

  }
}
