import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/recommend_user.dart';

/// 匹配成功弹窗
class MatchDialog extends StatelessWidget {
  final RecommendUser user;
  final VoidCallback onDismiss;

  const MatchDialog({
    super.key,
    required this.user,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(AppTheme.spacingXl),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXl)),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 匹配动画图标
                const Icon(Icons.favorite, size: 72, color: AppTheme.primary),
                const SizedBox(height: AppTheme.spacingMd),

                // 标题
                Text(
                  '💘 匹配成功！',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primary,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                const Text('你们互相喜欢！快去聊天吧~'),
                const SizedBox(height: AppTheme.spacingXl),

                // 双方头像
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _avatar(user.avatar, isSelf: true),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                      padding: const EdgeInsets.all(AppTheme.spacingSm),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite, color: AppTheme.primary, size: 28),
                    ),
                    _avatar(user.avatar, isSelf: false),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),

                Text(
                  '你和 ${user.nickname ?? 'TA'}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppTheme.spacingXl),

                // 按钮组
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDismiss,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.textSecondary),
                          foregroundColor: AppTheme.textSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                        ),
                        child: const Text('继续寻觅'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onDismiss();
                          // TODO: 跳转聊天页
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('开始聊天 💬'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar(String? url, {bool isSelf = false}) {
    return CircleAvatar(
      radius: 42,
      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
      child: url != null && url.isNotEmpty
          ? ClipOval(child: Image.network(url, fit: BoxFit.cover))
          : Icon(Icons.person, size: 36, color: AppTheme.primary.withValues(alpha: 0.4)),
    );
  }
}