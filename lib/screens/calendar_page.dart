import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unspammer/models/calendar_model.dart';
import 'package:unspammer/models/dummy_data.dart';
import 'package:unspammer/services/database_service.dart';
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

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

   void _onJumpDateChanged() {
    if (appCalendarJumpDate.value != null) {
      setState(() {
        _focusedMonth = DateTime(
          appCalendarJumpDate.value!.year,
          appCalendarJumpDate.value!.month,
        );
        _selectedDate = appCalendarJumpDate.value!;
      });
      _eventAnimController.reset();
      _eventAnimController.forward();
      appCalendarJumpDate.value = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _selectedDate = DateTime.now();

    if (appCalendarJumpDate.value != null) {
      _focusedMonth = DateTime(
        appCalendarJumpDate.value!.year,
        appCalendarJumpDate.value!.month,
      );
      _selectedDate = appCalendarJumpDate.value!;
      appCalendarJumpDate.value = null;
    }

    appCalendarJumpDate.addListener(_onJumpDateChanged);

    _eventAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    appCalendarJumpDate.removeListener(_onJumpDateChanged);
    _eventAnimController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Map<String, List<CalendarEvent>> _computeEvents(List<CalendarEvent> events) {
    final map = <String, List<CalendarEvent>>{};
    for (final event in events) {
      map.putIfAbsent(_dateKey(event.date), () => []).add(event);
    }
    return map;
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

  void _showAddEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Add Event', style: context.textStyles.titleLarge),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: 'Event Title'),
          style: context.textStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                context.read<DatabaseService>().insertEvent(
                  CalendarEvent(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    description: 'Custom scheduled event',
                    date: _selectedDate,
                    sourceEmailId: '',
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: Text('Add', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CalendarEvent>>(
      stream: context.read<DatabaseService>().watchAllEvents(),
      initialData: const [],
      builder: (context, snapshot) {
        final events = snapshot.data ?? const [];
        final eventsMap = _computeEvents(events);
        bool hasEventsOnDate(DateTime date) =>
            eventsMap.containsKey(_dateKey(date));
        final selectedEvents = eventsMap[_dateKey(_selectedDate)] ?? [];

        final months = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December',
        ];
        final monthName = months[_focusedMonth.month - 1];

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: Stack(
            children: [
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Schedule',
                                      style: context.textStyles.displaySmall
                                          ?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${events.length} upcoming events - $monthName ${_focusedMonth.year}',
                                      style: context.textStyles.bodyMedium
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      AppColors.isDark
                                          ? Icons.light_mode_rounded
                                          : Icons.dark_mode_rounded,
                                      color: AppColors.textPrimary,
                                    ),
                                    onPressed: () {
                                      AppColors.toggleTheme();
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  _AnimatedTodayButton(onTap: _jumpToToday),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Calendar
                        _CalendarWidget(
                          focusedMonth: _focusedMonth,
                          selectedDate: _selectedDate,
                          hasEventsOnDate: hasEventsOnDate,
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
                        onDeleteEvent: (event) {
                          context.read<DatabaseService>().deleteEvent(event.id);
                        },
                        onAddEvent: () => _showAddEventDialog(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
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
          color: widget.isSelected
              ? AppColors.green
              : widget.isToday
              ? AppColors.green.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${widget.dayNumber}',
              style: context.textStyles.titleMedium?.copyWith(
                color: widget.isSelected
                    ? AppColors.white
                    : widget.isToday
                    ? AppColors.green
                    : AppColors.textPrimary,
                fontWeight: widget.isSelected || widget.isToday
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
            if (widget.hasEvents && !widget.isSelected)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
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
  final ValueChanged<CalendarEvent> onDeleteEvent;
  final VoidCallback onAddEvent;

  const _EventsPanel({
    required this.selectedDate,
    required this.events,
    required this.animController,
    required this.onDeleteEvent,
    required this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: true,
      minChildSize: 0.32,
      initialChildSize: 0.39,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.32, 0.39, 0.62, 0.9],
      builder: (context, scrollController) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.surfaceLight, AppColors.surfaceLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, -5),
              ),
            ],
            border: Border(
              top: BorderSide(color: AppColors.border, width: 1.0),
            ),
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
                          color: AppColors.textMuted,
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
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.border,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onAddEvent,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                border: Border.all(
                                  color: AppColors.green.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                color: AppColors.green,
                                size: 20,
                              ),
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
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: _EmptyEventsView(),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 24, 100),
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
                          final opacityProgress = safeMotion
                              .clamp(0.0, 1.0)
                              .toDouble();
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - safeMotion)),
                            child: Opacity(
                              opacity: opacityProgress,
                              child: child,
                            ),
                          );
                        },
                        child: EventCard(
                          event: events[index],
                          index: index,
                          isFirst: index == 0,
                          isLast: index == events.length - 1,
                          onDelete: () => onDeleteEvent(events[index]),
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
            child: Text(
              _formatDate(widget.date),
              style: context.textStyles.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
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
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onDelete;
  const EventCard({
    super.key,
    required this.event,
    required this.index,
    this.isFirst = false,
    this.isLast = false,
    this.onDelete,
  });

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

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time column
          SizedBox(
            width: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                Text(
                  _formatTimeHourMinute(widget.event.date),
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _formatTimePeriod(widget.event.date),
                  style: context.textStyles.labelSmall?.withColor(
                    AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Timeline column
          SizedBox(
            width: 30,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Vertical Line
                Positioned(
                  top: widget.isFirst ? 24 : 0,
                  bottom: widget.isLast ? null : 0,
                  height: widget.isLast ? 24 : null,
                  child: Container(width: 1, color: AppColors.border),
                ),
                // Colored Dot
                Positioned(
                  top: 22,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surfaceLight,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.navy.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.event.title,
                                  style: context.textStyles.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (widget.onDelete != null &&
                                  !widget.event.id.startsWith('auto_'))
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  color: AppColors.textMuted,
                                  onPressed: widget.onDelete,
                                ),
                            ],
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
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeHourMinute(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatTimePeriod(DateTime date) {
    return date.hour >= 12 ? 'PM' : 'AM';
  }
}
