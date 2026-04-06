import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:unspammer/models/dummy_data.dart';
import 'package:unspammer/theme.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with TickerProviderStateMixin {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;
  late AnimationController _eventAnimController;
  late AnimationController _backgroundController;
  late final Map<String, List<CalendarEvent>> _eventsByDay;

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _selectedDate = DateTime.now();
    _eventAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _eventsByDay = <String, List<CalendarEvent>>{};
    for (final event in dummyEvents) {
      _eventsByDay.putIfAbsent(_dateKey(event.date), () => <CalendarEvent>[]).add(
        event,
      );
    }
  }

  @override
  void dispose() {
    _eventAnimController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  List<CalendarEvent> _getEventsForDate(DateTime date) {
    return List<CalendarEvent>.unmodifiable(
      _eventsByDay[_dateKey(date)] ?? const <CalendarEvent>[],
    );
  }

  bool _hasEventsOnDate(DateTime date) {
    return _eventsByDay.containsKey(_dateKey(date));
  }

  void _selectDate(DateTime date) {
    if (_selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day) {
      return;
    }
    setState(() => _selectedDate = date);
    _eventAnimController.reset();
    _eventAnimController.forward();
  }

  void _jumpToToday() {
    final now = DateTime.now();
    setState(() => _focusedMonth = DateTime(now.year, now.month));
    _selectDate(now);
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _getEventsForDate(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background
          _AnimatedCalendarBackground(controller: _backgroundController),

          SafeArea(
            child: Stack(
              children: [
                ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    AppColors.textPrimary,
                                    AppColors.gold.withValues(alpha: 0.8),
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  'Calendar',
                                  style: context.textStyles.displaySmall
                                      ?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              _AnimatedEventCount(count: dummyEvents.length),
                            ],
                          ),
                          _AnimatedTodayButton(onTap: _jumpToToday),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Calendar
                    _CalendarWidget(
                      focusedMonth: _focusedMonth,
                      selectedDate: _selectedDate,
                      hasEventsOnDate: _hasEventsOnDate,
                      onDateSelected: _selectDate,
                      onMonthChanged: (month) =>
                          setState(() => _focusedMonth = month),
                    ),

                    // Keep room so content remains visible above the panel.
                    const SizedBox(height: 260),
                  ],
                ),
                Positioned.fill(
                  child: _EventsPanel(
                    selectedDate: _selectedDate,
                    events: selectedEvents,
                    animController: _eventAnimController,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCalendarBackground extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedCalendarBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _CalendarBackgroundPainter(controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CalendarBackgroundPainter extends CustomPainter {
  final double progress;
  _CalendarBackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Large olive orb
    final orb1Center = Offset(
      size.width * 0.9 + math.cos(progress * 2 * math.pi) * 40,
      size.height * 0.4 + math.sin(progress * 2 * math.pi) * 30,
    );
    paint.shader = RadialGradient(
      colors: [
        AppColors.olive.withValues(alpha: 0.1),
        AppColors.olive.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromCircle(center: orb1Center, radius: 200));
    canvas.drawCircle(orb1Center, 200, paint);

    // Gold accent orb
    final orb2Center = Offset(
      size.width * 0.1 + math.sin(progress * 2 * math.pi) * 20,
      size.height * 0.2 + math.cos(progress * 2 * math.pi) * 25,
    );
    paint.shader = RadialGradient(
      colors: [
        AppColors.gold.withValues(alpha: 0.08),
        AppColors.gold.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromCircle(center: orb2Center, radius: 100));
    canvas.drawCircle(orb2Center, 100, paint);
  }

  @override
  bool shouldRepaint(covariant _CalendarBackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _AnimatedEventCount extends StatelessWidget {
  final int count;
  const _AnimatedEventCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: count),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$value upcoming events',
            style: context.textStyles.bodyMedium?.withColor(
              AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedTodayButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedTodayButton({required this.onTap});

  @override
  State<_AnimatedTodayButton> createState() => _AnimatedTodayButtonState();
}

class _AnimatedTodayButtonState extends State<_AnimatedTodayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface,
                    AppColors.surfaceLight.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: AppColors.gold.withValues(
                    alpha: 0.3 + 0.2 * _glowController.value,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(
                      alpha: 0.1 + 0.1 * _glowController.value,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.today_rounded, color: AppColors.gold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Today',
                    style: context.textStyles.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CalendarWidget extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final bool Function(DateTime) hasEventsOnDate;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;

  const _CalendarWidget({
    required this.focusedMonth,
    required this.selectedDate,
    required this.hasEventsOnDate,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.surface,
              AppColors.surfaceLight.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.surfaceLight.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.background.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            _MonthSelector(
              focusedMonth: focusedMonth,
              onPrevious: () => onMonthChanged(
                DateTime(focusedMonth.year, focusedMonth.month - 1),
              ),
              onNext: () => onMonthChanged(
                DateTime(focusedMonth.year, focusedMonth.month + 1),
              ),
            ),
            const SizedBox(height: 20),
            _WeekdayHeaders(),
            const SizedBox(height: 12),
            _CalendarGrid(
              focusedMonth: focusedMonth,
              selectedDate: selectedDate,
              hasEventsOnDate: hasEventsOnDate,
              onDateSelected: onDateSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final DateTime focusedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthSelector({
    required this.focusedMonth,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ArrowButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
        Column(
          children: [
            Text(
              months[focusedMonth.month - 1],
              style: context.textStyles.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${focusedMonth.year}',
              style: context.textStyles.labelMedium?.withColor(
                AppColors.textMuted,
              ),
            ),
          ],
        ),
        _ArrowButton(icon: Icons.chevron_right_rounded, onTap: onNext),
      ],
    );
  }
}

class _ArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _isPressed
              ? AppColors.gold.withValues(alpha: 0.2)
              : AppColors.surfaceLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: _isPressed
                ? AppColors.gold.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Icon(
          widget.icon,
          color: _isPressed ? AppColors.gold : AppColors.textPrimary,
          size: 24,
        ),
      ),
    );
  }
}

class _WeekdayHeaders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map(
            (day) => SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  day,
                  style: context.textStyles.labelSmall?.copyWith(
                    color: day == 'Sat' || day == 'Sun'
                        ? AppColors.gold.withValues(alpha: 0.7)
                        : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final bool Function(DateTime) hasEventsOnDate;
  final ValueChanged<DateTime> onDateSelected;

  const _CalendarGrid({
    required this.focusedMonth,
    required this.selectedDate,
    required this.hasEventsOnDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final today = DateTime.now();
    final totalCells = ((firstWeekday - 1) + daysInMonth / 7).ceil() * 7;
    final weeks = (totalCells / 7).ceil().clamp(5, 6);

    return Column(
      children: List.generate(weeks, (weekIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (dayIndex) {
              final cellIndex = weekIndex * 7 + dayIndex;
              final dayNumber = cellIndex - (firstWeekday - 2);

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox(width: 40, height: 44);
              }

              final date = DateTime(
                focusedMonth.year,
                focusedMonth.month,
                dayNumber,
              );
              final isToday =
                  date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final isSelected =
                  date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              final hasEvents = hasEventsOnDate(date);

              return _CalendarDay(
                dayNumber: dayNumber,
                isToday: isToday,
                isSelected: isSelected,
                hasEvents: hasEvents,
                onTap: () => onDateSelected(date),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _CalendarDay extends StatefulWidget {
  final int dayNumber;
  final bool isToday;
  final bool isSelected;
  final bool hasEvents;
  final VoidCallback onTap;

  const _CalendarDay({
    required this.dayNumber,
    required this.isToday,
    required this.isSelected,
    required this.hasEvents,
    required this.onTap,
  });

  @override
  State<_CalendarDay> createState() => _CalendarDayState();
}

class _CalendarDayState extends State<_CalendarDay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.hasEvents && !widget.isSelected) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _CalendarDay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasEvents && !widget.isSelected) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 40,
        height: 44,
        decoration: BoxDecoration(
          gradient: widget.isSelected
              ? LinearGradient(
                  colors: [AppColors.gold, AppColors.goldMuted],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: widget.isSelected
              ? null
              : widget.isToday
              ? AppColors.gold.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${widget.dayNumber}',
              style: context.textStyles.titleMedium?.copyWith(
                color: widget.isSelected
                    ? AppColors.background
                    : widget.isToday
                    ? AppColors.gold
                    : AppColors.textPrimary,
                fontWeight: widget.isSelected || widget.isToday
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
            if (widget.hasEvents && !widget.isSelected)
              Positioned(
                bottom: 4,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.olive,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.olive.withValues(
                              alpha: 0.5 * _controller.value,
                            ),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EventsPanel extends StatelessWidget {
  final DateTime selectedDate;
  final List<CalendarEvent> events;
  final AnimationController animController;

  const _EventsPanel({
    required this.selectedDate,
    required this.events,
    required this.animController,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: true,
      minChildSize: 0.22,
      initialChildSize: 0.34,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.22, 0.34, 0.62, 0.9],
      builder: (context, scrollController) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.surface,
                AppColors.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            border: Border(
              top: BorderSide(
                color: AppColors.surfaceLight.withValues(alpha: 0.6),
                width: 1.2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.background.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                      child: Row(
                        children: [
                          _AnimatedDateBadge(date: selectedDate),
                          const SizedBox(width: 12),
                          Text(
                            events.isEmpty
                                ? 'No events'
                                : '${events.length} event${events.length > 1 ? 's' : ''}',
                            style: context.textStyles.bodyMedium?.withColor(
                              AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (events.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyEventsView(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverList.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: animController,
                        builder: (context, child) {
                          final delay = (index * 0.2).clamp(0.0, 0.6);
                          final normalized =
                              ((animController.value - delay) / (1 - delay));
                          final safeNormalized = normalized.isFinite
                              ? normalized.clamp(0.0, 1.0).toDouble()
                              : 0.0;
                          final motionProgress = Curves.easeOutBack.transform(
                            safeNormalized,
                          );
                          final safeMotion = motionProgress.isFinite
                              ? motionProgress
                              : 0.0;
                          final opacityProgress =
                              safeMotion.clamp(0.0, 1.0).toDouble();
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - safeMotion)),
                            child: Opacity(
                              opacity: opacityProgress,
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: EventCard(event: events[index], index: index),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedDateBadge extends StatefulWidget {
  final DateTime date;
  const _AnimatedDateBadge({required this.date});

  @override
  State<_AnimatedDateBadge> createState() => _AnimatedDateBadgeState();
}

class _AnimatedDateBadgeState extends State<_AnimatedDateBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedDateBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + 0.2 * Curves.elasticOut.transform(_controller.value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.36),
                  AppColors.goldMuted.withValues(alpha: 0.28),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.55)),
            ),
            child: Text(
              _formatDate(widget.date),
              style: context.textStyles.labelLarge?.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyEventsView extends StatefulWidget {
  @override
  State<_EmptyEventsView> createState() => _EmptyEventsViewState();
}

class _EmptyEventsViewState extends State<_EmptyEventsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, -5 * math.sin(_controller.value * math.pi)),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.surfaceLight.withValues(alpha: 0.4),
                        AppColors.surfaceLight.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(
                          alpha: 0.1 * _controller.value,
                        ),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.event_available_rounded,
                    color: AppColors.textMuted.withValues(
                      alpha: 0.6 + 0.4 * _controller.value,
                    ),
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No events',
                style: context.textStyles.headlineSmall?.withColor(
                  AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nothing scheduled for this day',
                style: context.textStyles.bodyMedium?.withColor(
                  AppColors.textMuted,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class EventCard extends StatefulWidget {
  final CalendarEvent event;
  final int index;
  const EventCard({super.key, required this.event, required this.index});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _isPressed = false;

  final List<Color> _accentColors = [
    AppColors.gold,
    AppColors.olive,
    AppColors.goldMuted,
    AppColors.oliveDeep,
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColors[widget.index % _accentColors.length];

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(
                      alpha: 0.1 + 0.1 * _glowController.value,
                    ),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                    AppColors.surface,
                    AppColors.forestGreen,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.surfaceLight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated time indicator
                Container(
                  width: 5,
                  height: 75,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withValues(alpha: 0.5)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  color: accentColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _formatTime(widget.event.date),
                                  style: context.textStyles.labelSmall
                                      ?.copyWith(
                                        color: accentColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.event.title,
                        style: context.textStyles.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.event.description,
                        style: context.textStyles.bodyMedium?.withColor(
                          AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

