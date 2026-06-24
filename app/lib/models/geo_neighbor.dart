/// 同乡近邻匹配结果
class GeoNeighbor {
  final int userId;
  final String? nickname;
  final String? avatar;
  final int? age;
  final String? education;
  final String? hometownMatch;
  final String? workMatch;
  final String? residenceMatch;
  final String? matchLabel;
  final String? distance;
  final int score;

  GeoNeighbor({
    required this.userId,
    this.nickname,
    this.avatar,
    this.age,
    this.education,
    this.hometownMatch,
    this.workMatch,
    this.residenceMatch,
    this.matchLabel,
    this.distance,
    required this.score,
  });

  factory GeoNeighbor.fromJson(Map<String, dynamic> json) => GeoNeighbor(
        userId: json['userId'] as int,
        nickname: json['nickname'] as String?,
        avatar: json['avatar'] as String?,
        age: json['age'] as int?,
        education: json['education'] as String?,
        hometownMatch: json['hometownMatch'] as String?,
        workMatch: json['workMatch'] as String?,
        residenceMatch: json['residenceMatch'] as String?,
        matchLabel: json['matchLabel'] as String?,
        distance: json['distance'] as String?,
        score: json['score'] as int,
      );
}