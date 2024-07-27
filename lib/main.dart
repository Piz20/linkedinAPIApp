import 'package:Linkedin/ui/Authentication/LinkedInAccountsPage.dart';
import 'package:Linkedin/ui/Authentication/LoginPage.dart';
import 'package:Linkedin/ui/main_content/MainPage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


void main() async {
  // Ensure Flutter is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables before accessing them
  await dotenv.load(fileName: "secret.env");

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String _accountId = "";
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    String accountId = await _checkOrCreateAccountId("accountId");
    setState(() {
      _accountId = accountId;
      _isInitialized = true;
    });
  }

  Future<String> _checkOrCreateAccountId(String key) async {
    String? value = await _storage.read(key: key);

    if (value == null) {
      // Key does not exist, so create it with an empty value
      await _storage.write(key: key, value: '');
      return ""; // Return an empty string since the value was empty
    } else if (value.isEmpty) {
      // Key exists but is empty
      return ""; // Return an empty string since the value was empty
    } else {
      // Key exists and has a non-empty value
      return value; // Return the non-empty value
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        title: 'LinkedInAPI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Colors.white,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.blue,
            secondary: Colors.white,
          ),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'LinkedInAPI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.blue,
          secondary: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: _accountId.isNotEmpty ? MainPage(accountId: _accountId) : LoginPage(),
    );
  }
}

