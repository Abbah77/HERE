class User {
  final String id;
  final String name;
  final String email;
  final String profileImage;
  final String bio;
  final int followers;
  final int following;
  final int posts;
  
  // Add optional fields that might be useful
  final bool? isVerified;
  final DateTime? createdAt;
  final DateTime? lastActive;

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
  });

  // CopyWith method for easy updates
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
    );
  }

  // Factory constructor from JSON with null safety
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

  // Helper getters
  bool get hasProfileImage => profileImage.isNotEmpty;
  bool get hasBio => bio.isNotEmpty;
  String get initials => name.isNotEmpty 
      ? name.split(' ').map((e) => e[0]).take(2).join().toUpperCase() 
      : '?';

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode;
}