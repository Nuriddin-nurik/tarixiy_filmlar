class UserModel {
  final int? id;
  final String? username;
  final String? email;
  final int? userId;
  final String? role;
  final int? telegramChatId;
  final String? telegramUsername;

  UserModel({
    this.id,
    this.username,
    this.email,
    this.userId,
    this.role,
    this.telegramChatId,
    this.telegramUsername,
  });

  bool get isTelegramAccount => email?.endsWith('@telegram.tarixiykinolar.uz') ?? false;

  String? get displayContact {
    if (!isTelegramAccount) return email;
    if (telegramUsername != null && telegramUsername!.isNotEmpty) return '@$telegramUsername';
    if (telegramChatId != null) return 'Telegram ID: $telegramChatId';
    return null;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      userId: json['userId'],
      role: json['role'],
      telegramChatId: json['telegramChatId'],
      telegramUsername: json['telegramUsername'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'userId': userId,
      'role': role,
      'telegramChatId': telegramChatId,
      'telegramUsername': telegramUsername,
    };
  }
}
