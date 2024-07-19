import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medipal/Individual/bottom_navigation_individual.dart';
import 'package:medipal/models/AppointmentModel.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppointmentForm extends StatefulWidget {
  const AppointmentForm({super.key});

  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _doctorNameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _doctorNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("yyyy-MM-dd");
    final timeFormat = DateFormat("HH:mm");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _doctorNameController,
                    decoration: const InputDecoration(
                      labelText: 'Doctor\'s Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.toString().trim().isEmpty) {
                        return '*Required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  GestureDetector(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: _selectedDate != null
                            ? TextEditingController(
                                text: dateFormat.format(_selectedDate!))
                            : null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '*Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  GestureDetector(
                    onTap: () {
                      _selectTime(context);
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        controller: _selectedTime != null
                            ? TextEditingController(
                                text: timeFormat.format(DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  _selectedTime!.hour,
                                  _selectedTime!.minute,
                                )),
                              )
                            : null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '*Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.toString().trim().isEmpty) {
                        return '*Required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.toString().trim().isEmpty) {
                        return '*Required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 42.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          DocumentReference documentReference =
                              FirebaseFirestore.instance
                                  .collection('appointments')
                                  .doc();

                          DateTime combinedDateTime = DateTime(
                            _selectedDate!.year,
                            _selectedDate!.month,
                            _selectedDate!.day,
                            _selectedTime!.hour,
                            _selectedTime!.minute,
                          );

                          String formattedDateTime =
                              DateFormat('yyyy-MM-dd HH:mm:ss')
                                  .format(combinedDateTime);

                          AppointmentModel appointmentModel = AppointmentModel(
                              userId: FirebaseAuth.instance.currentUser!.uid
                                  .toString(),
                              appointmentId: documentReference.id,
                              doctorName: _doctorNameController.text,
                              location: _locationController.text,
                              status: 'pending',
                              appointmentTime: formattedDateTime,
                              description: _descriptionController.text);

                          documentReference
                              .set(appointmentModel.toMap())
                              .then((value) => print('done'));

                          Fluttertoast.showToast(
                            msg: 'Appoinmnet Scheduled successfully!',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor:
                                const Color.fromARGB(255, 48, 48, 48),
                            textColor: Colors.white,
                          );

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const BottomNavigationIndividual()),
                            (Route<dynamic> route) => false,
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: 'Please fill in all required fields.',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        onPrimary: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 34, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
