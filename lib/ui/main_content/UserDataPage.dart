import 'package:Linkedin/models/User.dart';
import 'package:flutter/material.dart';

class UserDataPage extends StatefulWidget {
  final UserData currentUserData;

  UserDataPage({super.key, required this.currentUserData});

  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Use ClipOval with Image for better quality
              ClipOval(
                child: Image.network(
                  widget.currentUserData.profilePictureUrl,
                  width: 250, // Adjust width as needed
                  height: 250, // Adjust height as needed
                  fit: BoxFit.cover, // Ensure the image covers the area
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Name: ${widget.currentUserData.firstName} ${widget.currentUserData.lastName}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Email: ${widget.currentUserData.email}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Occupation: ${widget.currentUserData.occupation}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Location: ${widget.currentUserData.location}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
