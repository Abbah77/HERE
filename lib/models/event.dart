import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';


enum EventStatus { upcoming, ongoing, past }

class Event {
  final String id;
  final String title;
  final String organizer;
  final String organizerImage;
  final String? eventImage;
  final DateTime dateTime;
  final String location;
  final LatLng? coordinates;
  final String description;
  final int attendees;
  final int maxAttendees;
  final List<String> attendeeImages;
  final List<String> attendeeNames;
  final bool isAttending;
  final EventStatus status;
  final List<String> tags;

  const Event({
    required this.id,
    required this.title,
    required this.organizer,
    required this.organizerImage,
    this.eventImage,
    required this.dateTime,
    required this.location,
    this.coordinates,
    required this.description,
    required this.attendees,
    required this.maxAttendees,
    required this.attendeeImages,
    required this.attendeeNames,
    this.isAttending = false,
    required this.status,
    this.tags = const [],
  });

  // Helper getters
  String get formattedDate {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return '${days[dateTime.weekday - 1]} ${dateTime.day}, ${months[dateTime.month - 1]} ${dateTime.year}, at ${dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12}${dateTime.hour >= 12 ? 'PM' : 'AM'}';
  }

  String get timeUntil {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays > 0) {
      return 'In ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Now';
    }
  }

  String get attendeesText {
    if (attendees == maxAttendees) {
      return 'Full';
    } else {
      return '$attendees/$maxAttendees attending';
    }
  }

  bool get isFree => maxAttendees == 0;

  Color get statusColor {
    switch (status) {
      case EventStatus.ongoing:
        return Colors.green;
      case EventStatus.upcoming:
        return Colors.orange;
      case EventStatus.past:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case EventStatus.ongoing:
        return 'Ongoing';
      case EventStatus.upcoming:
        return 'Upcoming';
      case EventStatus.past:
        return 'Past';
    }
  }

  Event copyWith({
    String? id,
    String? title,
    String? organizer,
    String? organizerImage,
    String? eventImage,
    DateTime? dateTime,
    String? location,
    LatLng? coordinates,
    String? description,
    int? attendees,
    int? maxAttendees,
    List<String>? attendeeImages,
    List<String>? attendeeNames,
    bool? isAttending,
    EventStatus? status,
    List<String>? tags,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      organizer: organizer ?? this.organizer,
      organizerImage: organizerImage ?? this.organizerImage,
      eventImage: eventImage ?? this.eventImage,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      coordinates: coordinates ?? this.coordinates,
      description: description ?? this.description,
      attendees: attendees ?? this.attendees,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      attendeeImages: attendeeImages ?? this.attendeeImages,
      attendeeNames: attendeeNames ?? this.attendeeNames,
      isAttending: isAttending ?? this.isAttending,
      status: status ?? this.status,
      tags: tags ?? this.tags,
    );
  }
}