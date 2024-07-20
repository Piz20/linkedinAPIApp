import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// This class represents Connection , Connection is a "user seen by the current user" as a friend for example
class Connection {
  final String id;
  final String givenName;
  final String familyName;
  final String name;
  final String headline;
  final String picture;

  Connection({
    required this.id,
    required this.givenName,
    required this.familyName,
    required this.name,
    required this.headline, required this.picture,
  });

  // Convert a Connection instance to a Map
  Map<String, String> toMap() {
    return {
      'id': id,
      'givenName': givenName,
      'familyName': familyName,
      'name': name,
      'headline': headline,
      'picture': picture,
    };
  }

  // Factory method to create a Connection instance from a JSON object
  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['member_id'] ?? '',
      givenName: json['first_name'] ?? '',
      familyName: json['last_name'] ?? '',
      name: json['first_name']+" "+json["last_name"] ?? '',
      headline: json['headline'] ?? '',
      picture: json['profile_picture_url'] ?? '',
    );
  }

  String get allInfo {
    return '''
      id: $id
      givenName: $givenName
      familyName: $familyName
      name: $name
      headline: $headline
      picture: $picture
    ''';
  }

}
