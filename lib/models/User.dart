//This class represents an user
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

class UserData {
  final String providerId;
  final String firstName;
  final String lastName;
  final String profilePictureUrl;
  final String occupation;
  final String? location;
  final String? email;

  UserData({
    required this.providerId,
    required this.firstName,
    required this.lastName,
    required this.profilePictureUrl,
    required this.occupation,
    this.location,
    this.email,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      providerId: json['provider_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profilePictureUrl: json['profile_picture_url'],
      occupation: json['occupation'],
      location: json['location'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider_id': providerId,
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture_url': profilePictureUrl,
      'occupation': occupation,
      'location': location,
      'email': email,
    };
  }

  String getAllInfo() {
    return '''
   
    provider_id: $providerId,
    first_name: $firstName,
    last_name: $lastName,
    profile_picture_url: $profilePictureUrl,
   
    occupation: $occupation,
    location: $location,
    email: $email
    ''';
  }
}
