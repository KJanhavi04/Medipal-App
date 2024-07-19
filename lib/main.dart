import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:medipal/Individual/bottom_navigation_individual.dart';
import 'package:medipal/credentials/firebase_cred.dart';
import 'package:medipal/credentials/twilio_cred.dart';
import 'package:medipal/notification/notification_service.dart';
import 'package:medipal/premium.dart';
import 'package:medipal/user_registration/choose_screen.dart';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:medipal/notification/FirestoreCheck.dart';

import 'Dependent/bottom_navigation_dependent.dart';

Future<void> checkFirestoreTask() async {
  FireStoreCheck check = new FireStoreCheck();
  await check.checkFirestore();
}

Future<void> checkFirestoreForSnooze() async {
  FireStoreCheck check = new FireStoreCheck();
  await check.checkFirestoreForSnooze();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  await NotificationService.initializeNotification();

  await AndroidAlarmManager.initialize();

  const int helloAlarmID = 0;
  await AndroidAlarmManager.periodic(
      const Duration(minutes: 1), helloAlarmID, checkFirestoreTask);

  const int snoozeAlarmID = 1;
  await AndroidAlarmManager.periodic(
      const Duration(minutes: 5), snoozeAlarmID, checkFirestoreForSnooze);

  TwilioCred().writeCred();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'MediPal',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(
              255, 241, 239, 239), // Set the app bar background color to white
          iconTheme:
              IconThemeData(color: Colors.black), // Set the icon color to black
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ), // Set the title text color to black
          //centerTitle: true, // Center the title within the app bar
          toolbarHeight: 60, // Set the height of the app bar
        ),
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 41, 45, 92)),
        // appBarTheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 0, 0)),
        //useMaterial3: true,
      ),
      home: MyHomePage(),
      //  const BottomNavigationDependent(),
      // AddGuardian(),
      //AlarmScreen(),
    );
    // return MaterialApp(
    //   home: PremiumScreen(),
    // );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/medipal_splash.png',
              width: 400,
              height: 400,
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    var userRole;
    var user;

    FirebaseCred().getData().then((value) {
      user = value[0];
      userRole = value[1];
      Timer(const Duration(seconds: 2), () {
        if (user != null) {
          if (userRole == 'Individual') {
            navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const BottomNavigationIndividual()),
            );
          } else if (userRole == 'Guardian') {
            navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
                builder: (context) => const BottomNavigationIndividual()));
          } else {
            navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const BottomNavigationDependent()),
            );
          }
        } else {
          navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(builder: (context) => const ChooseScreen()));
        }
      });
    });
  }
}
