import 'package:flutter/foundation.dart';
import 'package:unspammer/models/email_model.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String sourceEmailId;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.sourceEmailId,
  });
}

// Dummy Data
final List<EmailModel> dummyEmails = [
  // 1. Important, Dated
  EmailModel(
    id: 'e1',
    fromAddress: 'Ahmed Taha',
    subject: 'Project Meeting',
    summary: 'Hey, let\'s meet tomorrow to discuss the final project presentation.',
    body: 'Hey, let\'s meet tomorrow to discuss the final project presentation.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    eventDate: DateTime.now().add(const Duration(days: 1, hours: 2)),
    classification: 'important',
    hasEvent: true,
    category: EmailCategory.direct,
  ),
  // 2. Important, Dated
  EmailModel(
    id: 'e2',
    fromAddress: 'Blackboard Learn',
    subject: 'Quiz Reminder for COE292',
    summary: 'Don\'t forget tomorrow\'s quiz on Ch 3.',
    body: 'Don\'t forget tomorrow\'s quiz on Ch 3.',
    timestamp: DateTime.now().subtract(const Duration(hours: 20)),
    eventDate: DateTime.now().add(const Duration(days: 1)),
    classification: 'important',
    hasEvent: true,
    category: EmailCategory.blackboard,
    courseCode: 'COE292',
  ),
  // 3. Important, Undated
  EmailModel(
    id: 'e3',
    fromAddress: 'Registrar Office',
    subject: 'Course Registration Result',
    summary: 'Your courses for the upcoming semester have been confirmed.',
    body: 'Your courses for the upcoming semester have been confirmed.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    classification: 'important',
    hasEvent: false,
    category: EmailCategory.registrar,
  ),
  // 4. Important, Undated
  EmailModel(
    id: 'e4',
    fromAddress: 'Blackboard Learn',
    subject: 'Assignment Graded: SWE316',
    summary: 'Your recent assignment has been graded. Click to view your feedback.',
    body: 'Your recent assignment has been graded. Click to view your feedback.',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    classification: 'important',
    hasEvent: false,
    category: EmailCategory.blackboard,
    courseCode: 'SWE316',
  ),
  // 5. Unimportant, Dated
  EmailModel(
    id: 'e5',
    fromAddress: 'Dean of Student Affairs',
    subject: 'Hackathon Registration Open!',
    summary: 'Don\'t miss the upcoming KFUPM hackathon this weekend. Great prizes and food!',
    body: 'Don\'t miss the upcoming KFUPM hackathon this weekend. Great prizes and food!',
    timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    eventDate: DateTime.now().add(const Duration(days: 2, hours: 10)),
    classification: 'not_important',
    hasEvent: true,
    category: EmailCategory.other,
  ),
  // 6. Unimportant, Dated
  EmailModel(
    id: 'e6',
    fromAddress: 'Career Services',
    subject: 'Job Fair This Thursday!',
    summary: 'Top companies including Aramco, SABIC, and STC will be recruiting on campus.',
    body: 'Top companies including Aramco, SABIC, and STC will be recruiting on campus.',
    timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    eventDate: DateTime.now().add(const Duration(days: 3, hours: 9)),
    classification: 'not_important',
    hasEvent: true,
    category: EmailCategory.other,
  ),
  // 7. Unimportant, Undated
  EmailModel(
    id: 'e7',
    fromAddress: 'Campus Dining',
    subject: 'Weekly Menu Updates & Discounts',
    summary: 'Check out the new meals available at the student mall food court this week.',
    body: 'Check out the new meals available at the student mall food court this week.',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    classification: 'not_important',
    hasEvent: false,
    category: EmailCategory.other,
  ),
  // 8. Unimportant, Undated
  EmailModel(
    id: 'e8',
    fromAddress: 'KFUPM Newsletter',
    subject: 'Weekly Tech News',
    summary: 'A round-up of the latest technology news around the campus.',
    body: 'A round-up of the latest technology news around the campus.',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    classification: 'not_important',
    hasEvent: false,
    category: EmailCategory.other,
  ),
];

final List<CalendarEvent> dummyEvents = [
  CalendarEvent(
    id: 'c1',
    title: 'Project Meeting',
    description: 'Hey, let\'s meet tomorrow to discuss the final project presentation.',
    date: DateTime.now().add(const Duration(days: 1, hours: 2)),
    sourceEmailId: 'e1',
  ),
  CalendarEvent(
    id: 'c2',
    title: 'Quiz Reminder for COE292',
    description: 'Don\'t forget tomorrow\'s quiz on Ch 3.',
    date: DateTime.now().add(const Duration(days: 1)),
    sourceEmailId: 'e2',
  ),
];

final ValueNotifier<int> appNavigationIndex = ValueNotifier(0);
final ValueNotifier<DateTime?> appCalendarJumpDate = ValueNotifier(null);
