import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_najwafth_driver/core/core.dart';

const String _brandLogoAsset = 'assets/images/app_logo.png';

final class DriverScaffold extends StatelessWidget {
  const DriverScaffold({
    required this.child,
    super.key,
    this.backgroundColor = AppColors.background,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget child;
  final Color backgroundColor;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: SafeArea(child: child),
      ),
    );
  }
}

final class DriverScrollableBody extends StatelessWidget {
  const DriverScrollableBody({
    required this.children,
    super.key,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 16),
  });

  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

final class DriverBrandHeader extends StatelessWidget {
  const DriverBrandHeader({super.key, this.width = 250});

  final double width;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 390;

    return Center(
      child: Image.asset(
        _brandLogoAsset,
        width: compact ? width * 0.78 : width,
        fit: BoxFit.contain,
      ),
    );
  }
}

final class DriverIntro extends StatelessWidget {
  const DriverIntro({
    required this.title,
    required this.subtitle,
    super.key,
    this.centered = false,
  });

  final String title;
  final String subtitle;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 390;
    final crossAxisAlignment = centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          title,
          textAlign: textAlign,
          style:
              (compact
                      ? Theme.of(context).textTheme.headlineSmall
                      : Theme.of(context).textTheme.headlineMedium)
                  ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: textAlign,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: compact ? 14 : 16,
            color: AppColors.subtitle,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

final class DriverFieldLabel extends StatelessWidget {
  const DriverFieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 390;

    return Text(
      label,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: compact ? 15 : 16,
        color: const Color(0xFF111111),
      ),
    );
  }
}

final class DriverTextField extends StatelessWidget {
  const DriverTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    super.key,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autofillHints,
    this.inputFormatters,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 390;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DriverFieldLabel(label),
        SizedBox(height: compact ? 8 : 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          validator: validator,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          onFieldSubmitted: onFieldSubmitted,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF303030),
            fontWeight: FontWeight.w500,
            fontSize: compact ? 15 : 16,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

final class DriverPrimaryButton extends StatelessWidget {
  const DriverPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 390;

    return SizedBox(
      width: double.infinity,
      height: compact ? 56 : 60,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 16 : 17,
                ),
              ),
      ),
    );
  }
}

final class DriverSocialButton extends StatelessWidget {
  const DriverSocialButton({
    required this.label,
    required this.leading,
    required this.onPressed,
    super.key,
  });

  final String label;
  final Widget leading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 390;

    return SizedBox(
      width: double.infinity,
      height: compact ? 58 : 62,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(backgroundColor: Colors.transparent),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: compact ? 15 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.title,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class OnboardingDots extends StatelessWidget {
  const OnboardingDots({
    required this.currentIndex,
    required this.total,
    super.key,
  });

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final selected = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: selected ? 24 : 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.dotInactive,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}

final class DriverVehicleCard extends StatelessWidget {
  const DriverVehicleCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.large,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 112,
          decoration: BoxDecoration(
            color: selected ? AppColors.sky : Colors.transparent,
            borderRadius: AppRadius.large,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: 1.7,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 34,
                color: selected ? AppColors.primary : AppColors.subtitle,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: selected ? AppColors.primary : AppColors.subtitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
