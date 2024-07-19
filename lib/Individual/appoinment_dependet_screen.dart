import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:medipal/models/AppointmentModel.dart';
import 'package:fluttertoast/fluttertoast.dart';

FirebaseFirestore user = FirebaseFirestore.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

class AppointmentGaurdianScreen extends StatefulWidget {
  final dependentId;
  const AppointmentGaurdianScreen({super.key, required this.dependentId});

  @override
  _AppointmentGaurdianScreenState createState() =>
      _AppointmentGaurdianScreenState();
}

class _AppointmentGaurdianScreenState extends State<AppointmentGaurdianScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<List<QueryDocumentSnapshot>?> fetchData() async {
    final appointQuery = firestore
        .collection('appointments')
        .where('userId', isEqualTo: widget.dependentId)
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

  TextEditingController doctorNameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  void _showEditDialog(String id, String name, String date, String time,
      String location, String description) {
    doctorNameController.text = name;
    locationController.text = location;
    descriptionController.text = description;

    final inputDateFormat = DateFormat('dd MMM yyyy');
    DateTime inputDate = inputDateFormat.parse(date);

    final outputDateFormat = DateFormat('yyyy-MM-dd');
    String formattedDate = outputDateFormat.format(inputDate);

    dateController.text = formattedDate;

    DateTime initialdate = DateTime.parse(formattedDate);
    DateTime firstDate;

    if (initialdate.isBefore(DateTime.now())) {
      firstDate = initialdate;
    } else {
      firstDate = DateTime.now();
    }

    final inputTimeFormat = DateFormat('HH:mm');
    DateTime inputTime = inputTimeFormat.parse(time);

    final outputFormat = DateFormat('HH:mm:ss');
    String formattedTime = outputFormat.format(inputTime);

    DateTime initialTime = DateTime.parse("$formattedDate $formattedTime");

    timeController.text = time;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Appointment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: doctorNameController,
                  decoration:
                      const InputDecoration(labelText: 'Doctor\'s Name'),
                ),
                SizedBox(height: 12.0),
                TextField(
                  readOnly: true,
                  controller: dateController,
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: initialdate,
                      firstDate: firstDate,
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        dateController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Date',
                    suffixIcon: IconButton(
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: initialdate,
                          firstDate: firstDate,
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            dateController.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          });
                        }
                      },
                      icon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                SizedBox(height: 12.0),
                TextField(
                  readOnly: true,
                  controller: timeController,
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(initialTime),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        timeController.text = pickedTime.format(context);
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Time',
                    suffixIcon: IconButton(
                      onPressed: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(initialTime),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            timeController.text = pickedTime.format(context);
                          });
                        }
                      },
                      icon: Icon(Icons.access_time),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: () async {
                        Map<String, dynamic> appointment = {
                          'doctorName': doctorNameController.text,
                          'appointmentTime': dateController.text +
                              " " +
                              timeController.text +
                              ':00',
                          'location': locationController.text,
                          'description': descriptionController.text,
                        };

                        await firestore
                            .collection('appointments')
                            .doc(id)
                            .update(appointment)
                            .then(
                              (value) => Fluttertoast.showToast(
                                msg: 'Appointment updated',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor:
                                    const Color.fromARGB(206, 2, 191, 34),
                                textColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                              ),
                            );

                        Navigator.pop(context);
                        setState(() {});
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Appointment'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to delete this appointment?'),
              Text(
                'Note: Deleting this appointment will also delete the associated alarms.',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await firestore
                    .collection('appointments')
                    .doc(id)
                    .delete()
                    .then((value) async {
                  Fluttertoast.showToast(
                    msg: 'Appointment deleted!',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: const Color.fromARGB(206, 2, 191, 34),
                    textColor: const Color.fromARGB(255, 255, 255, 255),
                  );
                });

                Navigator.pop(context);

                // Refresh the page after data is deleted
                setState(() {});
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                ButtonBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: Color.fromARGB(255, 120, 120, 120),
                      onPressed: () {
                        // Open the edit dialog when the edit button is pressed
                        _showEditDialog(appointmentId, name, date, time,
                            location, description);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Color.fromARGB(255, 120, 120, 120),
                      onPressed: () {
                        _showDeleteDialog(appointmentId);
                      },
                    ),
                  ],
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
