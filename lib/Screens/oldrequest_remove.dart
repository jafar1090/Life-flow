import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class BloodRequestHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> removeOldBloodRequests() async {
    // Calculate the timestamp one week ago
    DateTime oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));

    try {
      // Query blood requests older than one week
      QuerySnapshot oldRequestsSnapshot = await _firestore
          .collection('blood_requests')
          .where('timestamp', isLessThan: oneWeekAgo)
          .get();

      // Delete each old blood request
      for (DocumentSnapshot doc in oldRequestsSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing old blood requests: $e');
      }
    }
  }
}
