import 'dart:convert';
import 'package:Linkedin/models/User.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import '../../models/Connection.dart';
import '../../models/Post.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<Post> posts = [];
  List<Connection> connections = [];
  UserData? currentUserData;
  String? selectedUserId;
  Connection? selectedConnection;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData().then((userData) {
      setState(() {
        currentUserData = userData;
        selectedUserId = userData.providerId;
        fetchUserPosts(userData.providerId);
      });
    });
    fetchAllConnections();
  }

  Future<UserData> fetchUserData() async {
    final response = await http.get(
      Uri.parse(
          'https://api2.unipile.com:13237/api/v1/users/me?account_id=${dotenv.env['UNIPILE_ACCOUNT_ID']}'),
      headers: {
        'X-API-KEY': dotenv.env['UNIPILE_ACCESS_TOKEN']!,
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserData.fromJson(data);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> fetchAllConnections() async {
    var url = Uri.parse(
        'https://api2.unipile.com:13237/api/v1/users/relations?account_id=${dotenv.env['UNIPILE_ACCOUNT_ID']}');
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

        // Ajouter le currentUser à la liste des connexions
        UserData currentUserData = await fetchUserData();
        Connection currentUserConnection = Connection(
            id: currentUserData.providerId,
            givenName: currentUserData.firstName,
            familyName: currentUserData.lastName,
            picture: currentUserData.profilePictureUrl,
            name: currentUserData.firstName + " " + currentUserData.lastName,
            headline: currentUserData.occupation);
        loadedConnections.insert(0, currentUserConnection);

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

  Future<void> fetchUserPosts(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api2.unipile.com:13237/api/v1/users/$userId/posts?account_id=${dotenv.env['UNIPILE_ACCOUNT_ID']}'),
        headers: {
          'X-API-KEY': dotenv.env['UNIPILE_ACCESS_TOKEN']!,
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('items') &&
            jsonResponse['items'] is List) {
          List<dynamic> postItems = jsonResponse['items'];

          setState(() {
            posts = postItems.map((item) => Post.fromJson(item)).toList();
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to parse posts from response');
        }
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch user posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedConnection?.id,
            hint: Text(
              _getDropdownHint(),
              // Get the hint based on the selected connection
              overflow: TextOverflow.ellipsis,
            ),
            onChanged: (String? newValue) {
              setState(() {
                selectedConnection =
                    connections.firstWhere((c) => c.id == newValue);
                fetchUserPosts(newValue!);
              });
            },
            items: connections
                .map<DropdownMenuItem<String>>((Connection connection) {
              return DropdownMenuItem<String>(
                value: connection.id,
                child: Container(
                  color: Colors.transparent,
                  // Set background color to transparent
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(connection.picture),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          connection.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            // Set the width of the DropdownButton
            itemHeight: 60,
            // Adjust item height if necessary
            isExpanded: true,
          ),
        ),
        centerTitle: false, // Align title to the left
        actions: [
          // Add any actions if necessary
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return _buildPostCard(posts[index]);
              },
            ),
    );
  }

  Widget _buildPostCard(Post post) {
    String formattedDate = DateFormat.yMMMMd().format(post.parsedDatetime);

    // Déterminez l'utilisateur à afficher dans le post
    UserData postUserData = selectedConnection != null
        ? UserData(
            providerId: selectedConnection!.id,
            firstName: selectedConnection!.name.split(' ')[0],
            lastName: selectedConnection!.name.split(' ').skip(1).join(' '),
            profilePictureUrl: selectedConnection!.picture,
            occupation: selectedConnection!.headline,
          )
        : currentUserData!;

    // Création du nom de l'auteur avec "(vous)" si c'est le currentUser
    String authorName = '${postUserData.firstName} ${postUserData.lastName}';
    if ((selectedConnection != null &&
            selectedConnection!.id == currentUserData!.providerId) ||
        selectedConnection?.id == null) {
      authorName += ' (vous)';
    }

    return Card(
      margin: EdgeInsets.all(10.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(postUserData.profilePictureUrl),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      Text(
                        postUserData.occupation,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Text(
              post.text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (post.attachments.isNotEmpty) ...[
              SizedBox(height: 10.0),
              Image.network(post.attachments[0].url),
            ],
            SizedBox(height: 10.0),
            Row(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.thumb_up,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 5),
                    Text('${post.reactionCounter} likes'),
                  ],
                ),
                SizedBox(width: 20),
                Row(
                  children: [
                    Icon(
                      Icons.comment,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 5),
                    Text('${post.commentCounter} comments'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bar_chart,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 5),
                    Text('${post.impressionsCounter} impressions'),
                  ],
                ),
                SizedBox(width: 20),
                Row(
                  children: [
                    Icon(
                      Icons.repeat,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 5),
                    Text('${post.repostCounter} reposts'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDropdownHint() {
    if (selectedConnection != null) {
      if (selectedConnection!.id == currentUserData!.providerId) {
        return 'Mes posts';
      } else {
        return selectedConnection!.name;
      }
    } else {
      return 'Mes posts';
    }
  }
}
