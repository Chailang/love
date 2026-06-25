import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// 页面级按钮容器：统一左右边距
class AppButtonBar extends StatelessWidget {
  final Widget child;
  final bool inset;

  const AppButtonBar({
    super.key,
    required this.child,
    this.inset = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!inset) return child;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePaddingH),
      child: child,
    );
  }
}

/// 主按钮：左右留白后在可用宽度内撑满
class AppPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool inset;
  final ButtonStyle? style;

  const AppPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.inset = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return AppButtonBar(
      inset: inset,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: style,
          child: child,
        ),
      ),
    );
  }
}

/// 描边按钮：与主按钮相同的页面边距规则
class AppOutlinedButton extends StatelessWidget {
  final Key? buttonKey;
  final VoidCallback? onPressed;
  final Widget child;
  final bool inset;
  final ButtonStyle? style;

  const AppOutlinedButton({
    super.key,
    this.buttonKey,
    required this.onPressed,
    required this.child,
    this.inset = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).outlinedButtonTheme.style;
    return AppButtonBar(
      inset: inset,
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          key: buttonKey,
          onPressed: onPressed,
          style: style != null ? baseStyle?.merge(style) ?? style : baseStyle,
          child: child,
        ),
      ),
    );
  }
}
