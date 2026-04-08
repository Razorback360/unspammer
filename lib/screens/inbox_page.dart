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
  EmailCategory? _categoryFilter;
  String? _courseFilter;
  late AnimationController _animController;
  late AnimationController _shimmerController;

  List<String> get _availableCourses {
    return dummyEmails
        .where((e) => e.isImportant && e.courseCode != null)
        .map((e) => e.courseCode!)
        .toSet()
        .toList();
  }

  List<Email> get _filteredEmails {
    if (_selectedFilter == 0) return dummyEmails;
    if (_selectedFilter == 2) {
      return dummyEmails.where((e) => !e.isImportant).toList();
    }

    // Important tab (_selectedFilter == 1)
    var filtered = dummyEmails.where((e) => e.isImportant).toList();

    if (_categoryFilter != null) {
      filtered = filtered.where((e) => e.category == _categoryFilter).toList();
    }

    if (_courseFilter != null) {
      filtered = filtered.where((e) => e.courseCode == _courseFilter).toList();
    }

    return filtered;
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
      setState(() {
        _selectedFilter = index;
        _categoryFilter = null;
        _courseFilter = null;
      });
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
                        Text(
                          'Good morning,',
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Student',
                              style: context.textStyles.displaySmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('👋', style: TextStyle(fontSize: 24)),
                            const Spacer(),
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
                          ],
                        ),
                        const SizedBox(height: 20),
                        _FilterChips(
                          selectedIndex: _selectedFilter,
                          onSelected: _changeFilter,
                        ),
                        if (_selectedFilter == 1) ...[
                          const SizedBox(height: 16),
                          _ImportantFilters(
                            selectedCategory: _categoryFilter,
                            selectedCourse: _courseFilter,
                            availableCourses: _availableCourses,
                            onCategoryChanged: (category) {
                              setState(() {
                                _categoryFilter = category;
                                _courseFilter = null;
                              });
                            },
                            onCourseChanged: (course) {
                              setState(() {
                                _courseFilter = course;
                              });
                            },
                          ),
                        ],
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
                          final normalized =
                              (_animController.value - delay) / (1.0 - delay);
                          final safeProgress = normalized.isFinite
                              ? normalized.clamp(0.0, 1.0).toDouble()
                              : 0.0;
                          final motion = Curves.easeOutCubic.transform(
                            safeProgress,
                          );
                          final opacityProgress = motion
                              .clamp(0.0, 1.0)
                              .toDouble();
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
                            onToggleImportant: () {
                              setState(() {
                                email.isImportant = !email.isImportant;
                              });
                            },
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
}

class _FilterChips extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _FilterChips({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Important', 'Other'];
    final alignment = selectedIndex == 0
        ? Alignment.centerLeft
        : selectedIndex == 1
        ? Alignment.center
        : Alignment.centerRight;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.isDark
            ? Colors.black.withValues(alpha: 0.25)
            : AppColors.navy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.navy.withValues(alpha: 0.1),
        ),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: alignment,
            child: FractionallySizedBox(
              widthFactor: 1 / 3,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: List.generate(filters.length, (index) {
              final isSelected = selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(index),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: context.textStyles.labelLarge!.copyWith(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      child: Text(filters[index]),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ImportantFilters extends StatelessWidget {
  final EmailCategory? selectedCategory;
  final String? selectedCourse;
  final List<String> availableCourses;
  final ValueChanged<EmailCategory?> onCategoryChanged;
  final ValueChanged<String?> onCourseChanged;

  const _ImportantFilters({
    required this.selectedCategory,
    required this.selectedCourse,
    required this.availableCourses,
    required this.onCategoryChanged,
    required this.onCourseChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'All',
            isSelected: selectedCategory == null && selectedCourse == null,
            onTap: () {
              onCategoryChanged(null);
              onCourseChanged(null);
            },
          ),
          for (final course in availableCourses)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _Chip(
                label: course,
                isSelected: selectedCourse == course,
                onTap: () {
                  onCategoryChanged(EmailCategory.blackboard);
                  onCourseChanged(course);
                },
              ),
            ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Registrar',
            isSelected: selectedCategory == EmailCategory.registrar,
            onTap: () {
              onCategoryChanged(EmailCategory.registrar);
              onCourseChanged(null);
            },
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Direct',
            isSelected: selectedCategory == EmailCategory.direct,
            onTap: () {
              onCategoryChanged(EmailCategory.direct);
              onCourseChanged(null);
            },
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (AppColors.isDark
                    ? AppColors.gold.withValues(alpha: 0.2)
                    : AppColors.gold.withValues(alpha: 0.1))
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppColors.gold
                : (AppColors.isDark ? Colors.white24 : Colors.black12),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: context.textStyles.labelMedium?.copyWith(
            color: isSelected ? AppColors.gold : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class EmailCard extends StatefulWidget {
  final Email email;
  final AnimationController shimmerController;
  final VoidCallback? onToggleImportant;
  const EmailCard({
    super.key,
    required this.email,
    required this.shimmerController,
    this.onToggleImportant,
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.05),
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
                border: Border(
                  left: BorderSide(
                    color: email.isImportant ? AppColors.gold : AppColors.green,
                    width: 6,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar with solid fill
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: email.isImportant
                              ? AppColors.gold.withValues(alpha: 0.2)
                              : AppColors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Center(
                          child: Text(
                            email.sender.substring(0, 2).toUpperCase(),
                            style: context.textStyles.titleMedium?.copyWith(
                              color: email.isImportant
                                  ? AppColors.gold
                                  : AppColors.green,
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
                            Text(
                              email.subject,
                              style: context.textStyles.labelMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Text(
                            timeAgo,
                            style: context.textStyles.labelSmall?.withColor(
                              AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              if (widget.onToggleImportant != null) {
                                widget.onToggleImportant!();
                              }
                            },
                            child: Icon(
                              email.isImportant
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: email.isImportant
                                  ? AppColors.gold
                                  : AppColors.textMuted,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Snippet
                  Text(
                    email.snippet,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!dummyEvents.any(
                        (e) => e.sourceEmailId == email.id,
                      )) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        DateTime? eventDate = email.eventDate;

                        if (!email.hasEvent || eventDate == null) {
                          // Allow user to select a date and time
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );

                          if (selectedDate == null) return; // User canceled

                          if (!context.mounted) return;

                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (selectedTime == null) return; // User canceled

                          eventDate = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                        }

                        setState(() {
                          dummyEvents.add(
                            CalendarEvent(
                              id: 'manual_${email.id}',
                              title: email.subject,
                              description: email.snippet,
                              date: eventDate!,
                              sourceEmailId: email.id,
                            ),
                          );
                        });
                        appCalendarJumpDate.value = eventDate;
                        appNavigationIndex.value = 1;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Add to calendar',
                              style: context.textStyles.labelMedium?.copyWith(
                                color: AppColors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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

// Nothing
