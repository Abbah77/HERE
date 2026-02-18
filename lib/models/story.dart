import 'package:flutter/material.dart';

enum StoryMediaType { image, video, text }

class Story {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String mediaUrl;
  final StoryMediaType mediaType;
  final String? caption;
  final String? color;
  final DateTime timestamp; // Standardized to timestamp
  final bool isViewed;
  final bool isMyStory;

  Story({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.mediaUrl,
    required this.mediaType,
    this.caption,
    this.color,
    required this.timestamp,
    this.isViewed = false,
    this.isMyStory = false,
  });

  // Rule: Must handle string to DateTime conversion for the Mock Data
  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userImage: json['userImage'],
      mediaUrl: json['mediaUrl'] ?? '',
      mediaType: _parseMediaType(json['mediaType']),
      caption: json['caption'],
      color: json['color'],
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      isViewed: json['isViewed'] ?? false,
      isMyStory: json['isMyStory'] ?? false,
    );
  }

  static StoryMediaType _parseMediaType(String? type) {
    switch (type) {
      case 'video': return StoryMediaType.video;
      case 'text': return StoryMediaType.text;
      default: return StoryMediaType.image;
    }
  }

  // Rule: Required for updating 'isViewed' state in the Provider
  Story copyWith({bool? isViewed}) {
    return Story(
      id: id,
      userId: userId,
      userName: userName,
      userImage: userImage,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      caption: caption,
      color: color,
      timestamp: timestamp,
      isViewed: isViewed ?? this.isViewed,
      isMyStory: isMyStory,
    );
  }
}
