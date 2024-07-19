import 'package:cloud_firestore/cloud_firestore.dart';

class AlarmModel {
  final String alarmId;
  final String skipReason;
  final String userId;
  final String time;
  final String status;
  final String medicationId;

  AlarmModel(
      {required this.alarmId,
      required this.skipReason,
      required this.userId,
      required this.time,
      required this.status,
      required this.medicationId});

  factory AlarmModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return AlarmModel(
      alarmId: data['alarmId'],
      skipReason: data['skipReason'],
      userId: data['userId'],
      time: data['time'],
      status: data['status'],
      medicationId: data['medicationId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'alarmId': alarmId,
      'skipReason': skipReason,
      'userId': userId,
      'time': time,
      'status': status,
      'medicationId': medicationId,
    };
  }
}
