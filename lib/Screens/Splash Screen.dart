import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Home_Screen.dart';
import 'login_screen.dart';
import '../messaging_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> {
  final messagingService = MessagingService();

  @override
  void initState() {
    super.initState();
    messagingService.init(context);
    _checkUserAuthentication();
  }

  Future<void> _checkUserAuthentication() async {
    final user = FirebaseAuth.instance.currentUser;

    await Future.delayed(const Duration(seconds: 2));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => user != null ? const MyHomeScreen(userId: '') : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get screen size
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: Container(
        color: const Color(0xFF4A148C),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // CircleAvatar size based on screen dimensions
              CircleAvatar(
                radius: screenWidth * 0.2, // 20% of screen width
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage("assets/blood.jpeg"),
              ),
              SizedBox(height: screenHeight * 0.03), // 3% of screen height
              Text(
                "Life Flow",
                style: TextStyle(
                  fontSize: screenWidth * 0.12, // 12% of screen width
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                  fontFamily: 'Pacifico',
                ),
              ),
              SizedBox(height: screenHeight * 0.01), // 1% of screen height
              Text(
                "Connecting Blood Donors\nFor Rapid Emergencies",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.05, // 5% of screen width
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
