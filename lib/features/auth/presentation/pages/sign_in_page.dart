import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/auth/application/app_session_controller.dart';
import 'package:flutter_najwafth_driver/features/auth/presentation/widgets/auth_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key, this.prefilledEmail, this.successMessage});

  final String? prefilledEmail;
  final String? successMessage;

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

final class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    final session = ref.read(appSessionControllerProvider);
    _emailController = TextEditingController(
      text: widget.prefilledEmail ?? session.rememberedEmail ?? session.email,
    );
    _passwordController = TextEditingController();
    _rememberMe = session.rememberMe;

    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(widget.successMessage!)));
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _routeAfterSignIn() {
    final session = ref.read(appSessionControllerProvider);

    if (session.profileCompleted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      return;
    }

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.completeProfile,
      arguments: CompleteProfileRouteArgs(
        prefilledName: session.userName,
        email: session.email,
        phoneNumber: session.phoneNumber,
        shouldReturnToSignIn: false,
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final errorMessage = await ref
        .read(appSessionControllerProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          rememberMe: _rememberMe,
        );

    if (!mounted) return;
    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    _routeAfterSignIn();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      appSessionControllerProvider.select((s) => s.isLoading),
    );

    return DriverScaffold(
      child: Form(
        key: _formKey,
        child: Center(
          child: DriverScrollableBody(
            children: [
              const SizedBox(height: 18),
              const DriverBrandHeader(width: 240),
              const SizedBox(height: 34),
              DriverTextField(
                controller: _emailController,
                label: 'User Email',
                hintText: 'Enter your Email',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
              ),
              const SizedBox(height: 20),
              DriverTextField(
                controller: _passwordController,
                label: 'Password',
                hintText: 'Enter your Password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: (value) =>
                    Validators.minLength(value, 6, label: 'Password'),
                onFieldSubmitted: (_) => _submit(),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Remember me',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: AppColors.subtitle),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
                    },
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DriverPrimaryButton(
                label: 'Sign in',
                onPressed: isLoading ? null : _submit,
                isLoading: isLoading,
              ),
              const SizedBox(height: 28),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  Text(
                    "Don't have an account?",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.title,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.signUp),
                    child: Text(
                      'Sign Up Here',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.link,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
