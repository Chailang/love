import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../services/karma_provider.dart';
import 'karma_result_dialog.dart';

class BlindboxScreen extends StatefulWidget {
  const BlindboxScreen({super.key});

  @override
  State<BlindboxScreen> createState() => _BlindboxScreenState();
}

class _BlindboxScreenState extends State<BlindboxScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KarmaProvider>().loadAccount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KarmaProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('缘分盲盒')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(KarmaProvider provider) {
    if (provider.isLoading && provider.account == null) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    if (provider.error != null && provider.account == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: AppTheme.spacingMd),
            Text(provider.error!, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton(
              onPressed: () => provider.loadAccount(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        children: [
          // 余额展示
          _buildBalanceCard(provider),

          const SizedBox(height: AppTheme.spacingXl),

          // 三种玩法
          _buildGameCard(
            icon: '🎁',
            title: '缘分盲盒',
            desc: '随机匹配一个人\n概率出 SSR 高匹配度',
            cost: '5 币/次',
            remaining: '${3 - (provider.account?.dailyBlindUsed ?? 0)}/3 次',
            color: AppTheme.primary,
            enabled: (provider.account?.dailyBlindUsed ?? 0) < 3,
            onTap: () => _handleDraw(() => provider.playBlind()),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          _buildGameCard(
            icon: '🎲',
            title: '命运骰子',
            desc: '摇骰子获得匹配加成\n6 点出 SR 概率高',
            cost: '3 币/次',
            remaining: '${5 - (provider.account?.dailyDiceUsed ?? 0)}/5 次',
            color: AppTheme.accentPurple,
            enabled: (provider.account?.dailyDiceUsed ?? 0) < 5,
            onTap: () => _handleDraw(() => provider.playDice()),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          _buildGachaCards(provider),

          const SizedBox(height: AppTheme.spacingXl),

          // SSR 暴击周
          _buildSSRBoost(provider),

          const SizedBox(height: AppTheme.spacingXl),

          // 保底进度
          _buildPityProgress(provider),

          const SizedBox(height: AppTheme.spacingMd),

          // 说明文案
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📖 玩法规则', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppTheme.spacingSm),
                _ruleText('🎁 盲盒：每日 3 次，每次 5 币'),
                _ruleText('🎲 骰子：每日 5 次，每次 3 币'),
                _ruleText('🥚 扭蛋：单抽 3 币，十连 25 币（保底 SR）'),
                _ruleText('✨ SSR 概率 3%，每月 15-21 日暴击周翻倍'),
                _ruleText('🛡️ 扭蛋 30 抽保底出 SSR'),
                _ruleText('❤️ 匹配成功奖励 2 枚缘分币'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 余额卡片
  Widget _buildBalanceCard(KarmaProvider provider) {
    final acc = provider.account;
    if (acc == null) return const SizedBox.shrink();

    return Container(
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
            color: AppTheme.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🪙', style: TextStyle(fontSize: 40)),
          const SizedBox(width: AppTheme.spacingMd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('缘分币', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(
                '${acc.balance}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _balanceStat('累计获得', acc.totalEarned),
              const SizedBox(height: 4),
              _balanceStat('累计消耗', acc.totalSpent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceStat(String label, int value) {
    return Text(
      '$label: $value',
      style: const TextStyle(color: Colors.white60, fontSize: 12),
    );
  }

  /// 通用玩法卡片
  Widget _buildGameCard({
    required String icon,
    required String title,
    required String desc,
    required String cost,
    required String remaining,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(cost, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 6),
                  Text(remaining, style: TextStyle(color: color, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 扭蛋卡片（单抽 + 十连）
  Widget _buildGachaCards(KarmaProvider provider) {
    final color = AppTheme.accentGold;
    final dailyUsed = provider.account?.dailyGachaUsed ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🥚', style: TextStyle(fontSize: 40)),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('缘分扭蛋', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '十连必出 SR 以上',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                '$dailyUsed/∞',
                style: TextStyle(color: color, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // 单抽 + 十连按钮
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleDraw(() => provider.playGacha(1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('单抽 3币', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleDraw(() => provider.playGacha(10)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('十连抽 ', style: TextStyle(color: Colors.white)),
                      Text('25币', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// SSR 暴击周横幅
  Widget _buildSSRBoost(KarmaProvider provider) {
    if (provider.account?.ssrBoostActive != true) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFFFE082)]),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🔥', style: TextStyle(fontSize: 24)),
          SizedBox(width: 8),
          Text(
            'SSR 暴击周！概率翻倍 3% → 8%',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(width: 8),
          Text('🔥', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  /// 保底进度
  Widget _buildPityProgress(KarmaProvider provider) {
    final counter = provider.account?.pityCounter ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.raritySSR.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.raritySSR.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🛡️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: AppTheme.spacingSm),
              const Text('扭蛋保底进度', style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                '$counter/30',
                style: const TextStyle(color: AppTheme.raritySSR, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          LinearProgressIndicator(
            value: counter / 30.0,
            backgroundColor: AppTheme.raritySSR.withValues(alpha: 0.1),
            color: AppTheme.raritySSR,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _ruleText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
    );
  }

  /// 抽奖处理
  Future<void> _handleDraw(Future<bool> Function() drawFn) async {
    final provider = context.read<KarmaProvider>();
    final ok = await drawFn();

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? '抽奖失败'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 展示结果弹窗
    if (mounted && provider.lastResult != null) {
      await showDialog(
        context: context,
        builder: (_) => provider.multiResults != null
            ? MultiGachaResultDialog(results: provider.multiResults!)
            : KarmaResultDialog(
                result: provider.lastResult!,
                isDice: provider.lastResult!.actionType == 'DICE',
              ),
      );
      provider.dismissResult();
    }
  }
}