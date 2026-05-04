import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/auth/presentation/widgets/auth_ui.dart';

final class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

final class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

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

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    Navigator.of(context).pushNamed(
      AppRoutes.otp,
      arguments: OtpRouteArgs(email: _emailController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DriverScaffold(
      child: Form(
        key: _formKey,
        child: DriverScrollableBody(
          children: [
            const SizedBox(height: 72),
            const DriverBrandHeader(width: 240),
            const SizedBox(height: 24),
            const DriverIntro(
              title: 'Reset password',
              subtitle: 'Enter your email to receive the OTP',
              centered: true,
            ),
            const SizedBox(height: 24),
            DriverTextField(
              controller: _emailController,
              label: 'Your Email',
              hintText: 'Enter your Email',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: Validators.email,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            DriverPrimaryButton(label: 'Send OTP', onPressed: _submit),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
