import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../models/recommend_user.dart';

/// 推荐用户卡片组件 — Tinder 风格
class RecommendCard extends StatelessWidget {
  final RecommendUser user;
  final double? width;
  final double? height;

  const RecommendCard({
    super.key,
    required this.user,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 头像
            _buildAvatar(),

            // 底部渐变遮罩 + 信息
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildInfoOverlay(),
            ),

            // 空状态占位
            if (user.avatar == null || user.avatar!.isEmpty)
              const Center(
                child: Icon(Icons.person, size: 80, color: Colors.white38),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (user.avatar != null && user.avatar!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: user.avatar!,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: AppTheme.primary.withValues(alpha: 0.1)),
        errorWidget: (_, __, ___) => Container(
          color: AppTheme.primary.withValues(alpha: 0.15),
          child: const Center(child: Icon(Icons.broken_image, color: Colors.white38, size: 48)),
        ),
      );
    }
    return Container(color: AppTheme.primary.withValues(alpha: 0.1));
  }

  Widget _buildInfoOverlay() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.85),
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 姓名 + 年龄
          Row(
            children: [
              Text(
                user.nickname ?? '未设置',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              if (user.age != null) ...[
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  '${user.age}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),

          // 城市 + 学历
          Row(
            children: [
              if (user.city != null)
                _infoChip(Icons.location_on, user.city!),
              if (user.education != null) ...[
                const SizedBox(width: AppTheme.spacingSm),
                _infoChip(Icons.school, user.education!),
              ],
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),

          // 标签行
          if (user.tags.isNotEmpty)
            Wrap(
              spacing: AppTheme.spacingXs,
              runSpacing: AppTheme.spacingXs,
              children: user.tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ))
                  .toList(),
            ),

          // 个人简介
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              user.bio!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}