import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:unspammer/models/dummy_data.dart';
import 'package:unspammer/theme.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> with TickerProviderStateMixin {
  int _selectedFilter = 0;
  late AnimationController _animController;
  late AnimationController _shimmerController;

  List<Email> get _filteredEmails {
    if (_selectedFilter == 0) return dummyEmails;
    if (_selectedFilter == 1)
      return dummyEmails.where((e) => e.isImportant).toList();
    return dummyEmails.where((e) => !e.isImportant).toList();
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _changeFilter(int index) {
    if (_selectedFilter != index) {
      setState(() => _selectedFilter = index);
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEmails = _filteredEmails;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background gradients
          const RepaintBoundary(child: _AnimatedBackgroundOrbs()),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  AppColors.textPrimary,
                                  AppColors.gold,
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'Inbox',
                                style: context.textStyles.displaySmall
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _FilterChips(
                          selectedIndex: _selectedFilter,
                          onSelected: _changeFilter,
                        ),
                      ],
                    ),
                  ),
                ),

                // Email List
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final email = filteredEmails[index];
                      return AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          final delay = (index * 0.15).clamp(0.0, 0.7);
                          final normalized = (_animController.value - delay) /
                              (1.0 - delay);
                          final safeProgress = normalized.isFinite
                              ? normalized.clamp(0.0, 1.0).toDouble()
                              : 0.0;
                          final motion =
                              Curves.easeOutCubic.transform(safeProgress);
                          final opacityProgress =
                              motion.clamp(0.0, 1.0).toDouble();
                          return Transform.translate(
                            offset: Offset(0, 24 * (1 - motion)),
                            child: Opacity(
                              opacity: opacityProgress,
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: EmailCard(
                            email: email,
                            shimmerController: _shimmerController,
                          ),
                        ),
                      );
                    }, childCount: filteredEmails.length),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.surface.withValues(alpha: 0.95),
                AppColors.surfaceLight.withValues(alpha: 0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              _PulsingIcon(
                icon: Icons.notifications_active_rounded,
                color: AppColors.gold,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Important Email',
                      style: context.textStyles.titleMedium,
                    ),
                    Text(
                      'Hackathon starts tomorrow!',
                      style: context.textStyles.bodySmall?.withColor(
                        AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _AnimatedBackgroundOrbs extends StatefulWidget {
  const _AnimatedBackgroundOrbs();

  @override
  State<_AnimatedBackgroundOrbs> createState() =>
      _AnimatedBackgroundOrbsState();
}

class _AnimatedBackgroundOrbsState extends State<_AnimatedBackgroundOrbs>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _OrbsPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _OrbsPainter extends CustomPainter {
  final double progress;
  _OrbsPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Orb 1 - Top right gold glow
    final orb1Center = Offset(
      size.width * 0.8 + math.sin(progress * 2 * math.pi) * 30,
      size.height * 0.15 + math.cos(progress * 2 * math.pi) * 20,
    );
    paint.shader = RadialGradient(
      colors: [
        AppColors.gold.withValues(alpha: 0.15),
        AppColors.gold.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromCircle(center: orb1Center, radius: 150));
    canvas.drawCircle(orb1Center, 150, paint);

    // Orb 2 - Bottom left olive glow
    final orb2Center = Offset(
      size.width * 0.2 + math.cos(progress * 2 * math.pi) * 25,
      size.height * 0.7 + math.sin(progress * 2 * math.pi) * 30,
    );
    paint.shader = RadialGradient(
      colors: [
        AppColors.olive.withValues(alpha: 0.12),
        AppColors.olive.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromCircle(center: orb2Center, radius: 120));
    canvas.drawCircle(orb2Center, 120, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _AnimatedCounter extends StatelessWidget {
  final int count;
  final String suffix;

  const _AnimatedCounter({required this.count, required this.suffix});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: count),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Text(
        '$value$suffix',
        style: context.textStyles.bodyMedium?.withColor(
          AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _AnimatedNotificationBell extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedNotificationBell({required this.onTap});

  @override
  State<_AnimatedNotificationBell> createState() =>
      _AnimatedNotificationBellState();
}

class _AnimatedNotificationBellState extends State<_AnimatedNotificationBell>
    with SingleTickerProviderStateMixin {
  late AnimationController _wiggleController;
  Timer? _wiggleTimer;

  @override
  void initState() {
    super.initState();
    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _startWiggleLoop();
  }

  void _startWiggleLoop() {
    _wiggleTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      _wiggleController.forward(from: 0).then((_) {
        if (mounted) {
          _wiggleController.reverse();
        }
      });
    });
  }

  @override
  void dispose() {
    _wiggleTimer?.cancel();
    _wiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _wiggleController,
        builder: (context, child) {
          final wiggle = math.sin(_wiggleController.value * math.pi * 4) * 0.1;
          return Transform.rotate(angle: wiggle, child: child);
        },
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface,
                AppColors.surfaceLight.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: AppColors.surfaceLight.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textPrimary,
                size: 26,
              ),
              Positioned(top: 10, right: 11, child: _PulsingDot()),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + _controller.value * 0.3;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(
                    alpha: 0.6 - _controller.value * 0.4,
                  ),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  const _PulsingIcon({required this.icon, required this.color});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3 * _controller.value),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(widget.icon, color: widget.color, size: 22),
        );
      },
    );
  }
}

class _FilterChips extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _FilterChips({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Important', 'Other'];
    final icons = [
      Icons.all_inbox_rounded,
      Icons.star_rounded,
      Icons.inventory_2_rounded,
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: List.generate(filters.length, (index) {
        final isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: () => onSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [AppColors.gold, AppColors.goldMuted],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : AppColors.surfaceLight,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icons[index],
                    size: 16,
                    color: isSelected
                        ? AppColors.background
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    filters[index],
                    style: context.textStyles.labelLarge?.copyWith(
                      color: isSelected
                          ? AppColors.background
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        );
      }),
    );
  }
}

class EmailCard extends StatefulWidget {
  final Email email;
  final AnimationController shimmerController;
  const EmailCard({
    super.key,
    required this.email,
    required this.shimmerController,
  });

  @override
  State<EmailCard> createState() => _EmailCardState();
}

class _EmailCardState extends State<EmailCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final email = widget.email;
    final timeAgo = _getTimeAgo(email.date);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: email.isImportant
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.background.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    AppColors.surfaceLight.withValues(alpha: 0.3),
                  ],
                ),
                border: email.isImportant
                    ? Border.all(
                        color: AppColors.gold.withValues(alpha: 0.5),
                        width: 1.5,
                      )
                    : Border.all(
                        color: AppColors.surfaceLight.withValues(alpha: 0.3),
                      ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar with gradient
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: email.isImportant
                                ? [
                                    AppColors.gold.withValues(alpha: 0.4),
                                    AppColors.goldMuted.withValues(alpha: 0.2),
                                  ]
                                : [AppColors.surfaceLight, AppColors.surface],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: email.isImportant
                              ? [
                                  BoxShadow(
                                    color: AppColors.gold.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            email.sender[0].toUpperCase(),
                            style: context.textStyles.titleLarge?.copyWith(
                              color: email.isImportant
                                  ? AppColors.gold
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Sender & Time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              email.sender,
                              style: context.textStyles.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 12,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  timeAgo,
                                  style: context.textStyles.labelSmall
                                      ?.withColor(AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Important badge with glow
                      if (email.isImportant)
                        _ImportantBadge(
                          shimmerController: widget.shimmerController,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Subject
                  Text(
                    email.subject,
                    style: context.textStyles.headlineSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Snippet
                  Text(
                    email.snippet,
                    style: context.textStyles.bodyMedium?.withColor(
                      AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}';
  }
}

class _ImportantBadge extends StatelessWidget {
  final AnimationController shimmerController;
  const _ImportantBadge({required this.shimmerController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gold.withValues(alpha: 0.2),
                AppColors.gold.withValues(
                  alpha:
                      0.1 +
                      0.1 * math.sin(shimmerController.value * math.pi * 2),
                ),
                AppColors.gold.withValues(alpha: 0.2),
              ],
              stops: [0.0, shimmerController.value, 1.0],
            ),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, color: AppColors.gold, size: 14),
              const SizedBox(width: 4),
              Text(
                'Important',
                style: context.textStyles.labelSmall?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

