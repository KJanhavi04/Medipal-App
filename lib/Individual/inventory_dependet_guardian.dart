import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medipal/Individual/edit_medicine_depedent_form.dart';
import 'package:medipal/models/MedicationModel.dart';
import 'package:fluttertoast/fluttertoast.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class InventoryDependentGuardian extends StatefulWidget {
  final dependentId;

  InventoryDependentGuardian({required this.dependentId});

  @override
  _InventoryDependentGuardian createState() => _InventoryDependentGuardian();
}

class _InventoryDependentGuardian extends State<InventoryDependentGuardian> {
  @override
  void initState() {
    super.initState();
  }

  Future<List<QueryDocumentSnapshot>?> fetchData() async {
    final medicationQuery = firestore
        .collection('medications')
        .where('userId', isEqualTo: widget.dependentId)
        .get();

    List<QueryDocumentSnapshot> medicationDocumentList = [];

    try {
      final results = await Future.wait([medicationQuery]);
      final medicationQuerySnapshot = results[0];

      if (medicationQuerySnapshot.docs.isNotEmpty) {
        medicationDocumentList = medicationQuerySnapshot.docs.toList();
      }
      return medicationDocumentList;
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

  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController dosageController = TextEditingController();

  // Function to open a confirmation dialog for deleting a specific item
  void _openDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to delete this medication?'),
              Text(
                'Note: Deleting this medication will also delete all associated alarms.',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                firestore
                    .collection('medications')
                    .doc(id)
                    .delete()
                    .then((value) async {
                  final snapshots = await firestore
                      .collection('alarms')
                      .where('medicationId', isEqualTo: id)
                      .get();
                  for (final doc in snapshots.docs) {
                    await doc.reference.delete();
                  }
                });

                Navigator.pop(context);
                // Refresh the page after data is deleted
                setState(() {});
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
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
                return _buildLoadingIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final medicationQuery = snapshot.data;
                return _buildInventoryCard(medicationQuery!);
              }
            },
          ))
        ],
      ), // Create the inventory list view
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

  Widget _buildInventoryCard(
      List<QueryDocumentSnapshot> medicationQuerySnapshot) {
    return ListView.builder(
        itemCount: medicationQuerySnapshot.length,
        itemBuilder: (BuildContext context, int index) {
          final QueryDocumentSnapshot medicationDocumentSnapshot =
              medicationQuerySnapshot[index];
          final MedicationModel medicationModel =
              MedicationModel.fromDocumentSnapshot(medicationDocumentSnapshot);
          final Map<String, dynamic> medication = medicationModel.toMap();
          final name = medication['name'];
          final type = medication['type'];
          final medicationId = medication['medicationId'];
          final dosage = medication['dosage'];
          final quantity = medication['inventory']['quantity'];

          String img;

          if (medication['medicationImg'] == '') {
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
            img = medication['medicationImg'];
          }

          Widget Imgbuild(BuildContext context) {
            double width = 80.0;
            double height = 80.0;
            String defaultImage = 'assets/images/default.png';
            EdgeInsetsGeometry margins =
                const EdgeInsets.only(right: 14, left: 12);

            if (medication['medicationImg'] == '') {
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
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
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
              String img = medication['medicationImg'];
              return FutureBuilder(
                future: precacheImage(NetworkImage(img), context),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
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

          // Add this in UI
          final recorder = medication['inventory']['recorderLevel'];

          return Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Imgbuild(context),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1, color: Colors.grey),
                      // Vertical line
                      const SizedBox(height: 8),
                      // For this, make sure we have type in medicine form
                      Text('Type: $type'),
                      Text('Quantity: $quantity'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Open the edit dialog when the edit button is pressed
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DependentMedicineFormEdit(
                                    medicationId: medicationId,
                                    dependentId: widget.dependentId,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // Open the delete confirmation dialog when the delete button is pressed
                              _openDeleteDialog(medicationId);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
