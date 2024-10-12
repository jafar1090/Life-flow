import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lifeflow_project/Screens/search_donors.dart';
import 'package:lifeflow_project/Screens/setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_request.dart';
import 'Enableddonors_Screen.dart';
import 'login_screen.dart';
import 'about_page.dart';
import 'blood_Requests.dart';
import 'edite_profile.dart';
import 'my_requests_screen.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key, required String userId});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  final List<Color> iconColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
  ];

  bool isDonationEnabled = false;
  int curindex = 0;
  late String _userId;
  User? _currentUser;
  File? _imageFile;
  String? _userProfilePhotoUrl;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserOnDemand();
  }

  Future<void> _pickImage() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  void _fetchCurrentUserOnDemand() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
        _userId = user.uid;
      });
    }
  }

  ImageProvider<Object> _getUserProfileImage() {
    if (_userProfilePhotoUrl != null && _userProfilePhotoUrl!.isNotEmpty) {
      return NetworkImage(_userProfilePhotoUrl!);
    }
    return const AssetImage('assets/default_profile_image.jpg');
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('userId');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildDrawerItem(Icons.person, 'Profile', _navigateToProfileEditScreen,
              iconColors[0], context),
          _buildDrawerItem(Icons.search, 'Search Donors', _navigateToSearchDonor,
              iconColors[1], context),
          _buildDrawerItem(Icons.volunteer_activism, 'Blood Requests',
              _navigateToBloodRequestScreen, iconColors[0], context),
          _buildDrawerItem(Icons.add_circle, 'Add Blood Request',
              _navigateToAddBloodRequestScreen, iconColors[0], context),
          _buildDrawerItem(Icons.settings, 'Settings', _navigateToSettingsScreen,
              iconColors[1], context),
          _buildDrawerItem(Icons.volunteer_activism, 'My Requests',
              _navigateToMyRequestsScreen, iconColors[0], context),
          _buildDrawerItem(Icons.exit_to_app, 'Logout', _signOut, iconColors[2], context),
          _buildDrawerItem(Icons.info, 'About', _navigateToAboutScreen, iconColors[0], context),
          _buildDrawerItem(CupertinoIcons.checkmark_circle, 'We are Ready Now',
              _navigateToEnabledDonorsScreen, iconColors[1], context),
          const Divider(
            color: Colors.grey,
            height: 1,
          ),
          ListTile(
            leading: Icon(
              CupertinoIcons.checkmark_circle,
              color: isDonationEnabled ? Colors.green : Colors.blue,
            ),
            title: Text(
              'Ready to Donate',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.bold,
                color: isDonationEnabled ? Colors.green : Colors.black,
              ),
            ),
            trailing: Switch(
              value: isDonationEnabled,
              onChanged: (value) {
                setState(() {
                  isDonationEnabled = value;
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(_userId)
                      .update({
                    'isDonationEnabled': isDonationEnabled,
                  });
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return UserAccountsDrawerHeader(
      accountName: Text(
        _currentUser?.displayName ?? "User",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: MediaQuery.of(context).size.width * 0.045,
        ),
      ),
      accountEmail: Text(
        _currentUser?.email ?? "",
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.035,
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.grey[300],
        backgroundImage: _getUserProfileImage(),
      ),
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, Function onTap,
      Color iconColor, BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
        size: MediaQuery.of(context).size.width * 0.07,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.black87,
          fontSize: MediaQuery.of(context).size.width * 0.045,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lifeflow'),
        actions: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const CircleAvatar(
              backgroundImage: AssetImage("assets/appicon.jpg"),
              radius: 20,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _getBody(curindex, context),
      drawer: _buildDrawer(context),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: iconColors[0],
              size: MediaQuery.of(context).size.width * 0.07,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              color: iconColors[1],
              size: MediaQuery.of(context).size.width * 0.07,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.profile_circled,
              color: iconColors[2],
              size: MediaQuery.of(context).size.width * 0.07,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: curindex,
        onTap: (value) {
          setState(() {
            curindex = value;
          });
        },
      ),
    );
  }

  Widget _getBody(int index, BuildContext context) {
    switch (index) {
      case 0:
        return const BloodRequestScreen();
      case 1:
        return const SearchDonor();
      case 2:
        return ProfileEditScreen(userId: _userId);
      default:
        return Container();
    }
  }

  void _navigateToProfileEditScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditScreen(userId: _userId),
      ),
    );
  }

  void _navigateToAboutScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutPage(),
      ),
    );
  }

  void _navigateToBloodRequestScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BloodRequestScreen(),
      ),
    );
  }

  void _navigateToAddBloodRequestScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddBloodRequestScreen(),
      ),
    );
  }

  void _navigateToSearchDonor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchDonor(),
      ),
    );
  }

  void _navigateToSettingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _navigateToMyRequestsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyRequestsScreen(),
      ),
    );
  }

  void _navigateToEnabledDonorsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EnabledDonorsScreen(),
      ),
    );
  }
}
