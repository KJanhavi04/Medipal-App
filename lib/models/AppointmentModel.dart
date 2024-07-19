import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  String userId;
  String appointmentId;
  String doctorName;
  String location;
  String status;
  String appointmentTime;
  String description;

  AppointmentModel(
      {required this.userId,
      required this.appointmentId,
      required this.doctorName,
      required this.location,
      required this.status,
      required this.appointmentTime,
      required this.description});

  factory AppointmentModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return AppointmentModel(
        userId: data['userId'],
        appointmentId: data['appointmentId'],
        doctorName: data['doctorName'],
        location: data['location'],
        status: data['status'],
        appointmentTime: data['appointmentTime'],
        description: data['description']);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'appointmentId': appointmentId,
      'doctorName': doctorName,
      'location': location,
      'status': status,
      'appointmentTime': appointmentTime,
      'description': description,
    };
  }
}
