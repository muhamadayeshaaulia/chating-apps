import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/chat_models.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final SupabaseClient _supabase;

  ChatRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<String> getOrCreateDirectRoom({
    required String myUserId,
    required String targetUserId,
  }) async {
    final existingRoom = await _findExistingDirectRoom(myUserId, targetUserId);
    if (existingRoom != null) {
      return existingRoom;
    }

    final roomResponse = await _supabase
        .from('rooms')
        .insert({
          'type': 'direct',
          'created_by': myUserId,
        })
        .select('id')
        .single();

    final newRoomId = roomResponse['id'] as String;

    await _supabase.from('room_members').insert([
      {'room_id': newRoomId, 'user_id': myUserId, 'role': 'member'},
      {'room_id': newRoomId, 'user_id': targetUserId, 'role': 'member'},
    ]);

    return newRoomId;
  }

  Future<String?> _findExistingDirectRoom(String userA, String userB) async {
    final userARooms = await _supabase
        .from('room_members')
        .select('room_id, rooms!inner(type)')
        .eq('user_id', userA)
        .eq('rooms.type', 'direct');

    final roomIds = (userARooms as List).map((r) => r['room_id'] as String).toList();
    if (roomIds.isEmpty) return null;

    final match = await _supabase
        .from('room_members')
        .select('room_id')
        .eq('user_id', userB)
        .filter('room_id', 'in', roomIds)
        .maybeSingle();

    return match != null ? match['room_id'] as String : null;
  }

  @override
  Future<String> createGroup({
    required String groupName,
    required String creatorUserId,
    required List<String> initialMemberIds,
  }) async {
    final roomResponse = await _supabase
        .from('rooms')
        .insert({
          'type': 'group',
          'name': groupName,
          'created_by': creatorUserId,
        })
        .select('id')
        .single();

    final newRoomId = roomResponse['id'] as String;

    final membersToInsert = <Map<String, dynamic>>[
      {
        'room_id': newRoomId,
        'user_id': creatorUserId,
        'role': 'admin',
      }
    ];

    for (final memberId in initialMemberIds) {
      if (memberId != creatorUserId) {
        membersToInsert.add({
          'room_id': newRoomId,
          'user_id': memberId,
          'role': 'member',
        });
      }
    }

    await _supabase.from('room_members').insert(membersToInsert);

    return newRoomId;
  }

  @override
  Future<void> addMemberToGroup({
    required String roomId,
    required String newUserId,
    String role = 'member',
  }) async {
    await _supabase.from('room_members').insert({
      'room_id': roomId,
      'user_id': newUserId,
      'role': role,
    });
  }

  @override
  Future<void> removeMemberFromGroup({
    required String roomId,
    required String userId,
  }) async {
    await _supabase
        .from('room_members')
        .delete()
        .eq('room_id', roomId)
        .eq('user_id', userId);
  }

  @override
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String content,
  }) async {
    await _supabase.from('messages').insert({
      'room_id': roomId,
      'sender_id': senderId,
      'content': content,
    });
  }

  @override
  Stream<List<ChatMessage>> streamMessages(String roomId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: true)
        .map((data) => data.map((json) => ChatMessage.fromMap(json)).toList());
  }

  @override
  Future<List<Map<String, dynamic>>> getRoomMembers(String roomId) async {
    final response = await _supabase
        .from('room_members')
        .select('user_id, role, joined_at, profiles(username, avatar_url)')
        .eq('room_id', roomId);

    return List<Map<String, dynamic>>.from(response);
  }
}
