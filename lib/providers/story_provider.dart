import 'package:flutter/material.dart';
import 'package:here/models/story.dart';

enum StoryStatus { initial, loading, loaded, error }

class StoryProvider with ChangeNotifier {
  List<Story> _stories = [];
  StoryStatus _status = StoryStatus.initial;
  String? _errorMessage;

  // Getters
  List<Story> get stories => List.unmodifiable(_stories);
  StoryStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == StoryStatus.loading;
  bool get hasError => _status == StoryStatus.error;

  // --- NEW: ADD STORY LOGIC (Fixes Codemagic Error) ---
  
  /// Rule: Adds a new story to the local list and notifies listeners.
  /// Returns true if successful.
  Future<bool> addStory({
    required String mediaUrl,
    required StoryMediaType mediaType,
    required String caption,
    required String color,
  }) async {
    try {
      // Create the new story object
      final newStory = Story(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user', // Matches mock data ID
        userName: 'Allan Paterson', 
        userImage: 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        caption: caption,
        color: color,
        createdAt: DateTime.now(), // Use createdAt to match model
        isViewed: true, // Your own stories are seen by you immediately
        isMyStory: true,
      );

      // Add to beginning of list
      _stories.insert(0, newStory);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding story: $e');
      return false;
    }
  }

  // --- BUSINESS LOGIC ---

  List<MapEntry<String, List<Story>>> getStoriesGroupedByUser() {
    final Map<String, List<Story>> grouped = {};

    for (var story in _stories) {
      grouped.putIfAbsent(story.userId, () => []).add(story);
    }

    // Sort individual user story stacks by time (newest first)
    for (var list in grouped.values) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    final entries = grouped.entries.toList();

    entries.sort((a, b) {
      final aFirst = a.value.first;
      final bFirst = b.value.first;
      
      if (aFirst.isMyStory) return -1;
      if (bFirst.isMyStory) return 1;
      
      return bFirst.createdAt.compareTo(aFirst.createdAt);
    });

    return entries;
  }

  Future<void> loadStories() async {
    if (_status == StoryStatus.loading) return;

    _status = StoryStatus.loading;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 1200));
      _stories = _mockStoryData.map((data) => Story.fromJson(data)).toList();
      _status = StoryStatus.loaded;
    } catch (e) {
      _status = StoryStatus.error;
      _errorMessage = 'Failed to sync stories';
    } finally {
      notifyListeners();
    }
  }

  List<Story> getStoriesByUser(String userId) {
    return _stories.where((story) => story.userId == userId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  void markUserStoriesAsViewed(String userId) {
    bool updated = false;
    _stories = _stories.map((story) {
      if (story.userId == userId && !story.isViewed) {
        updated = true;
        return story.copyWith(isViewed: true);
      }
      return story;
    }).toList();

    if (updated) notifyListeners();
  }

  bool hasUnviewedStories(String userId) {
    return _stories.any((story) => story.userId == userId && !story.isViewed);
  }

  // --- MOCK DATA ---
  final List<Map<String, dynamic>> _mockStoryData = [
    {
      'id': '101',
      'userId': 'current_user',
      'userName': 'Allan Paterson',
      'userImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
      'mediaUrl': 'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg',
      'mediaType': 'image',
      'createdAt': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
      'isViewed': false,
      'isMyStory': true,
    },
    {
      'id': '102',
      'userId': 'friend_1',
      'userName': 'Emma Watson',
      'userImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'mediaUrl': 'https://images.pexels.com/photos/4264555/pexels-photo-4264555.jpeg',
      'mediaType': 'image',
      'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      'isViewed': false,
      'isMyStory': false,
    },
    {
      'id': '103',
      'userId': 'friend_2',
      'userName': 'Tom Holland',
      'userImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'mediaUrl': '',
      'mediaType': 'text',
      'caption': 'Working on something big! 🎬',
      'color': '0xFFFF6B6B',
      'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      'isViewed': true,
      'isMyStory': false,
    },
  ];
}
