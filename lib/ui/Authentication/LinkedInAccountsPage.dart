import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../main_content/MainPage.dart';

class LinkedInAccountsPage extends StatefulWidget {
  @override
  _LinkedInAccountsPageState createState() => _LinkedInAccountsPageState();
}

class _LinkedInAccountsPageState extends State<LinkedInAccountsPage> {
  List<Map<String, dynamic>> accounts = [];
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchAccounts();
  }

  Future<void> fetchAccounts() async {
    final response = await http.get(
      Uri.parse('https://api2.unipile.com:13237/api/v1/accounts'),
      headers: {
        'X-API-KEY': dotenv.env["UNIPILE_ACCESS_TOKEN"]!,
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List<dynamic>;

      // Filtrer les doublons
      final Map<String, Map<String, dynamic>> uniqueAccounts = {};
      for (var item in items) {
        final account = item as Map<String, dynamic>;
        final imId = account['connection_params']['im']['id'];
        if (!uniqueAccounts.containsKey(imId)) {
          uniqueAccounts[imId] = account;
        }
      }

      setState(() {
        accounts = uniqueAccounts.values.toList();
      });
    } else {
      throw Exception('Échec du chargement des comptes');
    }
  }

  void navigateToMainPage(BuildContext context, String accountId) async{
    await _storage.write(key: "accountId", value: accountId) ;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainPage(accountId: accountId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comptes LinkedIn Connectés'),
      ),
      body: accounts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                final name = account['name'];
                final sourceId = account['sources'][0]['id'];
                final accountId = sourceId.replaceAll('_MESSAGING', '');
                print(accountId);
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(name),
                  onTap: () => navigateToMainPage(context, accountId),
                );
              },
            ),
    );
  }
}
