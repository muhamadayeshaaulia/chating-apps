import '../models/chat_models.dart';

abstract class ChatRepository {
  Future<String> getOrCreateDirectRoom({
    required String myUserId,
    required String targetUserId,
  });

  Future<String> createGroup({
    required String groupName,
    required String creatorUserId,
    required List<String> initialMemberIds,
  });

  Future<void> addMemberToGroup({
    required String roomId,
    required String newUserId,
    String role = 'member',
  });

  Future<void> removeMemberFromGroup({
    required String roomId,
    required String userId,
  });

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String content,
  });

  Stream<List<ChatMessage>> streamMessages(String roomId);

  Future<List<Map<String, dynamic>>> getRoomMembers(String roomId);
}
