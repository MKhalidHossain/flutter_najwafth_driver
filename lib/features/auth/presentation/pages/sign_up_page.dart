import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/auth/application/app_session_controller.dart';
import 'package:flutter_najwafth_driver/features/auth/presentation/widgets/auth_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

final class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    final session = ref.read(appSessionControllerProvider);
    _nameController = TextEditingController(text: session.userName);
    _emailController = TextEditingController(text: session.email);
    _phoneController = TextEditingController(text: session.phoneNumber);
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    final requiredMessage = Validators.required(value, label: 'Phone number');
    if (requiredMessage != null) {
      return requiredMessage;
    }

    final digitsOnly = value!.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 7) {
      return 'Enter a valid phone number.';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final passwordError = Validators.minLength(
      value,
      6,
      label: 'Confirm password',
    );
    if (passwordError != null) {
      return passwordError;
    }

    if (value!.trim() != _passwordController.text.trim()) {
      return 'Passwords do not match.';
    }

    return null;
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    await ref
        .read(appSessionControllerProvider.notifier)
        .saveAccountIdentity(
          userName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamed(
      AppRoutes.completeProfile,
      arguments: CompleteProfileRouteArgs(
        prefilledName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        shouldReturnToSignIn: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DriverScaffold(
      child: Form(
        key: _formKey,
        child: DriverScrollableBody(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          children: [
            const SizedBox(height: 8),
            const DriverBrandHeader(width: 240),
            const SizedBox(height: 24),
            const DriverIntro(
              title: 'Let’s Get Started!',
              subtitle: 'Create an account',
              centered: true,
            ),
            const SizedBox(height: 28),
            DriverTextField(
              controller: _nameController,
              label: 'User Name',
              hintText: 'Enter your First Name',
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: (value) => Validators.required(value, label: 'Name'),
            ),
            const SizedBox(height: 18),
            DriverTextField(
              controller: _emailController,
              label: 'Your Email',
              hintText: 'Enter your Email',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
            ),
            const SizedBox(height: 18),
            DriverTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hintText: 'Enter your phone number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              validator: _validatePhone,
            ),
            const SizedBox(height: 18),
            DriverTextField(
              controller: _passwordController,
              label: 'Password',
              hintText: 'Enter your Password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  Validators.minLength(value, 6, label: 'Password'),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            const SizedBox(height: 18),
            DriverTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hintText: 'Enter Confirm Password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              validator: _validateConfirmPassword,
              onFieldSubmitted: (_) => _submit(),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            const SizedBox(height: 24),
            DriverPrimaryButton(label: 'Sign up', onPressed: _submit),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                Text(
                  'Already have an account?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.title,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    'Sign In Here',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.link,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
