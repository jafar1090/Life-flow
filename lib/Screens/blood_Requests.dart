import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import '../my_model.dart';
import 'oldrequest_remove.dart';

class BloodRequestScreen extends StatefulWidget {
  const BloodRequestScreen({super.key});

  @override
  _BloodRequestScreenState createState() => _BloodRequestScreenState();
}

class _BloodRequestScreenState extends State<BloodRequestScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(days: 1), (timer) {
      BloodRequestHelper.removeOldBloodRequests();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  final int _perPage = 10;
  DocumentSnapshot? _lastDocument;

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Blood Requests',
          style: TextStyle(
            fontSize: screenSize.width * 0.05, // 5% of screen width
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getBloodRequestsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: screenSize.width * 0.045, color: Colors.red[600]),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<BloodRequest> bloodRequests = snapshot.data!.docs.map((doc) {
            return BloodRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
          bloodRequests.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return bloodRequests.isEmpty
              ? Center(
            child: Text(
              'No requests available',
              style: TextStyle(fontSize: screenSize.width * 0.045, color: Colors.grey),
            ),
          )
              : ListView.builder(
            itemCount: bloodRequests.length + 1,
            itemBuilder: (context, index) {
              if (index == bloodRequests.length) {
                return _buildLoadMoreButton(bloodRequests.length, snapshot.data!);
              } else {
                var request = bloodRequests[index];
                return BloodRequestCard(request: request);
              }
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getBloodRequestsStream() {
    Query query = FirebaseFirestore.instance
        .collection('blood_requests')
        .orderBy('timestamp', descending: true)
        .limit(_perPage);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    return query.snapshots();
  }

  Widget _buildLoadMoreButton(int currentCount, QuerySnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Center(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.redAccent, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            _loadMore(currentCount, snapshot);
          },
          child: const Text(
            'Load More',
            style: TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _loadMore(int currentCount, QuerySnapshot snapshot) {
    setState(() {
      _lastDocument = snapshot.docs[currentCount - 1];
    });
  }
}

class BloodRequestCard extends StatelessWidget {
  final BloodRequest request;

  const BloodRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {

    final screenSize = MediaQuery.of(context).size;

    String formattedDateTime = DateFormat('dd/MM/yyyy hh:mm a').format(request.timestamp);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.03, vertical: screenSize.height * 0.01),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.red[50]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenSize.width * 0.01),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: screenSize.width * 0.1,
                    backgroundColor: Colors.blue,
                    child: Text(
                      request.bloodGroup,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenSize.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.userName,
                          style: TextStyle(
                            fontSize: screenSize.width * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'District: ${request.district}',
                          style: TextStyle(fontSize: screenSize.width * 0.04, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, color: Colors.blueAccent),
                    onPressed: () {
                      _makePhoneCall(request.contactNumber, context);
                    },
                  ),
                ],
              ),
              const Divider(),
              Text(
                'Requested On: $formattedDateTime',
                style: TextStyle(fontSize: screenSize.width * 0.04, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _makePhoneCall(String? phoneNumber, BuildContext context) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is not available')),
      );
      return;
    }

    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }
}
class LocalUser {
  String name;
  String email;
  bool online;
  String profilePhotoUrl;
  String bloodType;
  String phoneNumber;
  String district;

  LocalUser({
    required this.name,
    required this.email,
    required this.online,
    required this.profilePhotoUrl,
    required this.bloodType,
    required this.district,
    required this.phoneNumber,
    required isDonationEnabled,
  });
}