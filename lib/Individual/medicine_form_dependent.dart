import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:medipal/models/AlarmModel.dart';
import 'package:medipal/models/MedicationModel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MedicineFormDependent extends StatefulWidget {
  final dependentId;

  MedicineFormDependent({required this.dependentId});

  @override
  _MedicineFormDependentState createState() => _MedicineFormDependentState();
}

class _MedicineFormDependentState extends State<MedicineFormDependent> {

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
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false; // Add this to control the loading indicator

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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("yyyy-MM-dd");

    // Define the dropdown items for dosage type
    final List<DropdownMenuItem<String>> dosageTypeItems = [
      const DropdownMenuItem(
        value: 'Pills',
        child: Row(
          children: [
            ImageIcon(
              AssetImage('assets/images/pill_icon.png'),
              size: 28,
              color: Color.fromARGB(255, 0, 0, 0),
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
              size: 28,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            SizedBox(width: 8.0),
            Text('Injection'),
          ],
        ),
      ),
      const DropdownMenuItem(
        value: 'Liquid',
        child: Row(
          children: [
            ImageIcon(
              AssetImage('assets/images/liquid_icon.png'),
              size: 28,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            SizedBox(width: 8.0),
            Text('Liquid'),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Form'),
      ),
      body: isLoading
          ? _buildLoadingIndicator()
          : SingleChildScrollView(
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
                          Center(
                            child: InkWell(
                              onTap: () {
                                _getImage(); // Call the method to pick an image
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _selectedImage != null
                                      ? Image.file(_selectedImage!)
                                      : Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.add_a_photo),
                                  ),
                                  const SizedBox(
                                      height: 8), // Add some space between image and text
                                  Text(
                                    _selectedImage != null
                                        ? 'Change Image'
                                        : 'Select Image for Your Medicine',
                                    style: const TextStyle(
                                      color: Colors
                                          .blue, // You can adjust the color as needed
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                            value: _selectedDosageType,
                            decoration: const InputDecoration(
                              labelText: 'Type of Dosage',
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.toString().trim().isEmpty) {
                                return '*Required';
                              }
                              return null;
                            },
                            items: dosageTypeItems,
                            onChanged: (value) {
                              setState(() {
                                _selectedDosageType = value;
                              });
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
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _startDate = value;
                              });
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.toString().trim().isEmpty) {
                                return '*Required';
                              }
                              return null;
                            },
                            onShowPicker: (context, currentValue) async {
                              final date = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2000),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(2101),
                              );
                              return date;
                            },
                          ),
                          DateTimeField(
                            format: dateFormat,
                            decoration: const InputDecoration(
                              labelText: 'End Date',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _endDate = value;
                              });
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.toString().trim().isEmpty) {
                                return '*Required';
                              }
                              return null;
                            },
                            onShowPicker: (context, currentValue) async {
                              final date = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2000),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(2101),
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
                              // Set isLoading to true before performing async tasks

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
                                setState(() {
                                  isLoading = true;
                                });

                                DocumentReference medicationDocumentReference =
                                medicationCollectionRef.doc();

                                String imageUrl;

                                if (_selectedImage != null) {
                                  imageUrl = await uploadImage(
                                      _selectedImage, _nameController.text);
                                } else {
                                  imageUrl = '';
                                }

                                MedicationModel medication = MedicationModel(
                                  medicationId: medicationDocumentReference.id,
                                  name: _nameController.text,
                                  type: _selectedDosageType.toString(),
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
                                    int.tryParse(_quantityController.text) ?? 0,
                                    'reorderLevel': int.tryParse(
                                        _reorderLevelController.text) ??
                                        0,
                                  },
                                  startDate: _startDate != null
                                      ? dateFormat.format(_startDate!)
                                      : "",
                                  endDate: _endDate != null
                                      ? dateFormat.format(_endDate!)
                                      : "",
                                  userId: widget.dependentId,
                                  description: _descriptionController.text,
                                  medicationImg: imageUrl,
                                );

                                Map<String, dynamic> medicationModel =
                                medication.toMap();

                                await medicationDocumentReference
                                    .set(medicationModel);

                                for (var date = _startDate;
                                date!.isBefore(
                                    _endDate!.add(const Duration(days: 1)));
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
                                        DocumentReference alarmDocumentReference =
                                        alarmCollectionRef.doc();
                                        String medicineName = _nameController.text;
                                        String message = _dosageController.text;
                                        AlarmModel alarmModel = AlarmModel(
                                            alarmId: alarmDocumentReference.id,
                                            skipReason: '',
                                            userId: widget.dependentId,
                                            time: dateTime.toString(),
                                            status: 'pending',
                                            medicationId:
                                            medicationDocumentReference.id);

                                        Map<String, dynamic> alarm =
                                        alarmModel.toMap();
                                        await alarmDocumentReference.set(alarm);
                                      }
                                    }
                                  }
                                }

                                // Set isLoading back to false
                                setState(() {
                                  isLoading = false;
                                });

                                // Show the toast message
                                Fluttertoast.showToast(
                                  msg: 'Medicine added successfully!',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                );
                                Navigator.pop(context,
                                    medication); // Pass data back to the home screen
                              }else{
                                Fluttertoast.showToast(
                                  msg: 'Please fill in all required fields.',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );
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
    );
  }

  Future<String> uploadImage(File? selectedImage, String name) async{

    final userId= widget.dependentId;

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
