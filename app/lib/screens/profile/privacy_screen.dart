import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../services/profile_provider.dart';

/// 隐私设置页
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final c = provider.center;

    return Scaffold(
      appBar: AppBar(title: const Text('隐私设置')),
      body: c == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // 隐私区块
                const _SectionHeader('隐私控制'),
                _PrivacySwitch(
                  icon: Icons.checklist,
                  title: '已读回执',
                  subtitle: '对方可看到你已读消息',
                  value: c.readReceipt,
                  onChanged: (v) => provider.updatePrivacy({'readReceipt': v}),
                ),
                _PrivacySwitch(
                  icon: Icons.location_on_outlined,
                  title: '位置可见',
                  subtitle: '允许同乡/近邻搜索到你的位置',
                  value: c.locationVisible,
                  onChanged: (v) => provider.updatePrivacy({'locationVisible': v}),
                ),
                _PrivacySwitch(
                  icon: Icons.online_prediction,
                  title: '在线状态可见',
                  subtitle: '对方可看到你的在线状态',
                  value: c.onlineVisible,
                  onChanged: (v) => provider.updatePrivacy({'onlineVisible': v}),
                ),
                _PrivacySwitch(
                  icon: Icons.chat_outlined,
                  title: '允许陌生人私聊',
                  subtitle: '未匹配也能收到消息',
                  value: c.allowStrangerChat,
                  onChanged: (v) => provider.updatePrivacy({'allowStrangerChat': v}),
                ),
                _PrivacySwitch(
                  icon: Icons.notifications_active_outlined,
                  title: '上线提醒',
                  subtitle: '匹配好友上线时通知你',
                  value: c.onlineAlert,
                  onChanged: (v) => provider.updatePrivacy({'onlineAlert': v}),
                ),

                const SizedBox(height: AppTheme.spacingXl),

                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Text(
                    '⚠️ 隐私设置仅影响他人对你的可见性，不影响你自己查看内容',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        AppTheme.spacingMd,
        AppTheme.spacingMd,
        AppTheme.spacingSm,
      ),
      child: Text(title, style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      )),
    );
  }
}

class _PrivacySwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrivacySwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppTheme.primary),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      value: value,
      activeColor: AppTheme.primary,
      onChanged: onChanged,
    );
  }
}