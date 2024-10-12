import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../my_model.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  _MyRequestsScreenState createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getMyRequestsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<BloodRequest> myRequests = snapshot.data!.docs.map((doc) {
            return BloodRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return myRequests.isEmpty
              ? const Center(
            child: Text(
              'No requests found',
              style: TextStyle(fontSize: 16),
            ),
          )
              : ListView.builder(
            itemCount: myRequests.length,
            itemBuilder: (context, index) {
              var request = myRequests[index];
              return ListTile(
                title: Text(request.userName),
                subtitle: Text('Blood Group: ${request.bloodGroup}, District: ${request.district}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteRequest(request.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getMyRequestsStream() {
    final user = _auth.currentUser;

    if (user != null) {
      return FirebaseFirestore.instance
          .collection('blood_requests')
          .where('userId', isEqualTo: user.uid)
          .snapshots();
    }

    return const Stream.empty();
  }

  void _deleteRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('blood_requests').doc(requestId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete request')));
    }
  }
}
