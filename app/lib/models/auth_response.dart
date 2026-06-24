/// 认证响应 + Token 管理
class AuthResponse {
  final String token;
  final int userId;
  final String phone;
  final String? nickname;
  final String? avatar;
  final bool educationVerified;
  final bool realNameVerified;
  final String status;
  final int profileCompleteness;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.phone,
    this.nickname,
    this.avatar,
    this.educationVerified = false,
    this.realNameVerified = false,
    this.status = 'INCOMPLETE',
    this.profileCompleteness = 0,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'] as String,
        userId: json['userId'] as int,
        phone: json['phone'] as String,
        nickname: json['nickname'] as String?,
        avatar: json['avatar'] as String?,
        educationVerified: json['educationVerified'] ?? false,
        realNameVerified: json['realNameVerified'] ?? false,
        status: json['status'] ?? 'INCOMPLETE',
        profileCompleteness: json['profileCompleteness'] ?? 0,
      );
}