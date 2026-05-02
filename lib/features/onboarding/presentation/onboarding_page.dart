import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/auth/application/app_session_controller.dart';
import 'package:flutter_najwafth_driver/features/auth/presentation/widgets/auth_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

final class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final PageController _pageController;
  int _currentIndex = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      assetPath: 'assets/images/onboarding_books.png',
      title: 'Deliver Books, Earn More',
      description:
          'Join our network of drivers delivering knowledge across the city.',
      imageWidthFactor: 0.86,
      descriptionMaxWidth: 320,
    ),
    _OnboardingSlide(
      assetPath: 'assets/images/onboarding_earnings.png',
      title: 'Track Your Earnings',
      description: 'See your daily earnings and delivery history in real-time.',
      imageWidthFactor: 0.84,
      descriptionMaxWidth: 330,
    ),
    _OnboardingSlide(
      assetPath: 'assets/images/onboarding_navigation.png',
      title: 'Easy Navigation',
      description:
          'Built-in maps and optimized routes to make your deliveries smooth.',
      imageWidthFactor: 1,
      descriptionMaxWidth: 335,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(appSessionControllerProvider.notifier).completeOnboarding();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
  }

  Future<void> _goNext() async {
    if (_currentIndex == _slides.length - 1) {
      await _completeOnboarding();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _goBack() async {
    if (_currentIndex == 0) {
      await Navigator.of(context).maybePop();
      return;
    }

    await _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final compact = screenHeight < 780;

    return DriverScaffold(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, compact ? 4 : 8, 16, 16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _goBack,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.title,
                    size: 32,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: AppColors.title,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];

                  return Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: FractionallySizedBox(
                            widthFactor: slide.imageWidthFactor,
                            child: Image.asset(
                              slide.assetPath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 22 : 28),
                      Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontSize: compact ? 22 : 24),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: slide.descriptionMaxWidth,
                        ),
                        child: Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontSize: compact ? 15 : 16,
                                color: AppColors.title,
                                height: 1.34,
                              ),
                        ),
                      ),
                      SizedBox(height: compact ? 20 : 24),
                    ],
                  );
                },
              ),
            ),
            OnboardingDots(currentIndex: _currentIndex, total: _slides.length),
            SizedBox(height: compact ? 24 : 28),
            DriverPrimaryButton(label: 'Next', onPressed: _goNext),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

final class _OnboardingSlide {
  const _OnboardingSlide({
    required this.assetPath,
    required this.title,
    required this.description,
    required this.imageWidthFactor,
    required this.descriptionMaxWidth,
  });

  final String assetPath;
  final String title;
  final String description;
  final double imageWidthFactor;
  final double descriptionMaxWidth;
}
