import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum MessageStatus { sending, sent, delivered, read, error }
enum MessageType { text, image, video, file, audio }
enum ChatType { individual, group }

class ChatUser {
  final String id, name, avatar;
  final bool isOnline, isTyping;
  ChatUser({required this.id, required this.name, required this.avatar, this.isOnline = false, this.isTyping = false});
}

class Message {
  final String id, chatId, senderId, senderName, senderAvatar, content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final bool isMe;
  final String? replyToContent, replyToUser;

  Message({
    required this.id, required this.chatId, required this.senderId, required this.senderName,
    required this.senderAvatar, required this.content, required this.type, required this.status,
    required this.timestamp, required this.isMe, this.replyToContent, this.replyToUser,
  });

  // Required for the AI Typewriter effect
  Message copyWith({String? content, MessageStatus? status}) => Message(
    id: id, chatId: chatId, senderId: senderId, senderName: senderName,
    senderAvatar: senderAvatar, content: content ?? this.content, type: type,
    status: status ?? this.status, timestamp: timestamp, isMe: isMe,
    replyToContent: replyToContent, replyToUser: replyToUser,
  );

  Map<String, dynamic> toJson() => {
    'role': isMe ? 'user' : 'assistant',
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Message.fromJson(Map<String, dynamic> json, String chatId) => Message(
    id: json['timestamp'], chatId: chatId, 
    senderId: json['role'], senderName: json['role'] == 'user' ? 'You' : 'Here AI',
    senderAvatar: json['role'] == 'user' ? '' : 'assets/images/logo.png',
    content: json['content'], type: MessageType.text, status: MessageStatus.read,
    timestamp: DateTime.parse(json['timestamp']), isMe: json['role'] == 'user',
  );
}

class Chat {
  final String id, name, avatar;
  final ChatType type;
  final List<ChatUser> participants;
  final Message lastMessage;
  final int unreadCount;
  final bool isPinned;

  Chat({
    required this.id, required this.name, required this.avatar, required this.type,
    required this.participants, required this.lastMessage, this.unreadCount = 0, this.isPinned = false,
  });

  Chat copyWith({Message? lastMessage, int? unreadCount}) => Chat(
    id: id, name: name, avatar: avatar, type: type, participants: participants,
    lastMessage: lastMessage ?? this.lastMessage, unreadCount: unreadCount ?? this.unreadCount, isPinned: isPinned,
  );
}

class ChatProvider with ChangeNotifier {
  List<Chat> _chats = [];
  final Map<String, List<Message>> _messages = {};
  bool _isLoading = false;
  bool _isAILoading = false; // For AI thinking state
  Message? _replyingTo;

  List<Chat> get chats => _chats;
  bool get isLoading => _isLoading;
  bool get isAILoading => _isAILoading;
  Message? get replyingTo => _replyingTo;

  static const String _aiChatId = 'ai_assistant';
  static const String _aiStoreKey = 'here_ai_sessions';

  // --- AI INTEGRATION (DEMO LOGIC) ---

  Future<void> sendAIMessage(String content) async {
    _isAILoading = true;
    notifyListeners();

    final userMsg = Message(
      id: DateTime.now().toIso8601String(), chatId: _aiChatId, senderId: 'user', senderName: 'You',
      senderAvatar: '', content: content, type: MessageType.text, status: MessageStatus.sent,
      timestamp: DateTime.now(), isMe: true,
    );

    _messages[_aiChatId] ??= [];
    _messages[_aiChatId]!.insert(0, userMsg);
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("https://decodernet-servers.onrender.com/ReCore/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(_messages[_aiChatId]!.reversed.map((e) => e.toJson()).toList()),
      );

      final aiText = jsonDecode(response.body)['response'] ?? "";

      // Add empty AI bubble
      final aiMsg = Message(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}', chatId: _aiChatId, senderId: 'assistant',
        senderName: 'Here AI', senderAvatar: 'assets/images/logo.png', content: '', 
        type: MessageType.text, status: MessageStatus.read, timestamp: DateTime.now(), isMe: false,
      );
      _messages[_aiChatId]!.insert(0, aiMsg);
      _isAILoading = false;

      // Typewriter Effect
      for (int i = 0; i < aiText.length; i++) {
        _messages[_aiChatId]![0] = _messages[_aiChatId]![0].copyWith(
          content: _messages[_aiChatId]![0].content + aiText[i]
        );
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 5));
      }
      
      _saveAIHistory();
    } catch (e) {
      _isAILoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveAIHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = _messages[_aiChatId]?.map((e) => e.toJson()).toList() ?? [];
    await prefs.setString(_aiStoreKey, jsonEncode(history));
  }

  Future<void> loadAIHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_aiStoreKey);
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      _messages[_aiChatId] = decoded.map((e) => Message.fromJson(e, _aiChatId)).toList();
      notifyListeners();
    }
  }

  // --- STANDARD CHAT LOGIC ---

  Future<void> loadChats() async {
    _isLoading = true;
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate DB
    _chats = _genMocks();
    _isLoading = false;
    notifyListeners();
  }

  Future<List<Message>> loadMessages(String chatId) async {
    return _messages[chatId] ?? [];
  }

  Future<void> sendMessage({required String chatId, required String content}) async {
    final msg = Message(
      id: DateTime.now().toString(), chatId: chatId, senderId: 'me', senderName: 'You',
      senderAvatar: '', content: content, type: MessageType.text, status: MessageStatus.sending,
      timestamp: DateTime.now(), isMe: true, replyToContent: _replyingTo?.content, replyToUser: _replyingTo?.senderName,
    );
    
    _messages[chatId] ??= [];
    _messages[chatId]!.insert(0, msg);
    
    final idx = _chats.indexWhere((c) => c.id == chatId);
    if (idx != -1) {
      _chats[idx] = _chats[idx].copyWith(lastMessage: msg, unreadCount: 0);
      final c = _chats.removeAt(idx);
      _chats.insert(0, c);
    }
    _replyingTo = null;
    notifyListeners();
  }

  void setReplyMessage(Message? message) {
    _replyingTo = message;
    notifyListeners();
  }

  void markAsRead(String chatId) {
    final idx = _chats.indexWhere((c) => c.id == chatId);
    if (idx != -1) { _chats[idx] = _chats[idx].copyWith(unreadCount: 0); notifyListeners(); }
  }

  List<Chat> searchChats(String query) {
    if (query.isEmpty) return _chats;
    return _chats.where((c) => c.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  List<Chat> _genMocks() => [
    Chat(
      id: 'c1', type: ChatType.individual, name: 'Emma Watson', avatar: 'https://i.pravatar.cc/150?u=emma',
      isPinned: true, participants: [ChatUser(id: 'u2', name: 'Emma', avatar: '')],
      lastMessage: Message(id: 'm1', chatId: 'c1', senderId: 'u2', senderName: 'Emma', senderAvatar: '', content: 'Did you see the new design?', type: MessageType.text, status: MessageStatus.read, timestamp: DateTime.now(), isMe: false),
    ),
    Chat(
      id: 'c2', type: ChatType.group, name: 'Core Team', avatar: 'https://i.pravatar.cc/150?u=team',
      participants: [], 
      lastMessage: Message(id: 'm2', chatId: 'c2', senderId: 'u3', senderName: 'John', senderAvatar: '', content: 'Meeting at 10?', type: MessageType.text, status: MessageStatus.read, timestamp: DateTime.now(), isMe: false),
    ),
  ];
}
