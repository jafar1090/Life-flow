import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lifeflow_project/providers/searchdonors_provider.dart';
import 'package:lifeflow_project/themvechanger.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Screens/Splash Screen.dart';
import 'firebase_options.dart';
import 'providers/Authentication_provider.dart';
import 'providers/Profile_Provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  print(message.data);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => DonorProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (context) => ProfileProvider(
            authProvider: Provider.of<AuthProvider>(context, listen: false),
            userId: 'userId',
          ),
          update: (context, authProvider, previous) => ProfileProvider(
            authProvider: authProvider,
            userId: previous?.userId ?? '',
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lifeflow',
      theme: Provider.of<ThemeProvider>(context).currentTheme,
      home: const SplashScreen(),
    );
  }
}
