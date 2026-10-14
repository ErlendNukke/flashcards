class AppUser {
  AppUser({required this.id, required this.username});

  final String id;
  final String username;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'username': username};
}
