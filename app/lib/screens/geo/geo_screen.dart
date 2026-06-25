import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../services/geo_provider.dart';
import '../../widgets/geo_neighbor_card.dart';
import '../../widgets/app_button.dart';
import 'edit_geo_sheet.dart';

class GeoScreen extends StatefulWidget {
  const GeoScreen({super.key});

  @override
  State<GeoScreen> createState() => _GeoScreenState();
}

class _GeoScreenState extends State<GeoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GeoProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GeoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('同乡近邻'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_location_alt),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditGeoSheet()),
            ),
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(GeoProvider provider) {
    // 加载中
    if (provider.isLoading && !provider.hasLocation) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    // 未设置位置
    if (!provider.hasLocation && !provider.isLoading) {
      return _buildEmptyLocation();
    }

    // 错误
    if (provider.error != null && provider.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: AppTheme.spacingMd),
            Text(provider.error!, style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 位置档案摘要栏
        _buildLocationBar(provider),

        // 搜索标签栏
        _buildSearchTabs(provider),

        // 结果列表
        Expanded(child: _buildResults(provider)),
      ],
    );
  }

  /// 未设置位置 — 引导页
  Widget _buildEmptyLocation() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on_outlined, size: 48, color: AppTheme.accentTeal),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            const Text(
              '设置你的位置信息',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            const Text(
              '告诉系统你在哪——\n帮你找到同乡、同行和身边的TA 💚',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: AppTheme.spacingXl),
            AppPrimaryButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditGeoSheet()),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_location_alt),
                  SizedBox(width: AppTheme.spacingSm),
                  Text('去设置'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 位置档案摘要
  Widget _buildLocationBar(GeoProvider provider) {
    final geo = provider.myGeo;
    if (geo == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.accentTeal.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location, color: AppTheme.accentTeal, size: 20),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Text(
              _geoSummary(geo),
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  String _geoSummary(Map geo) {
    final parts = <String>[];
    final hp = geo['hometownProvince'] as String?;
    final hc = geo['hometownCity'] as String?;
    if (hp != null && hp.isNotEmpty) parts.add('🏠 $hp${hc != null ? hc : ''}');

    final wp = geo['workProvince'] as String?;
    final wc = geo['workCity'] as String?;
    if (wp != null && wp.isNotEmpty) parts.add('💼 $wp${wc != null ? wc : ''}');

    final rp = geo['residenceProvince'] as String?;
    final rc = geo['residenceCity'] as String?;
    if (rp != null && rp.isNotEmpty) parts.add('📍 $rp${rc != null ? rc : ''}');

    return parts.isEmpty ? '请设置位置' : parts.join(' · ');
  }

  /// 搜索标签
  Widget _buildSearchTabs(GeoProvider provider) {
    const tabs = [
      _GeoSearchTab('🌐', '综合', 'all'),
      _GeoSearchTab('🏠', '同乡', 'hometown'),
      _GeoSearchTab('💼', '同行', 'work'),
      _GeoSearchTab('📍', '近邻', 'residence'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: Row(
        children: tabs.map((tab) {
          final isActive = provider.activeTab == tab.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => provider.switchTab(tab.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.accentTeal.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: isActive ? AppTheme.accentTeal : AppTheme.divider,
                  ),
                ),
                child: Column(
                  children: [
                    Text(tab.icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 2),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive ? AppTheme.accentTeal : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 结果列表
  Widget _buildResults(GeoProvider provider) {
    if (provider.isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.accentTeal),
            SizedBox(height: AppTheme.spacingMd),
            Text('正在搜索...', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    if (provider.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: AppTheme.spacingMd),
            const Text('暂未搜索到结果', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: AppTheme.spacingXs),
            const Text('试试其他维度？', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: provider.results.length,
      itemBuilder: (_, index) => GeoNeighborCard(neighbor: provider.results[index]),
    );
  }
}

class _GeoSearchTab {
  final String icon;
  final String label;
  final String key;
  const _GeoSearchTab(this.icon, this.label, this.key);
}