import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/auth/data/auth_repository.dart';
import 'package:flutter_najwafth_driver/features/auth/presentation/widgets/auth_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({required this.email, super.key});

  final String email;

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

final class _OtpVerificationPageState
    extends ConsumerState<OtpVerificationPage> {
  static const _otpLength = 6;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  Timer? _timer;
  int _remainingSeconds = 45;
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remainingSeconds = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds == 0) {
        timer.cancel();
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  void _handleOtpChanged(int index, String value) {
    if (value.length > 1) {
      final normalized = value.characters.last;
      _controllers[index].value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }

    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _resendOtp() async {
    if (_remainingSeconds != 0) return;

    setState(() => _isResending = true);
    final result = await ref
        .read(authRepositoryProvider)
        .forgotPassword(widget.email);

    if (!mounted) return;
    setState(() => _isResending = false);

    final failure = result.failureOrNull;
    if (failure != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.tr(failure.message))));
      return;
    }

    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
    _startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.dataOrNull ?? context.l10n.tr('A fresh OTP has been sent.'),
        ),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.tr('Enter the complete 6-digit OTP.')),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await ref
        .read(authRepositoryProvider)
        .verifyOtp(email: widget.email, otp: otp);

    if (!mounted) return;
    setState(() => _isLoading = false);

    final failure = result.failureOrNull;
    if (failure != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.tr(failure.message))));
      return;
    }

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.resetPassword,
      arguments: ResetPasswordRouteArgs(email: widget.email, otp: otp),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DriverScaffold(
      child: DriverScrollableBody(
        children: [
          const SizedBox(height: 80),
          const DriverBrandHeader(width: 240),
          const SizedBox(height: 20),
          Text(
            context.l10n.tr('Enter OTP'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${context.l10n.tr('Sent to')} ${widget.email}',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.subtitle),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 8.0;
              final boxWidth = ((constraints.maxWidth - (spacing * 5)) / 6)
                  .clamp(42.0, 58.0);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (index) {
                  return SizedBox(
                    width: boxWidth,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      textInputAction: index == _otpLength - 1
                          ? TextInputAction.done
                          : TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF293C66),
                          ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 24,
                        ),
                        filled: false,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onChanged: (value) => _handleOtpChanged(index, value),
                      onSubmitted: (_) {
                        if (index == _otpLength - 1) _verifyOtp();
                      },
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            '${context.l10n.tr('Resend code in')} ${_remainingSeconds}s',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF717171),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              Text(
                context.l10n.tr("Didn't Receive OTP?"),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.title,
                ),
              ),
              GestureDetector(
                onTap: _isResending ? null : _resendOtp,
                child: Text(
                  context.l10n.tr(_isResending ? 'SENDING...' : 'RESEND OTP'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _remainingSeconds == 0
                        ? AppColors.success
                        : AppColors.subtitle,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          DriverPrimaryButton(
            label: context.l10n.tr('Verify Now'),
            onPressed: _isLoading ? null : _verifyOtp,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
