import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unspammer/nav.dart';
import 'package:unspammer/theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppColors.themeModeNotifier,
      builder: (context, themeMode, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 3),

                      // App Title & Tagline
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.green.withValues(alpha: 0.1),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.mark_email_read_rounded,
                                  size: 64,
                                  color: AppColors.gold,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'Unspammer',
                                style: context.textStyles.displayLarge?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Your smart academic inbox.\nOrganized, focused, and spam-free.',
                                style: context.textStyles.bodyLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Login Button with Microsoft
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: GestureDetector(
                            onTapDown: (_) => setState(() => _isPressed = true),
                            onTapUp: (_) {
                              setState(() => _isPressed = false);
                              // Login logic goes here, then navigate to home
                              context.go(AppRoutes.home);
                            },
                            onTapCancel: () => setState(() => _isPressed = false),
                            child: AnimatedScale(
                              scale: _isPressed ? 0.96 : 1.0,
                              duration: const Duration(milliseconds: 150),
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.navy.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const MicrosoftLogo(size: 24),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Login with Microsoft',
                                      style: context.textStyles.titleLarge?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 6),
                    ],
                  ),
                ),

                // Theme Toggle Button
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      AppColors.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {
                      AppColors.toggleTheme();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MicrosoftLogo extends StatelessWidget {
  final double size;
  const MicrosoftLogo({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    final double spacing = size * 0.06;
    final double squareSize = (size - spacing) / 2;
    return SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: squareSize, height: squareSize, color: const Color(0xFFF25022)), // Red
              Container(width: squareSize, height: squareSize, color: const Color(0xFF7FBA00)), // Green
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: squareSize, height: squareSize, color: const Color(0xFF00A4EF)), // Blue
              Container(width: squareSize, height: squareSize, color: const Color(0xFFFFB900)), // Yellow
            ],
          ),
        ],
      ),
    );
  }
}
