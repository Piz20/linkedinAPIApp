class User {
  final String sub;

  final String givenName;
  final String familyName;
  final String name;

  final String email;
  final String picture;
  final String token;

  User({
    required this.sub,
    required this.givenName,
    required this.familyName,
    required this.name,
    required this.email,
    required this.picture,
    required this.token,
  });

  // Convert a User instance to a Map
  Map<String, String?> toMap() {
    return {
      'sub': sub,
      'givenName': givenName,
      'familyName': familyName,
      'name': name,
      'email': email,
      'picture': picture,
      'token': token,
    };
  }
  String get allInfo {
    return '''
      sub: $sub
      givenName: $givenName
      familyName: $familyName
      name: $name
      email: $email
      picture: $picture
      token: $token
    ''';
  }
}
