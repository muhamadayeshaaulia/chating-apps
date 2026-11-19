class UserProfile {
  final String id;
  final String username;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      username: map['username'] as String? ?? 'Pengguna',
      avatarUrl: map['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
    };
  }
}

class ChatRoom {
  final String id;
  final String type; // 'direct' atau 'group'
  final String? name; // Nama grup
  final String? avatarUrl;
  final String? createdBy;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.type,
    this.name,
    this.avatarUrl,
    this.createdBy,
    required this.createdAt,
  });

  bool get isGroup => type == 'group';
  bool get isDirect => type == 'direct';

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'] as String,
      type: map['type'] as String,
      name: map['name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      createdBy: map['created_by'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class RoomMember {
  final String id;
  final String roomId;
  final String userId;
  final String role; // 'admin' atau 'member'
  final DateTime joinedAt;

  RoomMember({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  factory RoomMember.fromMap(Map<String, dynamic> map) {
    return RoomMember(
      id: map['id'] as String,
      roomId: map['room_id'] as String,
      userId: map['user_id'] as String,
      role: map['role'] as String? ?? 'member',
      joinedAt: DateTime.parse(map['joined_at'] as String),
    );
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      roomId: map['room_id'] as String,
      senderId: map['sender_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'room_id': roomId,
      'sender_id': senderId,
      'content': content,
    };
  }
}
