import 'dart:async';

import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/app_snackbar.dart';
import 'package:deca_mobile/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Man hinh dang nhap, goi backend qua [AuthCubit].
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'hs01');
  final _passwordController = TextEditingController(text: 'Admin@123');
  bool _obscure = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      unawaited(
        context.read<AuthCubit>().login(
              _usernameController.text.trim(),
              _passwordController.text,
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state.status == AuthStatus.failure) {
                  AppSnackBar.error(
                    context,
                    state.error ?? 'Đăng nhập thất bại',
                  );
                }
              },
              builder: (context, state) {
                final loading = state.status == AuthStatus.loading;
                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BrandHeader(theme: theme),
                      AppSpacing.gapXl,
                      TextFormField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Tài khoản',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Nhập tài khoản' : null,
                      ),
                      AppSpacing.gapLg,
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _obscure ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        onFieldSubmitted: (_) => _submit(),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Nhập mật khẩu' : null,
                      ),
                      AppSpacing.gapXl,
                      PrimaryButton(
                        label: 'Đăng nhập',
                        loading: loading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: AppRadii.rxl,
          ),
          child: Icon(
            Icons.school_rounded,
            size: 48,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        AppSpacing.gapLg,
        Text(
          'Trung tâm đào tạo',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        AppSpacing.gapXs,
        Text(
          'Đăng nhập để tiếp tục',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
