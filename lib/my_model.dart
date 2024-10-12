import 'package:cloud_firestore/cloud_firestore.dart';

class BloodRequest {
  final String id;
  final String userId; // ID of the user making the request
  final String userName;
  final String bloodGroup;
  final String district;
  final String contactNumber;
  final DateTime timestamp;
  final String name; // Assuming you need this field
  final String phoneNumber; // Assuming you need this field
  final String fcmToken; // Assuming you need this field
  bool isDonationEnabled;

  BloodRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.bloodGroup,
    required this.district,
    required this.contactNumber,
    required this.timestamp,
    required this.name,
    required this.phoneNumber,
    required this.fcmToken,
    required this.isDonationEnabled,
  });

  factory BloodRequest.fromMap(Map<String, dynamic> map, String id) {
    return BloodRequest(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      district: map['district'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      // Safely handle the timestamp conversion
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      fcmToken: map['fcmToken'] ?? '',
      isDonationEnabled: map['isDonationEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'bloodGroup': bloodGroup,
      'district': district,
      'contactNumber': contactNumber,
      'timestamp': FieldValue.serverTimestamp(),
      'name': name,
      'phoneNumber': phoneNumber,
      'fcmToken': fcmToken,
      'isDonationEnabled': isDonationEnabled,
    };
  }
}
