class UserModel {
  final int? id;
  final String? username;
  final String? email;
  final int? userId;
  final String? role;

  UserModel({this.id, this.username, this.email, this.userId, this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      userId: json['userId'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'userId': userId,
      'role': role,
    };
  }
}
