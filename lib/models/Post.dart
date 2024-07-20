class Post {
  final String date;
  final DateTime parsedDatetime;
  final int commentCounter;
  final int impressionsCounter;
  final int reactionCounter;
  final int repostCounter;
  final String text;
  final List<Attachment> attachments;
  final Author author;
  final String id;

  Post({
    required this.date,
    required this.parsedDatetime,
    required this.commentCounter,
    required this.impressionsCounter,
    required this.reactionCounter,
    required this.repostCounter,
    required this.text,
    required this.attachments,
    required this.author,
    required this.id,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      date: json['date'] ?? '',
      parsedDatetime: DateTime.parse(json['parsed_datetime']),
      commentCounter: json['comment_counter'] ?? 0,
      impressionsCounter: json['impressions_counter'] ?? 0,
      reactionCounter: json['reaction_counter'] ?? 0,
      repostCounter: json['repost_counter'] ?? 0,
      text: json['text'] ?? '',
      attachments: (json['attachments'] as List<dynamic>)
          .map((attachmentJson) => Attachment.fromJson(attachmentJson))
          .toList(),
      author: Author.fromJson(json['author']),
      id: json['id'] ?? '',
    );
  }
}
class Author {
  final String publicIdentifier;
  final String name;
  final bool isCompany;
  final String headline;

  Author({
    required this.publicIdentifier,
    required this.name,
    required this.isCompany,
    required this.headline,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      publicIdentifier: json['public_identifier'] ?? '',
      name: json['name'] ?? '',
      isCompany: json['is_company'] ?? false,
      headline: json['headline'] ?? '',
    );
  }
}
class Attachment {
  final String id;
  final bool sticker;
  final Size size;
  final bool unavailable;
  final String type;
  final String url;

  Attachment({
    required this.id,
    required this.sticker,
    required this.size,
    required this.unavailable,
    required this.type,
    required this.url,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] ?? '',
      sticker: json['sticker'] ?? false,
      size: Size(
        height: json['size']['height'] ?? 0,
        width: json['size']['width'] ?? 0,
      ),
      unavailable: json['unavailable'] ?? false,
      type: json['type'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class Size {
  final int height;
  final int width;

  Size({
    required this.height,
    required this.width,
  });
}
