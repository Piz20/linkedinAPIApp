import 'package:Linkedin/ui/main_content/ConnectionPage.dart';
import 'package:Linkedin/ui/main_content/PostPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/Post.dart';
import '../../models/User.dart';
import '../Authentication/LoginPage.dart';

class MainPage extends StatefulWidget {
  final User? currentUser;

  const MainPage({Key? key, this.currentUser}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // 0 for Home, 1 for Settings, etc.

  late User user;

  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    if (widget.currentUser != null) {
      user = widget.currentUser!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()), // Set the title based on _selectedIndex
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
                accountName: Text(
                  user.name,
                  style: TextStyle(color: Colors.white),
                ),
                accountEmail: Text(
                  user.email,
                  style: TextStyle(color: Colors.white),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(user.picture),
                )),
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
            // Add more items here if needed
            Divider(),
            _buildDrawerItem(
              icon: Icons.exit_to_app,
              iconColor: Colors.blue,
              text: 'Sign Out',
              textColor: Colors.blue,
              onTap: _signOut,
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          _buildBody(), // Main content area
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String text,
      Color? textColor,
      Color? iconColor,
      VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? null,
      ),
      title: Text(
        text,
        style: TextStyle(color: textColor ?? null),
      ),
      onTap: () {
        Navigator.of(context).pop(); // Close the drawer
        if (onTap != null) onTap();
      },
    );
  }

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: // Accueil
        return PostPage() ;
      case 1: // Contacts
        return ConnectionPage();
      // Ajoutez plus de cas pour d'autres indices/pages
      default:
        return Center(
          child: Text("Page not found"),
        );
    }
  }

  //Method helpful to fetch all datas in the fluttersecurestorage
  Future<List<Map<String, String>>> getAllEntries() async {
    final _storage = const FlutterSecureStorage();
    final allValues = await _storage.readAll();
    return allValues.entries
        .map((entry) => {'key': entry.key, 'value': entry.value})
        .toList();
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

  // Method to signOut of the Application
  void _signOut() async {
    final shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out Confirmation'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm
            child: Text('Sign Out'),
          ),
        ],
        backgroundColor: Colors.white,
      ),
    );

    if (shouldLogout ?? false) {
      try {
        // Clear all entries in FlutterSecureStorage
        await _storage.deleteAll();

        final allEntries = await _storage.readAll();
        // We add 2 seconds to ensure that all datas have been deleted
        await Future.delayed(Duration(seconds: 2));

        if (allEntries.isEmpty) {
          // We go to the login page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } catch (error) {
        // Handle errors that might occur during sign-out
        print('Error signing out: ${error.toString()}');
        // Add more specific error handling here
      }
    }
  }
}
