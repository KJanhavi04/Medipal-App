import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:medipal/models/AlarmModel.dart';
import 'package:medipal/models/MedicationModel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DependentMedicineFormEdit extends StatefulWidget {
  final String medicationId;
  final String dependentId;

  const DependentMedicineFormEdit(
      {super.key, required this.medicationId, required this.dependentId});

  @override
  _DependentMedicineFormEditState createState() =>
      _DependentMedicineFormEditState();
}

class _DependentMedicineFormEditState extends State<DependentMedicineFormEdit> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _reorderLevelController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  TimeOfDay? _morningTime;
  TimeOfDay? _noonTime;
  TimeOfDay? _eveningTime;

  DateTime? _startDate;
  DateTime? _endDate;

  String? _selectedDosageType; // Stores the selected dosage type

  CollectionReference medicationCollectionRef =
      FirebaseFirestore.instance.collection('medications');
  CollectionReference alarmCollectionRef =
      FirebaseFirestore.instance.collection('alarms');

  Future<Map<String, dynamic>?> loadData() async {
    final medicineSnapshots = await medicationCollectionRef
        .where('medicationId', isEqualTo: widget.medicationId)
        .get();
    for (QueryDocumentSnapshot snapshot in medicineSnapshots.docs) {
      MedicationModel medicationModel =
          MedicationModel.fromDocumentSnapshot(snapshot);
      Map<String, dynamic> medication = medicationModel.toMap();

      _nameController.text = medication['name'];
      _dosageController.text = medication['dosage'].toString();
      _quantityController.text = medication['inventory']['quantity'].toString();
      _reorderLevelController.text =
          medication['inventory']['reorderLevel'].toString();
      _descriptionController.text = medication['description'];

      DateTime startDate = DateTime.parse(medication['startDate']);
      DateTime endDate = DateTime.parse(medication['endDate']);

      final type = medication['type'];

      TimeOfDay? morning;
      TimeOfDay? noon;
      TimeOfDay? evening;

      String morningTimeString = medication['schedule']['morning'];
      if (morningTimeString.isNotEmpty) {
        List<String> morningTimeParts = morningTimeString.split(':');
        int hours = int.parse(morningTimeParts[0]);
        int minutes = int.parse(morningTimeParts[1]);

        morning = TimeOfDay(hour: hours, minute: minutes);
      } else {
        morning = null;
      }

      String noonTimeString = medication['schedule']['noon'];
      if (noonTimeString.isNotEmpty) {
        List<String> noonTimeParts = noonTimeString.split(':');
        int hours = int.parse(noonTimeParts[0]);
        int minutes = int.parse(noonTimeParts[1]);

        noon = TimeOfDay(hour: hours, minute: minutes);
      } else {
        noon = null;
      }

      String eveningTimeString = medication['schedule']['morning'];
      if (eveningTimeString.isNotEmpty) {
        List<String> eveningTimeParts = eveningTimeString.split(':');
        int hours = int.parse(eveningTimeParts[0]);
        int minutes = int.parse(eveningTimeParts[1]);

        evening = TimeOfDay(hour: hours, minute: minutes);
      } else {
        evening = null;
      }

      Map<String, dynamic> data = {
        'startDate': startDate,
        'endDate': endDate,
        'type': type,
        'medicationImg': medication['medicationImg'],
        'morning': morning,
        'noon': noon,
        'evening': evening
      };

      return data;
    }
    return null;
  }

  bool isSubmitting = false; // Track the submitting state

  //image
  File? _selectedImage; // Variable to store the selected image file

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _quantityController.dispose();
    _reorderLevelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, String timeName) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        if (timeName == 'Morning') {
          _morningTime = selectedTime;
        } else if (timeName == 'Noon') {
          _noonTime = selectedTime;
        } else if (timeName == 'Evening') {
          _eveningTime = selectedTime;
        }
      });
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        // cropImage(File(pickedImage.path));
        _selectedImage = File(pickedImage.path);
      } else {
        print('No image selected.');
      }
    });
  }

   Widget _buildLoadingIndicator() {
  return Container(
    color: Colors.white, 
    child: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.fromARGB(255, 41, 45, 92),
            ),
          ),
        ],
      ),
    ),
  );
}

  Future<String> uploadImage(File? selectedImage, String name) async {
    final userId = widget.dependentId;

    Reference storageReference =
        FirebaseStorage.instance.ref().child("medications/$userId/$name.jpg");

    // Upload the file to Firebase Storage
    UploadTask uploadTask = storageReference.putFile(selectedImage!);

    // Await the completion of the upload
    await uploadTask.whenComplete(() => print("Image uploaded"));

    // Get the download URL for the image
    String downloadURL = await storageReference.getDownloadURL();
    return downloadURL;
  }

  bool _validateTimings() {
    return _morningTime != null || _noonTime != null || _eveningTime != null;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("yyyy-MM-dd");

    // Define the dropdown items for dosage type
    final List<DropdownMenuItem<String>> dosageTypeItems = [
      const DropdownMenuItem(
        value: 'Liquid',
        child: Row(
          children: [
            ImageIcon(
              AssetImage('assets/images/liquid_icon.png'),
              // Replace 'assets/icon.png' with the path to your image
              size: 28, // Specify the size of the icon
              color:
                  Color.fromARGB(255, 0, 0, 0), // Specify the color of the icon
            ),
            SizedBox(width: 8.0),
            Text('Liquid'),
          ],
        ),
      ),
      const DropdownMenuItem(
        value: 'Pills',
        child: Row(
          children: [
            ImageIcon(
              AssetImage('assets/images/pill_icon.png'),
              // Replace 'assets/icon.png' with the path to your image
              size: 28, // Specify the size of the icon
              color:
                  Color.fromARGB(255, 0, 0, 0), // Specify the color of the icon
            ),
            SizedBox(width: 8.0),
            Text('Pills'),
          ],
        ),
      ),
      const DropdownMenuItem(
        value: 'Injection',
        child: Row(
          children: [
            ImageIcon(
              AssetImage('assets/images/injection_icon.png'),
              // Replace 'assets/icon.png' with the path to your image
              size: 28, // Specify the size of the icon
              color:
                  Color.fromARGB(255, 0, 0, 0), // Specify the color of the icon
            ),
            SizedBox(width: 8.0),
            Text('Injection'),
          ],
        ),
      ),
    ];

    return FutureBuilder(
        future: loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          } else if (snapshot.hasError) {
            // Handle the error case
            return Text('Error: ${snapshot.error}');
          } else {
            final data = snapshot.data;
            return Scaffold(
              appBar: AppBar(
                title: const Text('Medicine Form'),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Medication Details',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            //image
                            Center(
                              child: InkWell(
                                onTap: () {
                                  _getImage(); // Call the method to pick an image
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.grey[200],
                                      child: _selectedImage != null
                                          ? ClipOval(
                                        child: Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                      )
                                          : (data?['medicationImg'] != ""
                                          ? ClipOval(
                                        child: Image.network(
                                          data?['medicationImg'],
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                      )
                                          : const Icon(
                                        Icons.add_a_photo,
                                        size: 50,
                                        color: Colors.blue,
                                      )),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    const SizedBox(height: 8),
                                    // Add some space between image and text
                                    Text(
                                      _selectedImage != null
                                          ? 'Change Image'
                                          : 'Select Image for Your Medicine',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        // You can adjust the color as needed
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //image end
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Medication Name',
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
                              decoration: const InputDecoration(
                                labelText: 'Dosage Description',
                              ),
                              controller: _descriptionController,
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
                            DropdownButtonFormField(
                              value: _selectedDosageType ?? data?['type'],
                              decoration: const InputDecoration(
                                labelText: 'Type of Dosage',
                              ),
                              items: dosageTypeItems,
                              onChanged: (value) {
                                setState(() {
                                  _selectedDosageType = value as String?;
                                });
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.toString().trim().isEmpty) {
                                  return '*Required';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: _dosageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Quantity Per Dose',
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
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Inventory Quantity',
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
                              controller: _reorderLevelController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Reorder Level',
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
                            const Text(
                              'Medication Duration',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DateTimeField(
                              format: dateFormat,
                              initialValue: _startDate ?? data?['startDate'],
                              decoration: const InputDecoration(
                                labelText: 'Start Date',
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.toString().trim().isEmpty) {
                                  return '*Required';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _startDate = value;
                                });
                              },
                              onShowPicker: (context, currentValue) async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate ??
                                      data?['startDate'] ??
                                      DateTime.now(),
                                  firstDate: _startDate ??
                                      data?['startDate'] ??
                                      DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                return date;
                              },
                            ),
                            DateTimeField(
                              format: dateFormat,
                              initialValue: _endDate ?? data?['endDate'],
                              decoration: const InputDecoration(
                                labelText: 'End Date',
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.toString().trim().isEmpty) {
                                  return '*Required';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _endDate = value;
                                });
                              },
                              onShowPicker: (context, currentValue) async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate ??
                                      data?['endDate'] ??
                                      DateTime.now(),
                                  firstDate: _endDate ??
                                      data?['endDate'] ??
                                      DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                return date;
                              },
                            ),

                            const SizedBox(height: 16.0),
                            const Text(
                              'Medication Schedule',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            CheckboxListTile(
                              title: const Text('Morning'),
                              value: _morningTime != null,
                              onChanged: (bool? value) {
                                if (value!) {
                                  _selectTime(context, 'Morning');
                                } else {
                                  setState(() {
                                    _morningTime = null;
                                  });
                                }
                              },
                            ),
                            if (_morningTime != null)
                              Text(
                                  'Selected Morning Time: ${_morningTime!.format(context)}'),
                            CheckboxListTile(
                              title: const Text('Noon'),
                              value: _noonTime != null,
                              onChanged: (bool? value) {
                                if (value!) {
                                  _selectTime(context, 'Noon');
                                } else {
                                  setState(() {
                                    _noonTime = null;
                                  });
                                }
                              },
                            ),
                            if (_noonTime != null)
                              Text(
                                  'Selected Noon Time: ${_noonTime!.format(context)}'),
                            CheckboxListTile(
                              title: const Text('Evening'),
                              value: _eveningTime != null,
                              onChanged: (bool? value) {
                                if (value!) {
                                  _selectTime(context, 'Evening');
                                } else {
                                  setState(() {
                                    _eveningTime = null;
                                  });
                                }
                              },
                            ),
                            if (_eveningTime != null)
                              Text(
                                  'Selected Evening Time: ${_eveningTime!.format(context)}'),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () async {

                                if(_formKey.currentState!.validate()){
                                  if(!_validateTimings()){
                                    Fluttertoast.showToast(
                                      msg: 'Please select at least one timing.',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                    return;
                                  }
                                  // Set the submitting state to true
                                  setState(() {
                                    isSubmitting = true;
                                  });

                                  String imageUrl;

                                  if (_selectedImage != null) {
                                    imageUrl = await uploadImage(
                                        _selectedImage, _nameController.text);
                                  } else if (data?['medicationImg'] != null) {
                                    imageUrl = data?['medicationImg'];
                                  } else {
                                    imageUrl = '';
                                  }
                                  MedicationModel medication = MedicationModel(
                                    medicationId: widget.medicationId,
                                    name: _nameController.text,
                                    type: _selectedDosageType ?? data?['type'],
                                    dosage: int.parse(_dosageController.text),
                                    schedule: {
                                      'morning': _morningTime != null
                                          ? _morningTime!.format(context)
                                          : '',
                                      'noon': _noonTime != null
                                          ? _noonTime!.format(context)
                                          : '',
                                      'evening': _eveningTime != null
                                          ? _eveningTime!.format(context)
                                          : '',
                                    },
                                    inventory: {
                                      'quantity':
                                      int.tryParse(_quantityController.text) ??
                                          0,
                                      'reorderLevel': int.tryParse(
                                          _reorderLevelController.text) ??
                                          0,
                                    },
                                    startDate: _startDate != null
                                        ? dateFormat.format(_startDate!)
                                        : dateFormat
                                        .format(data?['startDate'])
                                        .toString() ??
                                        "",
                                    endDate: _endDate != null
                                        ? dateFormat.format(_endDate!)
                                        : dateFormat
                                        .format(data?['endDate'])
                                        .toString() ??
                                        "",
                                    userId: widget.dependentId,
                                    description: _descriptionController.text,
                                    medicationImg: imageUrl,
                                  );

                                  Map<String, dynamic> medicationModel =
                                  medication.toMap();

                                  await FirebaseFirestore.instance
                                      .collection('medications')
                                      .doc(medicationModel['medicationId'])
                                      .set(medicationModel)
                                      .then((value) async {
                                    //delete existing alarms
                                    final snapshots = await FirebaseFirestore
                                        .instance
                                        .collection('alarms')
                                        .where('medicationId',
                                        isEqualTo:
                                        medicationModel['medicationId'])
                                        .get();
                                    for (final doc in snapshots.docs) {
                                      await doc.reference.delete();
                                    }

                                    for (var date =
                                        _startDate ?? data?['startDate'];
                                    date!.isBefore(_endDate ??
                                        data?['endDate']!
                                            .add(const Duration(days: 1)));
                                    date = date.add(const Duration(days: 1))) {
                                      for (var key in medication.schedule.keys) {
                                        final value = medication.schedule[key];
                                        if (value != null && value.isNotEmpty) {
                                          final hrMin = value.split(' ');
                                          final timeParts = hrMin[0].split(':');
                                          final hr = int.tryParse(timeParts[0]);
                                          final min = int.tryParse(timeParts[1]);
                                          if (hr != null && min != null) {
                                            DateTime dateTime = DateTime(date.year,
                                                date.month, date.day, hr, min);

                                            DocumentReference
                                            alarmDocumentReference =
                                            alarmCollectionRef.doc();

                                            String medicineName =
                                                _nameController.text;
                                            String message = _dosageController.text;

                                            AlarmModel alarmModel = AlarmModel(
                                                alarmId: alarmDocumentReference.id,
                                                skipReason: '',
                                                userId: widget.dependentId,
                                                time: dateTime.toString(),
                                                status: 'pending',
                                                medicationId: medicationModel[
                                                'medicationId']);

                                            Map<String, dynamic> alarm =
                                            alarmModel.toMap();
                                            await alarmDocumentReference.set(alarm);
                                          }
                                        }
                                      }
                                    }
                                  });

                                  // Show the toast message
                                  Fluttertoast.showToast(
                                    msg: 'Medicine Updated successfully!',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor:
                                    const Color.fromARGB(255, 48, 48, 48),
                                    textColor: Colors.white,
                                  );

                                  // Set the submitting state back to false
                                  setState(() {
                                    isSubmitting = false;
                                  });

                                  Navigator.pop(context);
                                }

                              },
                              child: const Text('Submit'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ),
              ),
              bottomNavigationBar:
                  isSubmitting ? _buildLoadingIndicator() : null,
            );
          }
        });
  }
}
