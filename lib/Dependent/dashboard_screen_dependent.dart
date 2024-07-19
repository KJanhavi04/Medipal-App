import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medipal/models/AlarmModel.dart';
import 'package:medipal/models/MedicationModel.dart';
import 'package:fluttertoast/fluttertoast.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
final userId = auth.currentUser?.uid;

class DashboardScreenDependent extends StatefulWidget {
  const DashboardScreenDependent({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreenDependent> {
  List<QueryDocumentSnapshot> filteredAlarms = [];
  Future<List<List<QueryDocumentSnapshot>>?> fetchData() async {
    final alarmQuery =
        firestore.collection('alarms').where('userId', isEqualTo: userId).get();
    final medicationQuery = firestore
        .collection('medications')
        .where('userId', isEqualTo: userId)
        .get();

    List<QueryDocumentSnapshot> alarmDocumentList = [];
    List<QueryDocumentSnapshot> medicationDocumentList = [];

    try {
      final results = await Future.wait([alarmQuery, medicationQuery]);
      final alarmQuerySnapshot = results[0];
      final medicationQuerySnapshot = results[1];

      if (alarmQuerySnapshot.docs.isNotEmpty) {
        alarmDocumentList = alarmQuerySnapshot.docs.toList();
      }

      if (medicationQuerySnapshot.docs.isNotEmpty) {
        medicationDocumentList = medicationQuerySnapshot.docs.toList();
      }

      return [alarmDocumentList, medicationDocumentList];
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Error retrieving documents',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 240, 91, 91),
        textColor: const Color.fromARGB(255, 255, 255, 255),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/medipal.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text('MediPal'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Column(
          children: [
            _buildCalendar(context),
            const Divider(),
            Expanded(
              child: FutureBuilder(
                  future: fetchData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final alarmQuerySnapshot = snapshot.data![0];
                      final medicineQuerySnapshot = snapshot.data![1];
                      return _buildDynamicCards(
                          filteredAlarms.isEmpty
                              ? alarmQuerySnapshot
                              : filteredAlarms,
                          medicineQuerySnapshot);
                    }
                  }),
            ),
          ],
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
              Color.fromARGB(255, 71, 78, 84),
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    return FutureBuilder(
      future: fetchData(),
      builder: (BuildContext context,
          AsyncSnapshot<List<List<QueryDocumentSnapshot>>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        } else if (snapshot.hasError || snapshot.data == null) {
          return Text('Error: ${snapshot.error}');
        } else {
          final alarmQuerySnapshot = snapshot.data![0];
          return SizedBox(
            height: 100,
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    itemBuilder: (BuildContext context, int index) {
                      final currentDate =
                          DateTime.now().add(Duration(days: index));
                      final dayName = DateFormat('E').format(currentDate);
                      final dayOfMonth = currentDate.day.toString();

                      return GestureDetector(
                        onTap: () {
                          _onDateTapped(currentDate, alarmQuerySnapshot);
                        },
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromARGB(255, 41, 45, 92),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                dayOfMonth,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(dayName),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    _openCalendar(context, alarmQuerySnapshot);
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }

  void _openCalendar(BuildContext context,
      List<QueryDocumentSnapshot> alarmQuerySnapshot) async {
    final DateTime currentDate = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate.subtract(const Duration(days: 365)),
      lastDate: currentDate.add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      _onDateTapped(selectedDate, alarmQuerySnapshot);
    }
  }

  void _onDateTapped(
      DateTime currentDate, List<QueryDocumentSnapshot> alarmQuerySnapshot) {
    final List<QueryDocumentSnapshot> alarmFilteredSnapshot =
        alarmQuerySnapshot.where((element) {
      final Map<String, dynamic>? data =
          element.data() as Map<String, dynamic>?;
      if (data != null) {
        final String? date = data['time']?.toString().split(' ')[0];

        return date == currentDate.toString().split(' ')[0];
      } else {
        return false;
      }
    }).toList();

    setState(() {
      filteredAlarms = alarmFilteredSnapshot;
    });

    if (filteredAlarms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No alarms scheduled for this day.'),
        ),
      );
    }
  }

  Widget _buildDynamicCards(List<QueryDocumentSnapshot> alarmQuerySnapshot,
      List<QueryDocumentSnapshot> medicineQuerySnapshot) {
    if (filteredAlarms.isEmpty) {
      DateTime currentDate = DateTime.now();
      alarmQuerySnapshot = alarmQuerySnapshot.where((element) {
        DateTime alarmTime = DateTime.parse(element['time']);
        return alarmTime.isAfter(currentDate);
      }).toList();
    }

    //sorting
    alarmQuerySnapshot.sort((a, b) {
      final DateTime timeA = DateTime.parse(a['time']);
      final DateTime timeB = DateTime.parse(b['time']);
      return timeA.compareTo(timeB);
    });

    return ListView.builder(
        itemCount: alarmQuerySnapshot.length,
        itemBuilder: (BuildContext context, int index) {
          final QueryDocumentSnapshot alarmDocumentSnapshot =
              alarmQuerySnapshot[index];

          final AlarmModel alarmModel =
              AlarmModel.fromDocumentSnapshot(alarmDocumentSnapshot);
          final Map<String, dynamic> alarm = alarmModel.toMap();
          final String medicationId = alarm['medicationId'];

          if (medicineQuerySnapshot.isNotEmpty) {
            QueryDocumentSnapshot medicationDocument =
                medicineQuerySnapshot.firstWhere(
                    (element) => element['medicationId'] == medicationId,
                    orElse: null);

            final MedicationModel medicationModel =
                MedicationModel.fromDocumentSnapshot(medicationDocument);
            final Map<String, dynamic> medicine = medicationModel.toMap();
            final String name = medicine['name'];
            final String time = alarm['time'];
            final int quantity = medicine['dosage'];
            final String type = medicine['type'];

            String img;

            if (medicine['medicationImg'] == '') {
              if (type == 'Pills') {
                img =
                    'https://firebasestorage.googleapis.com/v0/b/medipal-61348.appspot.com/o/medication_icons%2Fpill_icon.png?alt=media&token=8967025a-597f-4d82-8b39-d705e2e051b4';
              } else if (type == 'Liquid') {
                img =
                    'https://firebasestorage.googleapis.com/v0/b/medipal-61348.appspot.com/o/medication_icons%2Fliquid_icon.png?alt=media&token=0541a72d-b74c-439e-8d40-2851bbc421aa';
              } else {
                img =
                    'https://firebasestorage.googleapis.com/v0/b/medipal-61348.appspot.com/o/medication_icons%2Finjection_icon.png?alt=media&token=95b4de3d-4cc3-41c1-b254-f4552d5d4545';
              }
            } else {
              img = medicine['medicationImg'];
            }
            Widget Imgbuild(BuildContext context) {
              double width = 80.0;
              double height = 80.0;
              String defaultImage = 'assets/images/default.png';
              EdgeInsetsGeometry margins =
                  const EdgeInsets.only(right: 14, left: 12);

              if (medicine['medicationImg'] == '') {
                String img;

                if (type == 'Pills') {
                  img =
                      'https://firebasestorage.googleapis.com/v0/b/medipal-61348.appspot.com/o/medication_icons%2Fpill_icon.png?alt=media&token=8967025a-597f-4d82-8b39-d705e2e051b4';
                } else if (type == 'Liquid') {
                  img =
                      'https://firebasestorage.googleapis.com/v0/b/medipal-61348.appspot.com/o/medication_icons%2Fliquid_icon.png?alt=media&token=0541a72d-b74c-439e-8d40-2851bbc421aa';
                } else {
                  img =
                      'https://firebasestorage.googleapis.com/v0/b/medipal-61348.appspot.com/o/medication_icons%2Finjection_icon.png?alt=media&token=95b4de3d-4cc3-41c1-b254-f4552d5d4545';
                }

                return FutureBuilder(
                  future: precacheImage(NetworkImage(img), context),
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      width = 64.0;
                      height = 64.0;
                      return Padding(
                        padding: margins,
                        child: Image(image: NetworkImage(img)),
                      );
                    } else {
                      return Image.asset(
                        defaultImage,
                        width: width,
                        height: height,
                        fit: BoxFit.fitWidth,
                      );
                    }
                  },
                );
              } else {
                String img = medicine['medicationImg'];
                return FutureBuilder(
                  future: precacheImage(NetworkImage(img), context),
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Container(
                        width: width,
                        height: height,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fitWidth,
                            image: NetworkImage(img),
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        width: width,
                        height: height,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fitWidth,
                            image: AssetImage(defaultImage),
                          ),
                        ),
                      );
                    }
                  },
                );
              }
            }

            DateTime dateTime = DateTime.parse(time);

            // Format the date portion of the timestamp as "day month" (e.g., "21 Sept")
            String formattedDate = DateFormat('d MMM').format(dateTime);

            // Format the time portion of the timestamp as "H:mm" (e.g., "9:00")
            String formattedTime = DateFormat.Hm().format(dateTime);

            String dateTimeText = '$formattedDate | $formattedTime';
            return Card(
              margin: const EdgeInsets.all(8),
              child: InkWell(
                onTap: () {
                  _showAlarmDetailsDialog(
                      context, alarm, medicineQuerySnapshot);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        dateTimeText,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Colors.grey),
                    ListTile(
                      leading: Imgbuild(context), //image n/w
                      title: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('Quantity: $quantity'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Card(
              margin: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Medication not found',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  void _showAlarmDetailsDialog(
    BuildContext context,
    Map<String, dynamic> alarm,
    List<QueryDocumentSnapshot> medicineQuerySnapshot,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final String medicationId = alarm['medicationId'];
        final medicationDocument = medicineQuerySnapshot.firstWhere(
          (element) => element['medicationId'] == medicationId,
        );

        QueryDocumentSnapshot? medicationDocumentSnapshot;

        if (medicationDocument != null &&
            medicationDocument is QueryDocumentSnapshot) {
          medicationDocumentSnapshot =
              medicationDocument as QueryDocumentSnapshot;
        }

        if (medicationDocumentSnapshot != null) {
          final MedicationModel medicationModel =
              MedicationModel.fromDocumentSnapshot(medicationDocumentSnapshot);
          final Map<String, dynamic> medicine = medicationModel.toMap();

          return AlertDialog(
            title: Text(_getFormattedDateTime(alarm['time'])),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Name', medicine['name'] ?? 'N/A'),
                _buildInfoRow(
                    'Quantity', medicine['dosage']?.toString() ?? 'N/A'),
                _buildInfoRow('Description', medicine['description'] ?? 'N/A'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: Text('Medication not found'),
            content: const Text('No details available'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        }
      },
    );
  }

  String _getFormattedDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);

    String formattedDate = DateFormat('d MMM yyyy').format(dateTime);
    String formattedTime = DateFormat.Hm().format(dateTime);

    return '$formattedDate | $formattedTime';
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
