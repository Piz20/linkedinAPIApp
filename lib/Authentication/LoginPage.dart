import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:linkedin_login/linkedin_login.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _simulateLoading() async {
    // Simulate a delay for LinkedIn loading (this should be replaced by actual LinkedIn login status)
    await Future.delayed(const Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white, // Background color for the login page
      body: FutureBuilder(
        future: _simulateLoading(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: LinkedInUserWidget(
                clientId: dotenv.env['LINKEDIN_CLIENT_ID']!,
                clientSecret: dotenv.env['LINKEDIN_CLIENT_SECRET']!,
                redirectUrl: dotenv.env['LINKEDIN_REDIRECT_URL']!,
                destroySession: true,
                onGetUserProfile: (UserSucceededAction linkedInUser) {
                  print('Access token ${linkedInUser.user.token}');
                  print('First name: ${linkedInUser.user.givenName}');
                  print('Last name: ${linkedInUser.user.familyName}');
                },
                onError: (UserFailedAction error) {
                  // Callback when an error occurs during login
                  print('LinkedIn login error: ${error.toString()}');
                  // Handle the error here
                },
              ),
            );
          }
        },
      ),
    );
  }
}
