import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../my_model.dart'; // Make sure this model is properly defined

class AddBloodRequestScreen extends StatefulWidget {
  const AddBloodRequestScreen({super.key});

  @override
  _AddBloodRequestScreenState createState() => _AddBloodRequestScreenState();
}

class _AddBloodRequestScreenState extends State<AddBloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactNumberController =
  TextEditingController();
  String? _selectedBloodGroup;
  String? _selectedDistrict;

  Future<void> sendNotificationToAllUsers(
      String title, String body, List<String> tokens) async {
    const String serverKey =
        'YOUR_SERVER_KEY_HERE'; // Replace with your FCM server key
    final Map<String, dynamic> data = {
      'registration_ids': tokens,
      'notification': {
        'title': title,
        'body': body,
      },
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _addBloodRequest() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        final phoneNumber = _contactNumberController.text;

        // Check if any user is already registered with this phone number
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('phoneNumber', isEqualTo: phoneNumber)
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('A user is already registered with this phone number')),
          );
          return;
        }

        final bloodRequest = BloodRequest(
          id: '',
          userId: user.uid,
          userName: _nameController.text,
          bloodGroup: _selectedBloodGroup ?? '',
          district: _selectedDistrict ?? '',
          contactNumber: phoneNumber,
          timestamp: DateTime.now(),
          fcmToken: fcmToken ?? '',
          name: '',
          phoneNumber: '',
          isDonationEnabled: false,
        );

        try {
          // Add the blood request to Firestore
          await FirebaseFirestore.instance
              .collection('blood_requests')
              .add(bloodRequest.toMap());

          // Fetch all user tokens from Firestore
          QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

          List<String> tokens = [];

          for (var doc in querySnapshot.docs) {
            if (doc.data() is Map<String, dynamic> &&
                (doc.data() as Map<String, dynamic>).containsKey('fcmToken')) {
              String token = (doc.data() as Map<String, dynamic>)['fcmToken'];
              tokens.add(token);
            }
          }

          // Send notification to all users if tokens are available
          if (tokens.isNotEmpty) {
            await sendNotificationToAllUsers(
              'New Blood Request',
              'A new blood request has been added by ${_nameController.text}.',
              tokens,
            );
          }

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Blood request submitted successfully!')),
          );

          // Navigate back to the previous screen
          Navigator.pop(context);
        } catch (e) {
          if (kDebugMode) {
            print('Error adding blood request: $e');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                Text('Failed to submit blood request. Please try again.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Blood Request',
          style: TextStyle(
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0, // No shadow
      ),
      body: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.05),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  icon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _selectedBloodGroup,
                items: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBloodGroup = newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Blood Group',
                  icon: Icon(Icons.local_hospital),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your blood group';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _selectedDistrict,
                items: [
                  "Thiruvananthapuram",
                  "Kollam",
                  "Alappuzha",
                  "Pathanamthitta",
                  "Kottayam",
                  "Idukki",
                  "Ernakulam",
                  "Thrissur",
                  "Palakkad",
                  "Malappuram",
                  "Kozhikode",
                  "Wayanad",
                  "Kannur",
                  "Kasaragod"
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDistrict = newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'District',
                  icon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your district';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactNumberController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  icon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your contact number';
                  }
                  // Regular expression for Indian phone numbers
                  final RegExp phoneRegex = RegExp(r'^[6-9]\d{9}$');
                  if (!phoneRegex.hasMatch(value)) {
                    return 'Please enter a valid Indian phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addBloodRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // Set button background color
                ),
                child: const Text('Submit Request',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
