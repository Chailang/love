import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../models/karma_models.dart';

/// 抽奖结果展示弹窗
class KarmaResultDialog extends StatelessWidget {
  final KarmaResult result;
  final bool isDice;

  const KarmaResultDialog({
    super.key,
    required this.result,
    this.isDice = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(AppTheme.spacingXl),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXl)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 稀有度图标
            _buildRarityIcon(),
            const SizedBox(height: AppTheme.spacingMd),

            // 稀有度标题
            Text(
              result.rarity,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppTheme.rarityColor(result.rarity),
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // 描述文案
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.rarityColor(result.rarity).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(
                result.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.rarityColor(result.rarity),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // 匹配用户
            if (result.matchedUserId != null) _buildMatchedUser(),
            if (result.matchedUserId != null) const SizedBox(height: AppTheme.spacingLg),

            // 骰子点数
            if (isDice && result.diceValue != null) ...[
              _buildDice(result.diceValue!),
              const SizedBox(height: AppTheme.spacingLg),
            ],

            // SSR 特效
            if (result.isSSR)
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFFFE082)]),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🌟', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text('天选之缘!', style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,
                    )),
                    SizedBox(width: 8),
                    Text('🌟', style: TextStyle(fontSize: 24)),
                  ],
                ),
              ),

            if (result.isSSR) const SizedBox(height: AppTheme.spacingLg),

            // 余额
            Text(
              '💰 剩余缘分币: ${result.coinBalance}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.spacingSm),

            // 保底计数
            Text(
              '🛡️ 保底计数: ${result.pityCounter}/30',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // 关闭按钮
            AppPrimaryButton(
              inset: false,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('知道了'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRarityIcon() {
    final color = AppTheme.rarityColor(result.rarity);
    final icon = switch (result.rarity) {
      'SSR' => Icons.diamond,
      'SR' => Icons.stars,
      'R' => Icons.auto_awesome,
      _ => Icons.emoji_emotions,
    };

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 3),
      ),
      child: Icon(icon, color: color, size: 40),
    );
  }

  Widget _buildMatchedUser() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
            backgroundImage: result.matchedAvatar != null
                ? NetworkImage(result.matchedAvatar!)
                : null,
            child: result.matchedAvatar == null
                ? Icon(Icons.person, color: AppTheme.primary.withValues(alpha: 0.4))
                : null,
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.matchedNickname ?? '神秘用户',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '匹配度: ${result.rarity} 级',
                  style: TextStyle(
                    color: AppTheme.rarityColor(result.rarity),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppTheme.primary.withValues(alpha: 0.5)),
        ],
      ),
    );
  }

  Widget _buildDice(int value) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$value',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: value == 6 ? AppTheme.raritySR : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// 十连抽结果展示
class MultiGachaResultDialog extends StatelessWidget {
  final List<KarmaResult> results;

  const MultiGachaResultDialog({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final ssrCount = results.where((r) => r.isSSR).length;
    final srCount = results.where((r) => r.rarity == 'SR').length;
    final rCount = results.where((r) => r.rarity == 'R').length;

    return Dialog(
      insetPadding: const EdgeInsets.all(AppTheme.spacingMd),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXl)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 统计摘要
            const Text('🎊 十连抽结果', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statChip('SSR', ssrCount, AppTheme.raritySSR),
                const SizedBox(width: 12),
                _statChip('SR', srCount, AppTheme.raritySR),
                const SizedBox(width: 12),
                _statChip('R', rCount, AppTheme.rarityR),
              ],
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // 卡片网格
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: results.length,
                itemBuilder: (_, index) {
                  final r = results[index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.rarityColor(r.rarity).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: AppTheme.rarityColor(r.rarity).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(r.rarity, style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold,
                          color: AppTheme.rarityColor(r.rarity),
                        )),
                        const SizedBox(height: 6),
                        Text(
                          r.matchedNickname ?? 'N/A',
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),

            if (ssrCount > 0)
              _goldenBanner('🌟 获得 $ssrCount 个 SSR! 🌟'),
            const SizedBox(height: AppTheme.spacingLg),

            AppPrimaryButton(
              inset: false,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('太棒了！'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label ×${count}',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _goldenBanner(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFFFE082)]),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Text(text, style: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white,
      )),
    );
  }
}