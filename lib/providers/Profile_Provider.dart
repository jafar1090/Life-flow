import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'Authentication_provider.dart';

class ProfileProvider with ChangeNotifier {
  final AuthProvider authProvider;
  String? userId;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  String? bloodGroup;
  String? userProfilePhotoUrl;
  File? imageFile;
  bool isEditMode = false;
  String? district;

  ProfileProvider({required this.authProvider, required this.userId}) {
    if (userId!.isNotEmpty) {
      fetchUserProfile();
    }
  }

  void updateUserId(String newUserId) {
    userId = newUserId;
    fetchUserProfile();
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    if (userId == null || userId!.isEmpty) return;

    var snapshot = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();

    snapshot.listen((userSnapshot) {
      if (userSnapshot.exists) {
        var user = userSnapshot.data() as Map<String, dynamic>;
        nameController.text = user['name'];
        emailController.text = user['email'];
        ageController.text = user['age'];
        bloodGroup = user['bloodGroup'];
        userProfilePhotoUrl = user['image'];
        district = user['district'];
        notifyListeners();
      }
    });
  }

  Future<void> pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      imageFile = File(pickedImage.path);
      notifyListeners();
    }
  }

  Future<void> updateUserProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'name': nameController.text,
      'email': emailController.text,
      'age': ageController.text,
      'bloodGroup': bloodGroup,
      'district': district,
    });

    if (imageFile != null) {
      var storageReference =
      FirebaseStorage.instance.ref().child("profile_photos/$userId");
      var uploadTask = await storageReference.putFile(imageFile!);
      var photoUrl = await storageReference.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'image': photoUrl,
      });
    }


  }

  void toggleEditMode() {
    isEditMode = !isEditMode;
    notifyListeners();
  }
}
