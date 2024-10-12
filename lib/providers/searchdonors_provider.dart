import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Screens/blood_Requests.dart';



class DonorProvider with ChangeNotifier {
  List<LocalUser> _donors = [];
  List<LocalUser> get donors => _donors;

  Future<void> updateSearch(String query, String bloodGroup) async {
    try {
      QuerySnapshot snapshot;
      if (query.isEmpty) {
        snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('bloodGroup', isEqualTo: bloodGroup)
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('bloodGroup', isEqualTo: bloodGroup)
            .get();
      }

      _donors = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return LocalUser(
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          online: data['online'] ?? false,
          profilePhotoUrl: data['image'] ?? '',
          bloodType: data['bloodGroup'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          isDonationEnabled: data['isDonationEnabled'] ?? false,
          district: data['district'] ?? '',
        );
      }).toList();

      notifyListeners();
    } catch (error) {
      print('Error updating search: $error');
    }
  }
}
