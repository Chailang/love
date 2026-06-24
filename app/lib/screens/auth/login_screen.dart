import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../config/app_theme.dart';
import '../../services/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isRegister = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 11) {
      _showSnack('请输入正确的手机号');
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.sendCode(phone, _isRegister ? 'REGISTER' : 'LOGIN');
    if (ok && mounted) _showSnack('验证码已发送（开发环境：123456）');
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    if (phone.length != 11) {
      _showSnack('请输入正确的手机号');
      return;
    }
    if (code.isEmpty) {
      _showSnack('请输入验证码');
      return;
    }

    final auth = context.read<AuthProvider>();
    bool ok;
    if (_isRegister) {
      ok = await auth.register(phone, 'Test123456', code);
    } else {
      ok = await auth.login(phone, code);
    }

    if (mounted) {
      if (ok) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _showSnack(auth.error ?? '操作失败');
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo / Title
              Icon(Icons.favorite, size: 64, color: AppTheme.primary),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                AppConfig.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                AppConfig.slogan,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // 切换登录/注册
              Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: '注册',
                      active: _isRegister,
                      onTap: () => setState(() => _isRegister = true),
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      label: '登录',
                      active: !_isRegister,
                      onTap: () => setState(() => _isRegister = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // 手机号
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: const InputDecoration(
                  hintText: '请输入手机号',
                  prefixIcon: Icon(Icons.phone_android),
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // 验证码 + 发送按钮
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        hintText: '验证码',
                        prefixIcon: Icon(Icons.message),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  TextButton(
                    onPressed: _sendCode,
                    child: const Text('获取验证码'),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // 错误提示
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  child: Text(
                    auth.error!,
                    style: TextStyle(color: AppTheme.primary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),

              // 提交按钮
              ElevatedButton(
                onPressed: auth.isLoading ? null : _submit,
                child: auth.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isRegister ? '注册' : '登录'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppTheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? AppTheme.primary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}