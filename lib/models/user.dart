class User {
  final int? id;
  final String email;
  final String username;
  final String? role;

  User({this.id, required this.email, required this.username, this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'username': username, 'role': role};
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, username: $username, role: $role)';
  }
}

