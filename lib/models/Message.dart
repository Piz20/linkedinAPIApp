//Class that represents messages , messages are contained in a chatroom
class Message {
  final String id;
  final String chatId;
  final DateTime timestamp;
  final String senderId;
  final String text;

  Message({
    required this.id,
    required this.chatId,
    required this.timestamp,
    required this.senderId,
    required this.text,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatId: json['chat_id'],
      timestamp: DateTime.parse(json['timestamp']),
      senderId: json['sender_id'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'timestamp': timestamp.toIso8601String(),
      'sender_id': senderId,
      'text': text,
    };
  }

  String get allInfo {
    return '''
      id: $id
      chatId: $chatId
      timestamp: $timestamp
      senderId: $senderId
      text: $text
    ''';
  }
}
