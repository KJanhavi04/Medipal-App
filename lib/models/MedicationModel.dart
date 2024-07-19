import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel {
  final String medicationId;
  final String name;
  final String type;
  final int dosage;
  final Map<String, dynamic> schedule;
  final Map<String, dynamic> inventory;
  final String startDate;
  final String endDate;
  final String userId;
  final String description;
  final String medicationImg;

  MedicationModel({
    required this.medicationId,
    required this.name,
    required this.type,
    required this.dosage,
    required this.schedule,
    required this.inventory,
    required this.startDate,
    required this.endDate,
    required this.userId,
    required this.description,
    required this.medicationImg,
  });

  factory MedicationModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return MedicationModel(
      medicationId: data['medicationId'],
      name: data['name'],
      type: data['type'],
      dosage: data['dosage'],
      schedule: data['schedule'],
      inventory: data['inventory'],
      startDate: data['startDate'],
      endDate: data['endDate'],
      userId: data['userId'],
      description: data['description'],
      medicationImg: data['medicationImg'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicationId': medicationId,
      'name': name,
      'type': type,
      'dosage': dosage,
      'schedule': schedule,
      'inventory': inventory,
      'startDate': startDate,
      'endDate': endDate,
      'userId': userId,
      'description': description,
      'medicationImg': medicationImg,
    };
  }
}
