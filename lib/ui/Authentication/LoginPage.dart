import 'package:Linkedin/ui/main_content/MainPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:linkedin_login/linkedin_login.dart';

import '../../models/User.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
// Simulate loading delay (replace with actual LinkedIn login status)

class _LoginPageState extends State<LoginPage> {
  final _storage = const FlutterSecureStorage();

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
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
                onGetUserProfile: (UserSucceededAction linkedInUser) async {
                  print('Access token ${linkedInUser.user.token.accessToken}');
                  print('First name: ${linkedInUser.user.givenName}');
                  print('Last name: ${linkedInUser.user.familyName}');

                  User user = new User(
                      sub: linkedInUser.user.sub.toString(),
                      givenName: linkedInUser.user.givenName.toString(),
                      familyName: linkedInUser.user.familyName.toString(),
                      name: linkedInUser.user.name.toString(),
                      email: linkedInUser.user.email.toString(),
                      picture: linkedInUser.user.picture.toString(),
                      token: linkedInUser.user.token.accessToken.toString());

                  await _storeUserInfo(user);

                  await Future.delayed(Duration(seconds: 2));

                  final allEntries = await _storage.readAll();
                  if (allEntries.isNotEmpty) {
                    // We go to the login page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainPage(
                                currentUser: user,
                              )),
                    );
                  }
                },
                onError: (UserFailedAction error) {
                  // Handle login error
                  print('LinkedIn login error: ${error.toString()}');
                },
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _storeUserInfo(User user) async {
    final userMap = user.toMap();
    for (final entry in userMap.entries) {
      await _storage.write(key: entry.key, value: entry.value);
    }
  }
}
