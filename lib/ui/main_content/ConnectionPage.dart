import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../models/Chat.dart';
import '../../models/Connection.dart';
import 'MessagePage.dart';

class ConnectionPage extends StatefulWidget {
  final String accountId;

  ConnectionPage({super.key, required this.accountId});

  @override
  _ConnectionPageState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  List<Connection> connections = [];
  List<Chat> chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllConnections();
    fetchAllChats();
  }

  // Retrieve all the relations of the current User
  Future<void> fetchAllConnections() async {
    var url = Uri.parse(
        'https://api2.unipile.com:13237/api/v1/users/relations?limit=50&account_id=${widget.accountId}');
    var headers = {
      'Accept': 'application/json',
      'X-Api-Key': dotenv.env['UNIPILE_ACCESS_TOKEN']!
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('items') && jsonResponse['items'] is List) {
        List<dynamic> items = jsonResponse['items'];
        List<Connection> loadedConnections =
            items.map((item) => Connection.fromJson(item)).toList();

        for (Connection connection in loadedConnections) {
          await precacheImage(NetworkImage(connection.picture), context);
        }

        setState(() {
          connections = loadedConnections;
          _isLoading = false; // Update loading state
        });
      } else {
        print('La réponse ne contient pas la structure attendue.');
        setState(() {
          _isLoading = false; // Update loading state even on error
        });
      }
    } else {
      print('Échec de la requête : ${response.statusCode}');
      setState(() {
        _isLoading = false; // Update loading state even on error
      });
    }
  }

  // Retrieve all the chats of the current user
  Future<void> fetchAllChats() async {
    var url = Uri.parse(
        'https://api2.unipile.com:13237/api/v1/chats?account_id=${widget.accountId}');

    var headers = {
      'X-API-KEY': dotenv.env['UNIPILE_ACCESS_TOKEN']!,
      'accept': 'application/json'
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      if (jsonData.containsKey('items') && jsonData['items'] is List) {
        List<dynamic> chatItems = jsonData['items'];
        setState(() {
          chats = chatItems.map((item) => Chat.fromJson(item)).toList();
        });
      }
    } else {
      print('Failed to fetch chats: ${response.statusCode}');
    }
  }

  // Check if a chat already exists between two users
  bool isChatExist(String attendeeProviderId) {
    return chats.any((chat) => chat.attendeeId == attendeeProviderId);
  }

  // Get the count of all the unread messages of a chat
  int getUnreadCount(String attendeeId) {
    Chat? chat = chats.firstWhere(
      (chat) => chat.attendeeId == attendeeId,
      orElse: () => Chat(
        id: '',
        accountId: '',
        attendeeId: '',
        unreadCount: 0,
      ),
    );

    return chat.unreadCount;
  }

  //To start a new chat
  Future<void> startNewChat(
      String attendeesIds, String accountId, Connection connection) async {
    var url = Uri.parse('https://api2.unipile.com:13237/api/v1/chats');
    var headers = {
      'X-API-KEY': dotenv.env['UNIPILE_ACCESS_TOKEN']!,
      'accept': 'application/json',
      'content-type': 'multipart/form-data',
    };

    var request = http.MultipartRequest('POST', url)
      ..headers.addAll(headers)
      ..fields['attendees_ids'] = attendeesIds
      ..fields['account_id'] = accountId
      ..fields['text'] = "Hello !";

    try {
      var response = await request.send();

      if (response.statusCode == 201) {
        print('Chat started successfully.');
        await fetchAllChats();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagePage(
                chatId: chats
                    .firstWhere((chat) => chat.attendeeId == attendeesIds)
                    .id,
                contact: connection),
          ),
        );
      } else {
        print('Failed to start chat. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error starting chat: $e');
    }
  }

  // Function for handling swipe-to-refresh
  Future<void> _refreshContacts() async {
    await fetchAllConnections();
    await fetchAllChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Discutez avec vos connections'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshContacts,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: connections.length,
                itemBuilder: (context, index) {
                  Connection connection = connections[index];
                  bool chatExists = isChatExist(connection.id);
                  int unreadCount = getUnreadCount(connection.id);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(connection.picture),
                    ),
                    title: Text(
                      connection.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      connection.headline,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: chatExists && unreadCount > 0
                        ? Stack(
                            children: [
                              IconButton(
                                icon: Icon(Icons.message),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MessagePage(
                                          chatId: chats
                                              .firstWhere((chat) =>
                                                  chat.attendeeId ==
                                                  connection.id)
                                              .id,
                                          contact: connection),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                  child: Text(
                                    '$unreadCount',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : chatExists && unreadCount == 0
                            ? null // Do not show message icon if no unread messages
                            : ElevatedButton(
                                onPressed: () async {
                                  startNewChat(connection.id, widget.accountId,
                                      connection);
                                },
                                child: Text('Say Hello !'),
                              ),
                    onTap: () async {
                      if (chatExists) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessagePage(
                                chatId: chats
                                    .firstWhere((chat) =>
                                        chat.attendeeId == connection.id)
                                    .id,
                                contact: connection),
                          ),
                        );
                      } else {
                        startNewChat(
                            connection.id, widget.accountId, connection);
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}
