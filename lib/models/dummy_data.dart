import 'package:flutter/foundation.dart';

class Email {
  final String id;
  final String sender;
  final String subject;
  final String snippet;
  final DateTime date;
  final DateTime? eventDate;
  bool isImportant;
  final bool hasEvent;
  final EmailCategory category;
  final String? courseCode;

  Email({
    required this.id,
    required this.sender,
    required this.subject,
    required this.snippet,
    required this.date,
    this.eventDate,
    required this.isImportant,
    this.hasEvent = false,
    required this.category,
    this.courseCode,
  });
}

enum EmailCategory {
  blackboard,
  registrar,
  direct,
  other
}

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
final List<Email> dummyEmails = [
  // 1. Important, Dated
  Email(
    id: 'e1',
    sender: 'Ahmed Taha',
    subject: 'Project Meeting',
    snippet: 'Hey, let\'s meet tomorrow to discuss the final project presentation.',
    date: DateTime.now().subtract(const Duration(minutes: 5)),
    eventDate: DateTime.now().add(const Duration(days: 1, hours: 2)),
    isImportant: true,
    hasEvent: true,
    category: EmailCategory.direct,
  ),
  // 2. Important, Dated
  Email(
    id: 'e2',
    sender: 'Blackboard Learn',
    subject: 'Quiz Reminder for COE292',
    snippet: 'Don\'t forget tomorrow\'s quiz on Ch 3.',
    date: DateTime.now().subtract(const Duration(hours: 20)),
    eventDate: DateTime.now().add(const Duration(days: 1)),
    isImportant: true,
    hasEvent: true,
    category: EmailCategory.blackboard,
    courseCode: 'COE292',
  ),
  // 3. Important, Undated
  Email(
    id: 'e3',
    sender: 'Registrar Office',
    subject: 'Course Registration Result',
    snippet: 'Your courses for the upcoming semester have been confirmed.',
    date: DateTime.now().subtract(const Duration(days: 1)),
    isImportant: true,
    hasEvent: false,
    category: EmailCategory.registrar,
  ),
  // 4. Important, Undated
  Email(
    id: 'e4',
    sender: 'Blackboard Learn',
    subject: 'Assignment Graded: SWE316',
    snippet: 'Your recent assignment has been graded. Click to view your feedback.',
    date: DateTime.now().subtract(const Duration(hours: 2)),
    isImportant: true,
    hasEvent: false,
    category: EmailCategory.blackboard,
    courseCode: 'SWE316',
  ),
  // 5. Unimportant, Dated
  Email(
    id: 'e5',
    sender: 'Dean of Student Affairs',
    subject: 'Hackathon Registration Open!',
    snippet: 'Don\'t miss the upcoming KFUPM hackathon this weekend. Great prizes and food!',
    date: DateTime.now().subtract(const Duration(minutes: 15)),
    eventDate: DateTime.now().add(const Duration(days: 2, hours: 10)),
    isImportant: false,
    hasEvent: true,
    category: EmailCategory.other,
  ),
  // 6. Unimportant, Dated
  Email(
    id: 'e6',
    sender: 'Career Services',
    subject: 'Job Fair This Thursday!',
    snippet: 'Top companies including Aramco, SABIC, and STC will be recruiting on campus.',
    date: DateTime.now().subtract(const Duration(hours: 8)),
    eventDate: DateTime.now().add(const Duration(days: 3, hours: 9)),
    isImportant: false,
    hasEvent: true,
    category: EmailCategory.other,
  ),
  // 7. Unimportant, Undated
  Email(
    id: 'e7',
    sender: 'Campus Dining',
    subject: 'Weekly Menu Updates & Discounts',
    snippet: 'Check out the new meals available at the student mall food court this week.',
    date: DateTime.now().subtract(const Duration(hours: 5)),
    isImportant: false,
    hasEvent: false,
    category: EmailCategory.other,
  ),
  // 8. Unimportant, Undated
  Email(
    id: 'e8',
    sender: 'KFUPM Newsletter',
    subject: 'Weekly Tech News',
    snippet: 'A round-up of the latest technology news around the campus.',
    date: DateTime.now().subtract(const Duration(days: 2)),
    isImportant: false,
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
