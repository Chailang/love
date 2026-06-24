/// 缘分盲盒抽奖结果
class KarmaResult {
  final String actionType;
  final String rarity;
  final int? matchedUserId;
  final String? matchedNickname;
  final String? matchedAvatar;
  final int? diceValue;
  final int coinBalance;
  final int pityCounter;
  final bool isSSR;
  final String description;

  KarmaResult({
    required this.actionType,
    required this.rarity,
    this.matchedUserId,
    this.matchedNickname,
    this.matchedAvatar,
    this.diceValue,
    required this.coinBalance,
    required this.pityCounter,
    required this.isSSR,
    required this.description,
  });

  factory KarmaResult.fromJson(Map<String, dynamic> json) => KarmaResult(
        actionType: json['actionType'] as String,
        rarity: json['rarity'] as String,
        matchedUserId: json['matchedUserId'] as int?,
        matchedNickname: json['matchedNickname'] as String?,
        matchedAvatar: json['matchedAvatar'] as String?,
        diceValue: json['diceValue'] as int?,
        coinBalance: json['coinBalance'] as int,
        pityCounter: json['pityCounter'] as int,
        isSSR: json['isSSR'] ?? false,
        description: json['description'] as String,
      );
}

/// 缘分币账户
class KarmaAccount {
  final int userId;
  final int balance;
  final int totalEarned;
  final int totalSpent;
  final int pityCounter;
  final int dailyBlindUsed;
  final int dailyDiceUsed;
  final int dailyGachaUsed;
  final bool ssrBoostActive;

  KarmaAccount({
    required this.userId,
    required this.balance,
    required this.totalEarned,
    required this.totalSpent,
    required this.pityCounter,
    required this.dailyBlindUsed,
    required this.dailyDiceUsed,
    required this.dailyGachaUsed,
    this.ssrBoostActive = false,
  });

  factory KarmaAccount.fromJson(Map<String, dynamic> json) => KarmaAccount(
        userId: json['userId'] as int,
        balance: json['balance'] as int,
        totalEarned: json['totalEarned'] as int,
        totalSpent: json['totalSpent'] as int,
        pityCounter: json['pityCounter'] as int,
        dailyBlindUsed: json['dailyBlindUsed'] as int,
        dailyDiceUsed: json['dailyDiceUsed'] as int,
        dailyGachaUsed: json['dailyGachaUsed'] as int,
        ssrBoostActive: json['ssrBoostActive'] ?? false,
      );
}