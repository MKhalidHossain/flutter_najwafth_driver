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
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
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

  String? _validateConfirmPassword(String? value) {
    final l10n = context.l10n;
    final passwordError = Validators.minLength(
      value,
      6,
      label: l10n.tr('Confirm Password'),
      l10n: l10n,
    );
    if (passwordError != null) return passwordError;

    if (value!.trim() != _passwordController.text.trim()) {
      return l10n.tr('Passwords do not match.');
    }
    return null;
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final errorMessage = await ref
        .read(appSessionControllerProvider.notifier)
        .signUp(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

    if (!mounted) return;
    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.tr(errorMessage))));
      return;
    }

    final session = ref.read(appSessionControllerProvider);
    Navigator.of(context).pushNamed(
      AppRoutes.completeProfile,
      arguments: CompleteProfileRouteArgs(
        prefilledName: session.userName,
        email: session.email,
        phoneNumber: session.phoneNumber,
        shouldReturnToSignIn: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLoading = ref.watch(
      appSessionControllerProvider.select((s) => s.isLoading),
    );

    return DriverScaffold(
      child: Form(
        key: _formKey,
        child: DriverScrollableBody(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          children: [
            const SizedBox(height: 8),
            const DriverBrandHeader(width: 240),
            const SizedBox(height: 24),
            DriverIntro(
              title: l10n.tr("Let's Get Started!"),
              subtitle: l10n.tr('Create an account'),
              centered: true,
            ),
            const SizedBox(height: 28),
            DriverTextField(
              controller: _nameController,
              label: l10n.tr('User Name'),
              hintText: l10n.tr('Enter your Full Name'),
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: (value) => Validators.required(
                value,
                label: l10n.tr('Name'),
                l10n: l10n,
              ),
            ),
            const SizedBox(height: 18),
            DriverTextField(
              controller: _emailController,
              label: l10n.tr('Your Email'),
              hintText: l10n.tr('Enter your Email'),
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (value) => Validators.email(value, l10n: l10n),
            ),
            const SizedBox(height: 18),
            DriverTextField(
              controller: _phoneController,
              label: l10n.tr('Phone Number'),
              hintText: l10n.tr('Enter your phone number'),
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              validator: (value) => Validators.required(
                value,
                label: l10n.tr('Phone Number'),
                l10n: l10n,
              ),
            ),
            const SizedBox(height: 18),
            DriverTextField(
              controller: _passwordController,
              label: l10n.tr('Password'),
              hintText: l10n.tr('Enter your Password'),
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              validator: (value) => Validators.minLength(
                value,
                6,
                label: l10n.tr('Password'),
                l10n: l10n,
              ),
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
              label: l10n.tr('Confirm Password'),
              hintText: l10n.tr('Enter Confirm Password'),
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
            DriverPrimaryButton(
              label: l10n.tr('Sign up'),
              onPressed: isLoading ? null : _submit,
              isLoading: isLoading,
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                Text(
                  l10n.tr('Already have an account?'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.title,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.tr('Sign In Here'),
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
