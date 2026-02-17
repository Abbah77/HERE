enum UserStatus { online, offline, away, busy }

class User {
  final String id;
  final String name;
  final String email;
  final String profileImage;
  final String bio;
  final int followers;
  final int following;
  final int posts;
  final bool? isVerified;
  final DateTime? createdAt;
  final DateTime? lastActive;
  final UserStatus? status;
  final String? phoneNumber;
  final String? website;
  final String? location;
  final List<String>? interests;
  final Map<String, dynamic>? socialLinks;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.bio,
    required this.followers,
    required this.following,
    required this.posts,
    this.isVerified,
    this.createdAt,
    this.lastActive,
    this.status,
    this.phoneNumber,
    this.website,
    this.location,
    this.interests,
    this.socialLinks,
  });

  // Comprehensive copyWith method
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    String? bio,
    int? followers,
    int? following,
    int? posts,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastActive,
    UserStatus? status,
    String? phoneNumber,
    String? website,
    String? location,
    List<String>? interests,
    Map<String, dynamic>? socialLinks,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      posts: posts ?? this.posts,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      location: location ?? this.location,
      interests: interests ?? this.interests,
      socialLinks: socialLinks ?? this.socialLinks,
    );
  }

  // Factory constructor from JSON with improved null safety
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
      posts: json['posts'] as int? ?? 0,
      isVerified: json['isVerified'] as bool?,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'] as String) 
          : null,
      lastActive: json['lastActive'] != null 
          ? DateTime.tryParse(json['lastActive'] as String) 
          : null,
      status: json['status'] != null 
          ? UserStatus.values.firstWhere(
              (e) => e.toString() == 'UserStatus.${json['status']}',
              orElse: () => UserStatus.offline,
            )
          : null,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      location: json['location'] as String?,
      interests: json['interests'] != null 
          ? List<String>.from(json['interests'] as List)
          : null,
      socialLinks: json['socialLinks'] as Map<String, dynamic>?,
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'bio': bio,
      'followers': followers,
      'following': following,
      'posts': posts,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
      'status': status?.toString().split('.').last,
      'phoneNumber': phoneNumber,
      'website': website,
      'location': location,
      'interests': interests,
      'socialLinks': socialLinks,
    };
  }

  // Empty user for initial states
  static const User empty = User(
    id: '',
    name: '',
    email: '',
    profileImage: '',
    bio: '',
    followers: 0,
    following: 0,
    posts: 0,
  );

  // Mock user for development
  static User get mockUser => User(
    id: '1',
    name: 'Allan Paterson',
    email: 'allan@example.com',
    profileImage: 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
    bio: 'Flutter Developer | UI/UX Designer | Coffee Lover | Building awesome social experiences',
    followers: 1247,
    following: 892,
    posts: 156,
    isVerified: true,
    createdAt: DateTime(2024, 1, 1),
    lastActive: DateTime.now(),
    status: UserStatus.online,
    phoneNumber: '+1 234 567 890',
    website: 'allanpaterson.dev',
    location: 'San Francisco, CA',
    interests: ['Flutter', 'UI/UX', 'Photography', 'Travel', 'Coffee'],
    socialLinks: {
      'twitter': 'twitter.com/allan',
      'github': 'github.com/allan',
      'linkedin': 'linkedin.com/in/allan',
    },
  );

  // Helper getters
  bool get hasProfileImage => profileImage.isNotEmpty;
  bool get hasBio => bio.isNotEmpty;
  bool get hasPhone => phoneNumber?.isNotEmpty ?? false;
  bool get hasWebsite => website?.isNotEmpty ?? false;
  bool get hasLocation => location?.isNotEmpty ?? false;
  bool get hasInterests => interests?.isNotEmpty ?? false;
  
  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String get formattedFollowers {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
  }

  String get formattedFollowing {
    if (following >= 1000000) {
      return '${(following / 1000000).toStringAsFixed(1)}M';
    } else if (following >= 1000) {
      return '${(following / 1000).toStringAsFixed(1)}K';
    }
    return following.toString();
  }

  String get formattedPosts {
    if (posts >= 1000000) {
      return '${(posts / 1000000).toStringAsFixed(1)}M';
    } else if (posts >= 1000) {
      return '${(posts / 1000).toStringAsFixed(1)}K';
    }
    return posts.toString();
  }

  String get lastActiveText {
    if (status == UserStatus.online) return 'Online';
    if (lastActive == null) return 'Offline';
    
    final now = DateTime.now();
    final difference = now.difference(lastActive!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  String get memberSince {
    if (createdAt == null) return 'Unknown';
    return '${createdAt!.month}/${createdAt!.year}';
  }

  // Validation methods
  bool get isComplete => 
      id.isNotEmpty && 
      name.isNotEmpty && 
      email.isNotEmpty && 
      profileImage.isNotEmpty;

  bool get isNewUser => 
      posts == 0 && 
      followers == 0 && 
      following == 0;

  // Equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, status: $status)';
  }
}
