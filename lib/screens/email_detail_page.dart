import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unspammer/models/calendar_model.dart';
import 'package:unspammer/models/dummy_data.dart';
import 'package:unspammer/models/email_model.dart';
import 'package:unspammer/services/database_service.dart';
import 'package:unspammer/theme.dart';

class EmailDetailPage extends StatefulWidget {
  final EmailModel email;
  final VoidCallback? onToggleImportant;

  const EmailDetailPage({
    super.key,
    required this.email,
    this.onToggleImportant,
  });

  @override
  State<EmailDetailPage> createState() => _EmailDetailPageState();
}

class _EmailDetailPageState extends State<EmailDetailPage> {
  late bool _isImportant;
  bool _backPressed = false;
  bool _starPressed = false;

  @override
  void initState() {
    super.initState();
    _isImportant = widget.email.isImportant;
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    const months = [
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
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email;
    final accentColor = _isImportant ? AppColors.gold : AppColors.green;
    final initials = email.fromAddress.length >= 2
        ? email.fromAddress.substring(0, 2).toUpperCase()
        : email.fromAddress.toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top navigation bar ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  GestureDetector(
                    onTapDown: (_) => setState(() => _backPressed = true),
                    onTapUp: (_) {
                      setState(() => _backPressed = false);
                      Navigator.of(context).pop();
                    },
                    onTapCancel: () => setState(() => _backPressed = false),
                    child: AnimatedScale(
                      scale: _backPressed ? 0.90 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.navy.withValues(alpha: 0.07),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  // Star button
                  GestureDetector(
                    onTapDown: (_) => setState(() => _starPressed = true),
                    onTapUp: (_) {
                      setState(() {
                        _starPressed = false;
                        _isImportant = !_isImportant;
                      });
                      widget.onToggleImportant?.call();
                    },
                    onTapCancel: () => setState(() => _starPressed = false),
                    child: AnimatedScale(
                      scale: _starPressed ? 0.88 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _isImportant
                              ? AppColors.gold.withValues(alpha: 0.14)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.navy.withValues(alpha: 0.07),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isImportant
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 20,
                          color: _isImportant
                              ? AppColors.gold
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable content ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sender row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _isImportant
                                ? AppColors.gold.withValues(alpha: 0.18)
                                : AppColors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: context.textStyles.titleLarge?.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Sender name + timestamp
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                email.fromAddress,
                                style: context.textStyles.titleMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _formatTimestamp(email.timestamp),
                                style: context.textStyles.labelSmall?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Classification badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _isImportant
                                ? AppColors.gold.withValues(alpha: 0.12)
                                : AppColors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: _isImportant
                                  ? AppColors.gold.withValues(alpha: 0.55)
                                  : AppColors.green.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            _isImportant ? 'Important' : 'Other',
                            style: context.textStyles.labelSmall?.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Subject
                    Text(
                      email.subject,
                      style: context.textStyles.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Divider(color: AppColors.border, height: 1),

                    const SizedBox(height: 20),

                    // AI Summary block
                    if (email.summary.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.isDark
                              ? AppColors.gold.withValues(alpha: 0.07)
                              : AppColors.gold.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border(
                            left: BorderSide(color: AppColors.gold, width: 4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 13,
                                  color: AppColors.gold,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'AI SUMMARY',
                                  style: context.textStyles.labelSmall
                                      ?.copyWith(
                                        color: AppColors.gold,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              email.summary,
                              style: context.textStyles.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Full body text
                    Text(
                      email.body,
                      style: context.textStyles.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.65,
                      ),
                    ),

                    // Add to calendar button
                    if (email.eventDate == null) ...[
                      const SizedBox(height: 32),
                      _AddToCalendarButton(email: email),
                    ] else ...[
                      const SizedBox(height: 32),
                      _EventDateChip(eventDate: email.eventDate!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add to Calendar button ────────────────────────────────────────────────────

class _AddToCalendarButton extends StatefulWidget {
  final EmailModel email;
  const _AddToCalendarButton({required this.email});

  @override
  State<_AddToCalendarButton> createState() => _AddToCalendarButtonState();
}

class _AddToCalendarButtonState extends State<_AddToCalendarButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) async {
        setState(() => _pressed = false);

        DateTime? eventDate = widget.email.eventDate;

        if (!widget.email.hasEvent || eventDate == null) {
          final selectedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (selectedDate == null) return;
          if (!context.mounted) return;

          final selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (selectedTime == null) return;

          eventDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        }

        if (!context.mounted) return;

        final db = context.read<DatabaseService>();
        final calEvent = CalendarEvent(
          id: 'manual_${widget.email.id}',
          title: widget.email.subject,
          description: widget.email.summary.isNotEmpty
              ? widget.email.summary
              : widget.email.body,
          date: eventDate,
          sourceEmailId: widget.email.id,
        );
        await db.insertEvent(calEvent);
        await db.updateEmailEventDate(
          id: widget.email.id,
          eventDate: eventDate,
        );

        appCalendarJumpDate.value = eventDate;
        appNavigationIndex.value = 1;

        if (context.mounted) Navigator.of(context).pop();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: AppColors.green,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Add to Calendar',
                style: context.textStyles.labelLarge?.copyWith(
                  color: AppColors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Event date pill (when event is already set) ───────────────────────────────

class _EventDateChip extends StatelessWidget {
  final DateTime eventDate;
  const _EventDateChip({required this.eventDate});

  String _format(DateTime dt) {
    const months = [
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
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  ·  $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available_rounded, color: AppColors.green, size: 16),
          const SizedBox(width: 8),
          Text(
            'Event: ${_format(eventDate)}',
            style: context.textStyles.labelMedium?.copyWith(
              color: AppColors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
