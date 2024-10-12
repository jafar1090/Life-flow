import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EnabledDonorsScreen extends StatefulWidget {
  const EnabledDonorsScreen({super.key});

  @override
  _EnabledDonorsScreenState createState() => _EnabledDonorsScreenState();
}

class _EnabledDonorsScreenState extends State<EnabledDonorsScreen> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('We are Ready Now',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.blue, // Adjust app bar color
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: users.where('isDonationEnabled', isEqualTo: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            var enabledUsers = snapshot.data!.docs;

            return ListView.builder(
              itemCount: enabledUsers.length,
              itemBuilder: (context, index) {
                var user = enabledUsers[index];
                var profilePhotoUrl = user['image'] ?? '';

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(profilePhotoUrl),
                      ),
                      title: Text(
                        "${user['name']}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, // Adjust name color
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Blood Type: ${user["bloodGroup"] ?? "N/A"}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Phone: ${user['phoneNumber'] ?? "N/A"}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'District: ${user['district'] ?? "N/A"}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.phone),
                        onPressed: () {
                          _makePhoneCall(user['phoneNumber']);
                        },
                      ),
                      onTap: () {
                        // Handle tapping on the user's tile
                        // You can implement any action here
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      String url = 'tel:$phoneNumber';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
    }
  }

}
