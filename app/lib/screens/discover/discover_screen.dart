import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../services/match_provider.dart';
import '../../widgets/recommend_card.dart';
import '../../widgets/app_button.dart';
import 'match_dialog.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  /// 当前卡片偏移（手势追踪）
  double _dragDx = 0;
  double _dragDy = 0;

  /// 当前旋转（根据 x 偏移）
  double _rotation = 0;

  /// 是否正在动画
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    // 首次加载推荐
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().loadRecommend();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('寻觅')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(MatchProvider provider) {
    // 加载中
    if (provider.isLoading && provider.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primary),
            SizedBox(height: AppTheme.spacingMd),
            Text('正在为你寻找有缘人...', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    // 错误
    if (provider.error != null && provider.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: AppTheme.spacingMd),
            Text(provider.error!, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: AppTheme.spacingLg),
            AppPrimaryButton(
              onPressed: () => provider.loadRecommend(),
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    // 空状态
    if (provider.isEmpty && !provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: AppTheme.primary.withValues(alpha: 0.3)),
            const SizedBox(height: AppTheme.spacingMd),
            const Text('今日推荐已用完~', style: TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
            const SizedBox(height: AppTheme.spacingXs),
            const Text('明天再来看看吧 🌙', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: AppTheme.spacingLg),
            AppPrimaryButton(
              onPressed: () => provider.loadRecommend(),
              child: const Text('刷新试试'),
            ),
          ],
        ),
      );
    }

    // 卡片栈
    return Stack(
      alignment: Alignment.center,
      children: [
        // 底部第二张卡片（无交互）
        if (provider.cards.length > 1)
          Positioned(
            top: 80,
            left: 20,
            right: 20,
            bottom: 160,
            child: Opacity(
              opacity: 0.6,
              child: Transform.scale(
                scale: 0.95,
                child: RecommendCard(user: provider.cards[1]),
              ),
            ),
          ),

        // 顶部卡片（可拖拽）
        Positioned(
          top: 70,
          left: 16,
          right: 16,
          bottom: 170,
          child: _buildTopCard(provider),
        ),

        // 底部操作按钮
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: _buildActionButtons(provider),
        ),

        // 匹配成功弹窗
        if (provider.matched && provider.matchedUser != null)
          MatchDialog(
            user: provider.matchedUser!,
            onDismiss: () => provider.dismissMatch(),
          ),
      ],
    );
  }

  Widget _buildTopCard(MatchProvider provider) {
    final card = RecommendCard(
      user: provider.cards.first,
      width: double.infinity,
      height: double.infinity,
    );

    if (_animating) return card;

    return GestureDetector(
      onPanStart: (_) {
        setState(() {
          _dragDx = 0;
          _dragDy = 0;
          _rotation = 0;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _dragDx += details.delta.dx;
          _dragDy += details.delta.dy;
          _rotation = _dragDx / 400; // 最大旋转 ~30°
        });
      },
      onPanEnd: (_) => _onSwipeEnd(provider),
      child: Transform.translate(
        offset: Offset(_dragDx, _dragDy),
        child: Transform.rotate(
          angle: _rotation,
          child: Stack(
            children: [
              card,
              // 喜欢戳（右滑 > 80px）
              if (_dragDx > 80)
                Positioned(
                  top: 40,
                  left: 30,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Text('❤️ 喜欢', style: TextStyle(
                        color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold,
                      )),
                    ),
                  ),
                ),
              // 跳过戳（左滑 < -80px）
              if (_dragDx < -80)
                Positioned(
                  top: 40,
                  right: 30,
                  child: Transform.rotate(
                    angle: 0.2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Text('👋 跳过', style: TextStyle(
                        color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold,
                      )),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSwipeEnd(MatchProvider provider) async {
    // 右滑超过 100px → 喜欢
    if (_dragDx > 100) {
      await _animateCardOff(true, provider);
      final matched = await provider.swipe(provider.cards.first.userId, true);
      provider.removeTopCard();
      if (!matched && mounted) _resetCard();
    }
    // 左滑超过 100px → 跳过
    else if (_dragDx < -100) {
      await _animateCardOff(false, provider);
      provider.swipe(provider.cards.first.userId, false);
      provider.removeTopCard();
      if (mounted) _resetCard();
    }
    // 不够远 → 弹回
    else {
      _resetCard();
    }
  }

  Future<void> _animateCardOff(bool isRight, MatchProvider provider) async {
    setState(() => _animating = true);
    final width = MediaQuery.of(context).size.width;
    final targetX = isRight ? width * 2 : -width * 2;

    // 简单线性动画
    final steps = 10;
    for (int i = 0; i < steps; i++) {
      await Future.delayed(const Duration(milliseconds: 16));
      if (!mounted) return;
      setState(() {
        _dragDx = (_dragDx * 0.7) + (targetX * 0.3);
        _dragDy += 20;
        _rotation = _dragDx / 300;
      });
    }
    setState(() => _animating = false);
  }

  void _resetCard() {
    setState(() {
      _dragDx = 0;
      _dragDy = 0;
      _rotation = 0;
    });
  }

  Widget _buildActionButtons(MatchProvider provider) {
    if (provider.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 跳过
        _circleButton(
          icon: Icons.close,
          color: Colors.white,
          bgColor: Colors.red,
          size: 56,
          onTap: () {
            _triggerSwipe(-400, provider);
          },
        ),
        // 喜欢
        _circleButton(
          icon: Icons.favorite,
          color: Colors.white,
          bgColor: AppTheme.primary,
          size: 64,
          onTap: () {
            _triggerSwipe(400, provider);
          },
        ),
        // 超级喜欢（暂用星标）
        _circleButton(
          icon: Icons.star,
          color: Colors.white,
          bgColor: AppTheme.accentGold,
          size: 56,
          onTap: () {
            _triggerSwipe(400, provider);
          },
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.45),
      ),
    );
  }

  Future<void> _triggerSwipe(double dx, MatchProvider provider) async {
    if (provider.isEmpty) return;
    final isLike = dx > 0;
    setState(() {
      _animating = true;
      _dragDx = dx * 0.2;
    });

    await _animateCardOff(isLike, provider);
    await provider.swipe(provider.cards.first.userId, isLike);
    provider.removeTopCard();
    if (mounted) {
      setState(() {
        _animating = false;
        _dragDx = 0;
        _dragDy = 0;
        _rotation = 0;
      });
    }
  }
}