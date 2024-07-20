//This class represents a Chat , a chat is a container for messages
class Chat {
  final String id;
  final String accountId;
  final String attendeeId;
  final int unreadCount;

  Chat({
    required this.id,
    required this.accountId,
    required this.attendeeId,
    required this.unreadCount,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      accountId: json['account_id'],
      attendeeId: json['attendee_provider_id'],
      unreadCount: json['unread_count'] ?? 0, // Default to 0 if unread_count is null
    );
  }


  String get allInfo {
    return '''
      id: $id
      accountId: $accountId
      attendeeId: $attendeeId
      unreadCount: $unreadCount
    ''';
  }


}
