import 'dart:convert';

import 'package:Linkedin/ui/Authentication/LoginPage.dart';
import 'package:Linkedin/ui/main_content/ConnectionPage.dart';
import 'package:Linkedin/ui/main_content/PostPage.dart';
import 'package:Linkedin/ui/main_content/UserDataPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../models/User.dart';
import 'package:flutter/services.dart'; // Importez ce package pour utiliser SystemNavigator

class MainPage extends StatefulWidget {
  final String accountId;

  MainPage({Key? key, required this.accountId}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // 0 for Posts, 1 for Contacts, etc.

  UserData? currentUserData;

  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api2.unipile.com:13237/api/v1/users/me?account_id=${widget.accountId}'),
        headers: {
          'X-API-KEY': dotenv.env['UNIPILE_ACCESS_TOKEN']!,
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          currentUserData = UserData.fromJson(data);
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<bool> _onWillPop() async {
    // Close the app when the back button is pressed
    SystemNavigator.pop();
    return Future.value(false); // Return false to prevent default behavior
  }

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String text,
      Color? textColor,
      Color? iconColor,
      VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? null),
      title: Text(text, style: TextStyle(color: textColor ?? null)),
      onTap: () {
        Navigator.of(context).pop(); // Close the drawer
        if (onTap != null) onTap();
      },
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return PostPage(accountId: widget.accountId);
      case 1:
        return ConnectionPage(accountId: widget.accountId);
      default:
        return Center(child: Text("Page not found"));
    }
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Posts';
      case 1:
        return 'Contacts';
      default:
        return 'LinkedInAPI'; // Default title for unknown pages
    }
  }

  void _signOut(BuildContext context) async {
    // Show a confirmation dialog
    final bool? shouldSignOut = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          backgroundColor: Colors.white,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false if cancelled
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true if confirmed
              },
              child: Text('Sign Out'),
            ),
          ],
        );
      },
    );

    // If the user confirms, perform the sign out
    if (shouldSignOut == true) {
      await _storage.write(key: "accountId", value: "");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Close the app when the back button is pressed
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(_getTitle()), // Set the title based on _selectedIndex
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: GestureDetector(
                  onTap: () {
                    _navigateToUserDataPage(context,currentUserData!);
                  },
                  child: CircleAvatar(
                    backgroundImage: currentUserData?.profilePictureUrl != null
                        ? NetworkImage(currentUserData!.profilePictureUrl)
                        : null,
                    child: currentUserData?.profilePictureUrl == null
                        ? Icon(Icons.person)
                        : null,
                  ),
                ),
                accountName: GestureDetector(
                  onTap: () {
                    _navigateToUserDataPage(context,currentUserData!);
                  },
                  child: Text(
                    currentUserData != null
                        ? '${currentUserData!.firstName} ${currentUserData!.lastName}'
                        : 'Nom Inconnu',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                accountEmail: GestureDetector(
                  onTap: () {
                    _navigateToUserDataPage(context,currentUserData!);
                  },
                  child: Text(
                    currentUserData != null && currentUserData!.email.isNotEmpty
                        ? currentUserData!.email
                        : 'Email Inconnu',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              _buildDrawerItem(
                icon: Icons.post_add,
                text: 'Posts',
                iconColor: Colors.blue,
                textColor: Colors.blue,
                onTap: () => _onItemTap(0),
              ),
              _buildDrawerItem(
                icon: Icons.chat,
                iconColor: Colors.blue,
                text: 'Chats',
                textColor: Colors.blue,
                onTap: () => _onItemTap(1),
              ),
              Divider(),
              _buildDrawerItem(
                icon: Icons.exit_to_app,
                iconColor: Colors.blue,
                text: 'Sign Out',
                textColor: Colors.blue,
                onTap: () => _signOut(context),
              ),
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            _buildBody(), // Main content area
          ],
        ),
      ),
    );
  }

  void _navigateToUserDataPage(BuildContext context , UserData currentUserData) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserDataPage(currentUserData: currentUserData,),
        ));
  }
}
