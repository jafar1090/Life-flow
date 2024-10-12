import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Life Flow'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Life Flow',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to Life Flow, your dedicated platform for connecting blood donors with those in need of life-saving blood transfusions. Life Flow is designed to streamline the process of finding blood donors, ensuring timely access to blood during emergencies and medical procedures.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Key Features:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.search),
              title: Text('Search Donors'),
            ),
            ListTile(
              leading: Icon(Icons.contact_phone),
              title: Text('Contact Donors'),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Receive Notifications'),
            ),
            ListTile(
              leading: Icon(Icons.mobile_friendly),
              title: Text('User-Friendly Interface'),
            ),
            SizedBox(height: 24),
            Text(
              'Our Mission:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'At Life Flow, our mission is to bridge the gap between blood donors and patients in need, ensuring that no life is lost due to a shortage of blood. We believe that every blood donation can make a difference and have the potential to save lives. By leveraging technology, we aim to promote a culture of voluntary blood donation and facilitate the blood donation process in our communities.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Get Started Today:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Join our community of blood donors and recipients by downloading Life Flow today. Together, we can make a positive impact and contribute to a world where access to safe and adequate blood is available to all those in need.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
