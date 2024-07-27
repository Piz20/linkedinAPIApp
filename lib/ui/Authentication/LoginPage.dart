import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'LinkedInAccountsPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _url;
  late WebViewController webViewController;

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
          _initializeWebView();
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
        throw Exception(
            'Failed to load link (status code: ${response.statusCode})');
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

  void _initializeWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_url!));
  }

  void _navigateToLinkedInAccountPage() {
    // Replace with your navigation logic to LinkedInAccountPage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LinkedInAccountsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _navigateToLinkedInAccountPage,
              child: Text('Choose an Account'),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('OR'),
            ),
            if (_url != null)
              Expanded(
                child: WebViewWidget(controller: webViewController),
              ),
          ],
        ),
      ),
    );
  }
}
