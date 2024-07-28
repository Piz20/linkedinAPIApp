import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import '../../models/Connection.dart';
import '../../models/Message.dart';

import 'package:http/http.dart' as http;

import '../../models/User.dart';

class MessagePage extends StatefulWidget {
  final Connection contact;
  final String chatId;

  MessagePage({required this.contact, required this.chatId});

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _controller = TextEditingController();
  List<Message> messages = [];
  bool _isSending = true;
  UserData? currentUser;

  @override
  void initState() {
    super.initState();
    fetchChatMessages();
  }

  // We retrieve the messages of the current user
  Future<void> fetchChatMessages() async {
    var url = Uri.parse(
        "https://api2.unipile.com:13237/api/v1/chats/${widget.chatId}/messages?limit=10");
    var headers = {
      'Accept': 'application/json',
      'X-Api-Key': dotenv.env['UNIPILE_ACCESS_TOKEN']!
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse.containsKey('items') && jsonResponse['items'] is List) {
        List<dynamic> messageItems = jsonResponse['items'];
        messageItems = messageItems.reversed.toList();
        setState(() {
          messages =
              messageItems.map((item) => Message.fromJson(item)).toList();
        });
      }
    } else {
      print('Failed to fetch messages: ${response.statusCode}');
    }

    setState(() {
      _isSending = false;
    });
  }

  //We send a message in the chat
  Future<void> sendMessage(String message) async {
    setState(() {
      _isSending = true; // Show loading indicator (e.g., progress bar)
    });

    var url = Uri.parse(
        'https://api2.unipile.com:13237/api/v1/chats/${widget.chatId}/messages');

    var request = http.MultipartRequest('POST', url)
      ..headers['X-API-KEY'] = dotenv.env['UNIPILE_ACCESS_TOKEN']!
      ..headers['accept'] = 'application/json'
      ..fields['text'] = message;

    try {
      var response = await request.send();
      if (response.statusCode == 201) {
        print(
            'Message envoyé avec succès================================================');
      } else {
        throw Exception(
            'Échec de l\'envoi du message------------------------- : ${response.statusCode}');
      }
    } catch (error) {
      // Handle error (e.g., display user-friendly message)
      print('Error sending message: $error');
    } finally {
      setState(() {
        fetchChatMessages();
        _isSending = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.contact.picture),
            ),
            SizedBox(width: 10), // Espacement entre l'avatar et le titre
            Expanded(
              child: Text(
                widget.contact.name,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchChatMessages, // Fonction de rafraîchissement
        child: Column(
          children: <Widget>[
            Divider(height: 1.0),
            Expanded(
              child:
                  _buildMessagesList(), // Utilisation d'une méthode séparée pour construire la liste de messages
            ),
            Divider(height: 1.0),
            _buildTextComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_isSending) {
      // Afficher un indicateur de chargement circulaire si les messages sont en cours de chargement
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            Message message = messages[index];

            // Determine si le message est envoye par l'expediteur ou le destinataire
            bool isSender = message.senderId == widget.contact.id;

            // Formatter l'heure d'envoi du message
            String formattedTime =
                DateFormat.Hm().format(message.timestamp.toLocal());

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment:
                    isSender ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: <Widget>[
                  if (isSender)
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.contact.picture),
                    ),
                  SizedBox(width: 8.0),
                  Container(
                    constraints: BoxConstraints(maxWidth: 250),
                    decoration: BoxDecoration(
                      color: isSender ? Colors.grey[300] : Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          message.text,
                          style: TextStyle(color: Colors.black),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildTextComposer() {
    final double initialHeight = 50.0; // Hauteur initiale de la zone de texte

    return IconTheme(
      data: IconThemeData(color: Theme.of(context).cardColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxWidth: 250),
                // Définir une largeur maximale de 250 pixels
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                  // Bordure grise de largeur 1
                  borderRadius: BorderRadius.circular(4.0),
                  // Coins arrondis de rayon 4
                ),
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  // Désactiver le rebondissement de défilement
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: initialHeight * 4),
                    // Limite de 4 fois la hauteur initiale
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.multiline,
                      // Clavier pour plusieurs lignes
                      maxLines: null,
                      // Permet au TextField de s'étendre verticalement
                      textInputAction: TextInputAction.newline,
                      // Action pour nouvelle ligne
                      onSubmitted: _handleSubmitted,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Envoyer un message',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                color: Colors.blue,
                onPressed: () => _handleSubmitted(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) {
    if (text.isNotEmpty) {
      _controller.clear();
      sendMessage(text);
    }
  }
}
