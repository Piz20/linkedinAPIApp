import 'package:Linkedin/models/Connection.dart';
import 'package:Linkedin/ui/Authentication/LoginPage.dart';
import 'package:Linkedin/ui/main_content/MainPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'models/Post.dart';
import 'models/User.dart';

Future<void> main() async {
  // Load environment variables before accessing them
  await dotenv.load(fileName: "secret.env");

  // Run the app with the loaded user data
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final User? currentUser;

  const MyApp({Key? key, this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LinkedInAPI',
      debugShowCheckedModeBanner: false, // Enlever la bannière de debug
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Fond d'écran blanc global
        primaryColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.blue,
          secondary: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: currentUser != null
          ? MainPage(currentUser: currentUser)
          : LoginPage(),
    );
  }
}
