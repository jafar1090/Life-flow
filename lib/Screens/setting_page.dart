import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'package:provider/provider.dart';

import '../themvechanger.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isNotificationEnabled = true;
  bool isDarkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final appBar = AppBar(
      title: const Text("Settings"),
    );
    final availableHeight = mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top;

    return Scaffold(
      appBar: appBar,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text("Receive Notifications"),
              subtitle: const Text("Enable or disable notifications"),
              value: isNotificationEnabled,
              onChanged: (value) {
                setState(() {
                  isNotificationEnabled = value;
                });
                // Handle notification preferences
              },
            ),
            SwitchListTile(
              title: const Text("Dark Mode"),
              subtitle: const Text("Enable or disable dark mode"),
              value: isDarkModeEnabled,
              onChanged: (value) {
                setState(() {
                  isDarkModeEnabled = value;
                });
                _updateTheme(value);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Delete Account",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _reauthenticateAndDeleteAccount();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _reauthenticateAndDeleteAccount() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Reauthentication and account deletion logic
    }
  }

  void _updateTheme(bool isDarkModeEnabled) {
    Provider.of<ThemeProvider>(context, listen: false)
        .toggleTheme(isDarkModeEnabled);
  }
}