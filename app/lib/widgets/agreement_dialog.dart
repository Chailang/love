import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';

/// 温馨提示 — 用户协议与隐私政策确认弹窗
class AgreementDialog extends StatelessWidget {
  final VoidCallback onAgree;
  final VoidCallback onDisagree;

  const AgreementDialog({
    super.key,
    required this.onAgree,
    required this.onDisagree,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onAgree,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AgreementDialog(
        onAgree: () {
          Navigator.of(context).pop();
          onAgree();
        },
        onDisagree: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '温馨提示',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 14, height: 1.6, color: AppTheme.textSecondary),
                children: [
                  const TextSpan(text: '为了向你提供更好的交友体验，请阅读并同意 '),
                  TextSpan(
                    text: '《用户协议》',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _openUrl(AppConfig.userAgreementUrl),
                  ),
                  const TextSpan(text: '、'),
                  TextSpan(
                    text: '《隐私政策》',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _openUrl(AppConfig.privacyPolicyUrl),
                  ),
                  const TextSpan(text: '，点击同意后才可以使用相关功能。'),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDisagree,
                    child: const Text('不同意'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAgree,
                    child: const Text('同意并继续'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
