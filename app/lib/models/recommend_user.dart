/// 推荐用户卡片数据
class RecommendUser {
  final int userId;
  final String? nickname;
  final String? avatar;
  final int? age;
  final String? city;
  final String? education;
  final String? school;
  final String? occupation;
  final int? height;
  final String? bio;
  final List<String> tags;

  RecommendUser({
    required this.userId,
    this.nickname,
    this.avatar,
    this.age,
    this.city,
    this.education,
    this.school,
    this.occupation,
    this.height,
    this.bio,
    this.tags = const [],
  });

  factory RecommendUser.fromJson(Map<String, dynamic> json) => RecommendUser(
        userId: json['id'] as int,
        nickname: json['nickname'] as String?,
        avatar: json['avatar'] as String?,
        age: _calcAge(json['birthDate']),
        city: json['city'] as String?,
        education: json['education'] as String?,
        school: json['school'] as String?,
        occupation: json['occupation'] as String?,
        height: json['height'] as int?,
        bio: json['bio'] as String?,
        tags: _extractTags(json),
      );

  static int? _calcAge(dynamic birthDate) {
    if (birthDate == null) return null;
    final dt = DateTime.tryParse(birthDate.toString().substring(0, 10));
    if (dt == null) return null;
    final now = DateTime.now();
    int age = now.year - dt.year;
    if (now.month < dt.month || (now.month == dt.month && now.day < dt.day)) {
      age--;
    }
    return age;
  }

  static List<String> _extractTags(Map<String, dynamic> json) {
    final tags = <String>[];
    if (json['education'] != null) tags.add(json['education']);
    if (json['occupation'] != null) tags.add(json['occupation']);
    if (json['city'] != null) tags.add(json['city']);
    if (json['school'] != null) tags.add(json['school']);
    if (json['constellation'] != null) tags.add(json['constellation']);
    return tags;
  }
}