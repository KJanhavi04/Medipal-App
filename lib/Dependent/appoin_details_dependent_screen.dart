import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medipal/models/AppointmentModel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
final userId = auth.currentUser?.uid;

class AppointmentDependentScreen extends StatefulWidget {
  const AppointmentDependentScreen({super.key});

  @override
  _AppointmentDependentScreenState createState() =>
      _AppointmentDependentScreenState();
}

class _AppointmentDependentScreenState
    extends State<AppointmentDependentScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<List<QueryDocumentSnapshot>?> fetchData() async {
    final appointQuery = firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .get();

    List<QueryDocumentSnapshot> appointmentDocumentList = [];

    try {
      final results = await Future.wait([appointQuery]);
      final appointQuerySnapshot = results[0];

      if (appointQuerySnapshot.docs.isNotEmpty) {
        appointmentDocumentList = appointQuerySnapshot.docs.toList();
      }
      return appointmentDocumentList;
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Error retrieving documents',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 240, 91, 91),
        textColor: const Color.fromARGB(255, 255, 255, 255),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Appointments'),
        ),
        body: Column(
          children: [
            Expanded(
                child: FutureBuilder(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  print("Loading...");
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final appointmentQuery = snapshot.data;
                  return _buildAppointmentCard(appointmentQuery!);
                }
              },
            ))
          ],
        ));
  }

  Widget _buildAppointmentCard(
      List<QueryDocumentSnapshot> appointmentQuerySnapshot) {
    return ListView.builder(
      itemCount: appointmentQuerySnapshot.length,
      itemBuilder: (BuildContext context, int index) {
        final QueryDocumentSnapshot appointmentDocumentSnapshot =
            appointmentQuerySnapshot[index];
        final AppointmentModel appointmentModel =
            AppointmentModel.fromDocumentSnapshot(appointmentDocumentSnapshot);
        final Map<String, dynamic> appointment = appointmentModel.toMap();
        final appointmentId = appointment['appointmentId'];
        final name = appointment['doctorName'];
        final String appointmentTimeString = appointment['appointmentTime'];
        final DateTime appointmentDateTime =
            DateTime.parse(appointmentTimeString);

        final date = DateFormat('d MMM yyyy').format(appointmentDateTime);
        final time = DateFormat.Hm().format(appointmentDateTime);
        final location = appointment['location'];
        final description = appointment['description'];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Date', date),
                      _buildInfoRow('Time', time),
                      _buildInfoRow('Location', location),
                      _buildInfoRow('Description', description),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
