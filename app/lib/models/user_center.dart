/// 用户中心聚合数据
class UserCenter {
  final int userId;
  final String? nickname;
  final String? avatar;
  final String? gender;
  final int? age;
  final String? city;
  final String? school;
  final String? education;
  final String? occupation;
  final int? height;
  final String? salaryRange;
  final String? bio;
  final bool realNameVerified;
  final bool educationVerified;
  final int profileCompleteness;
  final String status;
  final int likedCount;
  final int likedByCount;
  final int matchCount;
  final bool readReceipt;
  final bool locationVisible;
  final bool onlineVisible;
  final bool allowStrangerChat;
  final bool onlineAlert;

  UserCenter({
    required this.userId,
    this.nickname,
    this.avatar,
    this.gender,
    this.age,
    this.city,
    this.school,
    this.education,
    this.occupation,
    this.height,
    this.salaryRange,
    this.bio,
    this.realNameVerified = false,
    this.educationVerified = false,
    this.profileCompleteness = 0,
    this.status = 'INCOMPLETE',
    this.likedCount = 0,
    this.likedByCount = 0,
    this.matchCount = 0,
    this.readReceipt = true,
    this.locationVisible = true,
    this.onlineVisible = true,
    this.allowStrangerChat = false,
    this.onlineAlert = false,
  });

  factory UserCenter.fromJson(Map<String, dynamic> json) => UserCenter(
        userId: json['userId'] as int,
        nickname: json['nickname'] as String?,
        avatar: json['avatar'] as String?,
        gender: json['gender'] as String?,
        age: json['age'] as int?,
        city: json['city'] as String?,
        school: json['school'] as String?,
        education: json['education'] as String?,
        occupation: json['occupation'] as String?,
        height: json['height'] as int?,
        salaryRange: json['salaryRange'] as String?,
        bio: json['bio'] as String?,
        realNameVerified: json['realNameVerified'] ?? false,
        educationVerified: json['educationVerified'] ?? false,
        profileCompleteness: json['profileCompleteness'] ?? 0,
        status: json['status'] ?? 'INCOMPLETE',
        likedCount: json['likedCount'] ?? 0,
        likedByCount: json['likedByCount'] ?? 0,
        matchCount: json['matchCount'] ?? 0,
        readReceipt: json['readReceipt'] ?? true,
        locationVisible: json['locationVisible'] ?? true,
        onlineVisible: json['onlineVisible'] ?? true,
        allowStrangerChat: json['allowStrangerChat'] ?? false,
        onlineAlert: json['onlineAlert'] ?? false,
      );
}