import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../models/geo_neighbor.dart';

/// 同乡近邻匹配结果卡片
class GeoNeighborCard extends StatelessWidget {
  final GeoNeighbor neighbor;

  const GeoNeighborCard({super.key, required this.neighbor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            // 头像
            _buildAvatar(),
            const SizedBox(width: AppTheme.spacingMd),

            // 中间信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 姓名 + 年龄 + 得分
                  Row(
                    children: [
                      Text(
                        neighbor.nickname ?? '未设置',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      if (neighbor.age != null) ...[
                        const SizedBox(width: 6),
                        Text('${neighbor.age}', style: const TextStyle(color: AppTheme.textSecondary)),
                      ],
                      const Spacer(),
                      _scoreBadge(neighbor.score),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // 学历
                  if (neighbor.education != null)
                    Text(neighbor.education!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 6),

                  // 匹配标签
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (neighbor.matchLabel != null)
                        _matchChip(neighbor.matchLabel!, _labelColor(neighbor.matchLabel!)),
                      if (neighbor.hometownMatch != null)
                        _matchChip('🏠 ${neighbor.hometownMatch}', AppTheme.accentTeal),
                      if (neighbor.workMatch != null)
                        _matchChip('💼 ${neighbor.workMatch}', AppTheme.accentPurple),
                      if (neighbor.distance != null)
                        _matchChip('📍 ${neighbor.distance}', AppTheme.primary),
                    ],
                  ),
                ],
              ),
            ),

            // 右侧箭头
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (neighbor.avatar != null && neighbor.avatar!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: CachedNetworkImage(
          imageUrl: neighbor.avatar!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _defaultAvatar(),
        ),
      );
    }
    return _defaultAvatar();
  }

  Widget _defaultAvatar() => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Icon(Icons.person, color: AppTheme.primary.withValues(alpha: 0.4)),
      );

  Widget _scoreBadge(int score) {
    Color color;
    if (score >= 80) {
      color = AppTheme.raritySSR;
    } else if (score >= 60) {
      color = AppTheme.raritySR;
    } else if (score >= 40) {
      color = AppTheme.rarityR;
    } else {
      color = AppTheme.rarityN;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${score}分',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _matchChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  Color _labelColor(String label) {
    if (label.contains('老乡')) return AppTheme.accentTeal;
    if (label.contains('同事') || label.contains('工作')) return AppTheme.accentPurple;
    if (label.contains('近邻')) return AppTheme.primary;
    return AppTheme.accentGold;
  }
}