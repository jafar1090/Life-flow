import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'login_screen.dart'; // Import your login screen file

class SignupPages extends StatefulWidget {
  const SignupPages({super.key});

  @override
  _SignupPagesState createState() => _SignupPagesState();
}

class _SignupPagesState extends State<SignupPages> {
  final List<String> bloodGroups = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"];
  final List<String> districts = [
    "Thiruvananthapuram", "Kollam", "Alappuzha", "Pathanamthitta", "Kottayam",
    "Idukki", "Ernakulam", "Thrissur", "Palakkad", "Malappuram", "Kozhikode",
    "Wayanad", "Kannur", "Kasaragod"
  ];

  String? selectedGroup;
  String? selectedDistrict;
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  File? imageFile;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });
    }
  }

  Future<String?> _uploadImage(String userId) async {
    try {
      if (imageFile != null) {
        // Use the user ID or timestamp for unique naming
        final reference = FirebaseStorage.instance.ref().child("images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg");
        await reference.putFile(imageFile!);
        final imageUrl = await reference.getDownloadURL();
        return imageUrl;
      }
      return null;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> registerUser(BuildContext context) async {
    try {
      if (_validateForm()) {
        // Check if the phone number is already registered
        QuerySnapshot phoneQuery = await FirebaseFirestore.instance
            .collection("users")
            .where("phoneNumber", isEqualTo: phoneController.text)
            .get();

        if (phoneQuery.docs.isNotEmpty) {
          // Phone number already registered
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The phone number is already registered.')),
          );
          return; // Exit the function
        }

        // Phone number not registered, proceed with user registration
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        final imageUrl = await _uploadImage(userCredential.user!.uid);

        await FirebaseFirestore.instance.collection("users").doc(userCredential.user!.uid).set({
          "name": nameController.text,
          "age": ageController.text,
          "email": emailController.text,
          "uid": userCredential.user!.uid,
          "image": imageUrl,
          "phoneNumber": phoneController.text,
          "district": selectedDistrict,
          "bloodGroup": selectedGroup,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()), // Replace with your login screen
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "An error occurred")),
      );
    } catch (e) {
      print("Unexpected error during registration: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred")),
      );
    }
  }

  bool _validateForm() {
    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        selectedGroup == null ||
        selectedDistrict == null ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return false;
    }

    if (!RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email address")),
      );
      return false;
    }

    if (phoneController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number must have 10 digits")),
      );
      return false;
    }

    // Add more phone number validation if needed

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters long")),
      );
      return false;
    }

    // Add more password validation criteria if needed

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign Up",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: MediaQuery.of(context).size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.3,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: imageFile != null ? FileImage(imageFile!) : null,
                    child: imageFile == null
                        ? const Icon(Icons.camera_alt, size: 60, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              DropdownButtonFormField(
                value: selectedGroup,
                onChanged: (value) {
                  setState(() {
                    selectedGroup = value;
                  });
                },
                items: bloodGroups.map((group) {
                  return DropdownMenuItem(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: "Blood Group",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              DropdownButtonFormField(
                value: selectedDistrict,
                onChanged: (value) {
                  setState(() {
                    selectedDistrict = value;
                  });
                },
                items: districts.map((district) {
                  return DropdownMenuItem(
                    value: district,
                    child: Text(district),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: "District",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              ElevatedButton(
                onPressed: () => registerUser(context),
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
