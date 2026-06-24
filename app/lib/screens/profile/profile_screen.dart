import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../services/auth_provider.dart';
import '../../services/profile_provider.dart';
import '../../models/user_center.dart';
import 'edit_profile_sheet.dart';
import 'privacy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadCenter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _navigateTo(PrivacyScreen()),
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(ProfileProvider provider) {
    if (provider.isLoading && provider.center == null) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    if (provider.center == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: AppTheme.spacingMd),
            const Text('加载失败', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton(
              onPressed: () => provider.loadCenter(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final c = provider.center!;
    return RefreshIndicator(
      onRefresh: () => provider.loadCenter(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // 顶部资料卡片
            _buildProfileCard(c),

            const SizedBox(height: AppTheme.spacingMd),

            // 互动数据面板
            _buildStatsPanel(c),

            const SizedBox(height: AppTheme.spacingMd),

            // 功能入口列表
            _buildMenuList(),
          ],
        ),
      ),
    );
  }

  /// 顶部资料卡片
  Widget _buildProfileCard(UserCenter c) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头像 + 编辑
          Row(
            children: [
              // 头像
              _buildAvatar(c.avatar, c.nickname),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          c.nickname ?? '未设置昵称',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        if (c.realNameVerified)
                          const Icon(Icons.verified, color: Colors.white, size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildSubtitle(c),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => _navigateTo(EditProfileSheet()),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // 资料完整度
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('资料完整度', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text('${c.profileCompleteness}%',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: c.profileCompleteness / 100.0,
                        backgroundColor: Colors.white24,
                        color: c.profileCompleteness >= 80 ? AppTheme.accentGold : Colors.white,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              // 认证状态
              _buildVerifyBadge('学历', c.educationVerified),
              _buildVerifyBadge('实名', c.realNameVerified),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? avatar, String? nickname) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: ClipOval(
        child: avatar != null && avatar.isNotEmpty
            ? CachedNetworkImage(imageUrl: avatar, fit: BoxFit.cover)
            : Container(
                color: Colors.white24,
                child: Center(
                  child: Text(
                    (nickname ?? '?').substring(0, 1),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
      ),
    );
  }

  String _buildSubtitle(UserCenter c) {
    final parts = <String>[];
    if (c.city != null) parts.add(c.city!);
    if (c.age != null) parts.add('${c.age}岁');
    if (c.school != null) parts.add(c.school!);
    if (c.height != null) parts.add('${c.height}cm');
    return parts.isEmpty ? '完善资料让更多人认识你 ✏️' : parts.join(' · ');
  }

  Widget _buildVerifyBadge(String label, bool verified) {
    return Container(
      margin: const EdgeInsets.only(left: AppTheme.spacingSm),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: verified ? Colors.white : Colors.white24,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.check_circle : Icons.help_outline,
            size: 12,
            color: verified ? AppTheme.primary : Colors.white70,
          ),
          const SizedBox(width: 3),
          Text(
            '${label}${verified ? '' : ''}',
            style: TextStyle(
              fontSize: 11,
              color: verified ? AppTheme.primary : Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 互动数据面板
  Widget _buildStatsPanel(UserCenter c) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem('❤️', '喜欢', c.likedCount),
          _divider(),
          _statItem('💛', '被喜欢', c.likedByCount),
          _divider(),
          _statItem('💘', '匹配', c.matchCount),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 36, color: AppTheme.divider);

  Widget _statItem(String icon, String label, int count) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text('$count', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }

  /// 功能入口菜单
  Widget _buildMenuList() {
    return Column(
      children: [
        _menuItem(Icons.verified_user_outlined, '认证中心', '学历/实名认证'),
        _menuItem(Icons.favorite_outline, '我的喜欢', '查看已喜欢的人'),
        _menuItem(Icons.stars_outlined, '我的缘分', '缘分盲盒记录'),
        _menuItem(Icons.security_outlined, '隐私设置', '管理位置/在线状态'),
        _menuItem(Icons.help_outline, '帮助与反馈', ''),
        _menuItem(Icons.info_outline, '关于青藤之恋', 'v1.0.0'),

        const SizedBox(height: AppTheme.spacingMd),

        // 退出登录
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _logout(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            ),
            child: const Text('退出登录'),
          ),
        ),
        const SizedBox(height: AppTheme.spacingXl),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: () {},
    );
  }

  void _navigateTo(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('退出'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final auth = context.read<AuthProvider>();
      await auth.logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }
}