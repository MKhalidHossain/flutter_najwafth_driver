import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/auth/data/auth_repository.dart';
import 'package:flutter_najwafth_driver/features/auth/presentation/widgets/auth_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

final class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final result = await ref.read(authRepositoryProvider).forgotPassword(email);

    if (!mounted) return;
    setState(() => _isLoading = false);

    final failure = result.failureOrNull;
    if (failure != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.tr(failure.message))));
      return;
    }

    Navigator.of(
      context,
    ).pushNamed(AppRoutes.otp, arguments: OtpRouteArgs(email: email));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DriverScaffold(
      child: Form(
        key: _formKey,
        child: DriverScrollableBody(
          children: [
            const SizedBox(height: 72),
            const DriverBrandHeader(width: 240),
            const SizedBox(height: 24),
            DriverIntro(
              title: l10n.tr('Reset password'),
              subtitle: l10n.tr('Enter your email to receive the OTP'),
              centered: true,
            ),
            const SizedBox(height: 24),
            DriverTextField(
              controller: _emailController,
              label: l10n.tr('Your Email'),
              hintText: l10n.tr('Enter your Email'),
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: (value) => Validators.email(value, l10n: l10n),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            DriverPrimaryButton(
              label: l10n.tr('Send OTP'),
              onPressed: _isLoading ? null : _submit,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
