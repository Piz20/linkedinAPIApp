import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _url;

  @override
  void initState() {
    super.initState();
    _fetchLinkAndOpenWebView();
  }

  Future<void> _fetchLinkAndOpenWebView() async {
    try {
      final response = await http.post(
        Uri.parse('https://api2.unipile.com:13237/api/v1/hosted/accounts/link'),
        headers: {
          'X-API-KEY': dotenv.env['UNIPILE_ACCESS_TOKEN']!,
          'accept': 'application/json',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'type': 'create',
          'providers': ['LINKEDIN'],
          'api_url': 'https://api2.unipile.com:13237',
          'expiresOn': '2024-12-22T12:00:00.701Z',
        }),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('Response: $jsonResponse');
        if (jsonResponse.containsKey('url')) {
          setState(() {
            _url = jsonResponse['url'];
          });
          _launchURL(_url!);
        } else {
          print('Error: Response does not contain "url" key');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load link. Try again later.'),
            ),
          );
        }
      } else {
        print('Error: Status code ${response.statusCode}');
        throw Exception('Failed to load link (status code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
        ),
      );
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: _url == null
            ? CircularProgressIndicator()
            : ElevatedButton(
          onPressed: () => _launchURL(_url!),
          child: Text('Open WebView'),
        ),
      ),
    );
  }
}

