import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ProfileEditScreen extends StatefulWidget {
  final String userId;

  const ProfileEditScreen({super.key, required this.userId});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _bloodGroup;
  String? _userProfilePhotoUrl;
  File? _imageFile;
  bool _isEditMode = false;
  String? _district;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    var snapshot = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .snapshots();

    snapshot.listen((userSnapshot) {
      if (userSnapshot.exists) {
        var user = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = user['name'];
          _emailController.text = user['email'];
          _ageController.text = user['age'];
          _bloodGroup = user['bloodGroup'];
          _userProfilePhotoUrl = user['image'];
          _district = user['district'];
        });
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  ImageProvider<Object> _getUserProfileImage() {
    if (_userProfilePhotoUrl != null && _userProfilePhotoUrl!.isNotEmpty) {
      return NetworkImage(_userProfilePhotoUrl!);
    }
    return const AssetImage('assets/default_profile_image.jpg');
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('userId');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> _updateUserProfile() async {
    try {

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'name': _nameController.text,
        'email': _emailController.text,
        'age': _ageController.text,
        'bloodGroup': _bloodGroup,
        'district': _district,
      });


      _showSaveSuccessMessage();


      if (_imageFile != null) {
        var storageReference = FirebaseStorage.instance
            .ref()
            .child("profile_photos/${widget.userId}");
        await storageReference.putFile(_imageFile!);
        var photoUrl = await storageReference.getDownloadURL();


        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({
          'image': photoUrl,
        });
      }

    } catch (e) {
      print('Error updating profile: $e');
    } finally {

      setState(() {
        _isEditMode = false;
      });
    }
  }

  void _showSaveSuccessMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Save Success"),
          content: const Text("Your profile has been successfully updated."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_isEditMode)
            TextButton(
              onPressed: _signOut,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02
                ),
                child: const Text("Logout"),
              ),
            ),
        ],
        title: const Text("Edit Profile"),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _isEditMode ? _pickImage : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: screenWidth * 0.2,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : _getUserProfileImage(),
                        ),
                        if (_isEditMode)
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 35,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                      enabled: _isEditMode,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      enabled: _isEditMode,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Age"),
                      enabled: _isEditMode,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _bloodGroup,
                      onChanged: _isEditMode
                          ? (value) {
                        setState(() {
                          _bloodGroup = value;
                        });
                      }
                          : null,
                      items: [
                        "A+",
                        "A-",
                        "B+",
                        "B-",
                        "AB+",
                        "AB-",
                        "O+",
                        "O-",
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: const InputDecoration(labelText: "Blood Group"),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _district,
                      onChanged: _isEditMode
                          ? (value) {
                        setState(() {
                          _district = value;
                        });
                      }
                          : null,
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
                        "Kasaragod",
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: const InputDecoration(labelText: "District"),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isEditMode
          ? FloatingActionButton(
        onPressed: () async {
          await _updateUserProfile();
          setState(() {
            _isEditMode = false;
          });
        },
        child: const Icon(Icons.check),
      )
          : FloatingActionButton(
        onPressed: () {
          setState(() {
            _isEditMode = true;
          });
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
