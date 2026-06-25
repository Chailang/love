import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../config/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/agreement_dialog.dart';
import '../auth/login_screen.dart';

/// 新用户引导页 — App 首屏（未登录）
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  void _onStart(BuildContext context) {
    AgreementDialog.show(
      context,
      onAgree: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFE4E6), Color(0xFFFCE7F3), Color(0xFFDDD6FE)],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_rounded, size: 96, color: AppTheme.primary.withValues(alpha: 0.85)),
                        const SizedBox(height: AppTheme.spacingLg),
                        Text(
                          AppConfig.appName,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
                          child: Text(
                            AppConfig.slogan,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.textSecondary,
                                  height: 1.5,
                                ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          '（引导页占位图，后续替换为品牌视觉素材）',
                          style: TextStyle(fontSize: 12, color: AppTheme.textHint.withValues(alpha: 0.9)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: AppTheme.pagePaddingH,
                right: AppTheme.pagePaddingH,
                bottom: AppTheme.spacingXl,
              ),
              child: AppPrimaryButton(
                inset: false,
                onPressed: () => _onStart(context),
                child: const Text('开始邂逅'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
