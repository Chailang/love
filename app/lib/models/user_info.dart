/// 用户信息模型
class UserInfo {
  final int id;
  final String? nickname;
  final String? avatar;
  final String? gender;
  final String? birthDate;
  final String? city;
  final String? school;
  final String? education;
  final String? occupation;
  final int? height;
  final String? salaryRange;
  final String? bio;
  final bool educationVerified;
  final bool realNameVerified;
  final int profileCompleteness;
  final String status;

  UserInfo({
    required this.id,
    this.nickname,
    this.avatar,
    this.gender,
    this.birthDate,
    this.city,
    this.school,
    this.education,
    this.occupation,
    this.height,
    this.salaryRange,
    this.bio,
    this.educationVerified = false,
    this.realNameVerified = false,
    this.profileCompleteness = 0,
    this.status = 'INCOMPLETE',
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        id: json['id'] as int,
        nickname: json['nickname'] as String?,
        avatar: json['avatar'] as String?,
        gender: json['gender'] as String?,
        birthDate: json['birthDate'] != null ? json['birthDate'].toString().substring(0, 10) : null,
        city: json['city'] as String?,
        school: json['school'] as String?,
        education: json['education'] as String?,
        occupation: json['occupation'] as String?,
        height: json['height'] as int?,
        salaryRange: json['salaryRange'] as String?,
        bio: json['bio'] as String?,
        educationVerified: json['educationVerified'] ?? false,
        realNameVerified: json['realNameVerified'] ?? false,
        profileCompleteness: json['profileCompleteness'] ?? 0,
        status: json['status'] ?? 'INCOMPLETE',
      );

  int? get age {
    if (birthDate == null) return null;
    final birth = DateTime.parse(birthDate!);
    final now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age;
  }
}