class Email {
  final String id;
  final String sender;
  final String subject;
  final String snippet;
  final DateTime date;
  final bool isImportant;
  final bool hasEvent;
  final EmailCategory category;
  final String? courseCode;

  Email({
    required this.id,
    required this.sender,
    required this.subject,
    required this.snippet,
    required this.date,
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
  Email(
    id: 'e1',
    sender: 'Dean of Student Affairs',
    subject: 'Hackathon Registration Open!',
    snippet:
        'Don\'t miss the upcoming KFUPM hackathon this weekend. Great prizes and food!',
    date: DateTime.now().subtract(const Duration(minutes: 15)),
    isImportant: false,
    hasEvent: true,
    category: EmailCategory.other,
  ),
  Email(
    id: 'e2',
    sender: 'Blackboard Learn',
    subject: 'Assignment Graded: SWE316',
    snippet:
        'Your recent assignment has been graded. Click to view your feedback.',
    date: DateTime.now().subtract(const Duration(hours: 2)),
    isImportant: true,
    category: EmailCategory.blackboard,
    courseCode: 'SWE316',
  ),
  Email(
    id: 'e3',
    sender: 'Campus Dining',
    subject: 'Weekly Menu Updates & Discounts',
    snippet:
        'Check out the new meals available at the student mall food court this week.',
    date: DateTime.now().subtract(const Duration(hours: 5)),
    isImportant: false,
    category: EmailCategory.other,
  ),
  Email(
    id: 'e4',
    sender: 'Registrar Office',
    subject: 'Early Registration Reminder',
    snippet:
        'Early registration for the next semester begins on Tuesday. Prepare your schedule.',
    date: DateTime.now().subtract(const Duration(days: 1)),
    isImportant: true,
    hasEvent: true,
    category: EmailCategory.registrar,
  ),
  Email(
    id: 'e5',
    sender: 'KFUPM Newsletter',
    subject: 'Weekly Tech News',
    snippet: 'A round-up of the latest technology news around the campus.',
    date: DateTime.now().subtract(const Duration(days: 2)),
    isImportant: false,
    category: EmailCategory.other,
  ),
  Email(
    id: 'e6',
    sender: 'Career Services',
    subject: 'Job Fair This Thursday!',
    snippet:
        'Top companies including Aramco, SABIC, and STC will be recruiting on campus.',
    date: DateTime.now().subtract(const Duration(hours: 8)),
    isImportant: false,
    hasEvent: true,
    category: EmailCategory.other,
  ),
  Email(
    id: 'e7',
    sender: 'Ahmed Taha',
    subject: 'Project Meeting',
    snippet: 'Hey, let\'s meet tomorrow to discuss the final project presentation.',
    date: DateTime.now().subtract(const Duration(minutes: 5)),
    isImportant: true,
    category: EmailCategory.direct,
  ),
  Email(
    id: 'e8',
    sender: 'Blackboard Learn',
    subject: 'New Announcement: ICS324',
    snippet: 'Midterm grades are now published.',
    date: DateTime.now().subtract(const Duration(hours: 4)),
    isImportant: true,
    category: EmailCategory.blackboard,
    courseCode: 'ICS324',
  ),
  Email(
    id: 'e9',
    sender: 'Blackboard Learn',
    subject: 'Quiz Reminder for COE292',
    snippet: 'Don\'t forget tomorrow\'s quiz on Ch 3.',
    date: DateTime.now().subtract(const Duration(hours: 20)),
    isImportant: true,
    category: EmailCategory.blackboard,
    courseCode: 'COE292',
  ),
  Email(
    id: 'e10',
    sender: 'Blackboard Learn',
    subject: 'Assignment Graded: IAS212',
    snippet: 'You have a new grade posted.',
    date: DateTime.now().subtract(const Duration(days: 3)),
    isImportant: true,
    category: EmailCategory.blackboard,
    courseCode: 'IAS212',
  ),
  Email(
    id: 'e11',
    sender: 'Blackboard Learn',
    subject: 'Reading Materials for ISE201',
    snippet: 'I have attached chapter 4 slides.',
    date: DateTime.now().subtract(const Duration(days: 4)),
    isImportant: true,
    category: EmailCategory.blackboard,
    courseCode: 'ISE201',
  ),
];

final List<CalendarEvent> dummyEvents = [
  CalendarEvent(
    id: 'c1',
    title: 'KFUPM Hackathon',
    description: 'Participate in the weekend hackathon. Free food & prizes!',
    date: DateTime.now().add(const Duration(days: 2, hours: 10)),
    sourceEmailId: 'e1',
  ),
  CalendarEvent(
    id: 'c2',
    title: 'Early Registration',
    description: 'Register for classes for the upcoming semester.',
    date: DateTime.now().add(const Duration(days: 4, hours: 8)),
    sourceEmailId: 'e4',
  ),
  CalendarEvent(
    id: 'c3',
    title: 'Career Fair',
    description: 'Meet recruiters from top companies. Bring your resume!',
    date: DateTime.now().add(const Duration(days: 3, hours: 9)),
    sourceEmailId: 'e6',
  ),
  CalendarEvent(
    id: 'c4',
    title: 'SWE316 Final Exam',
    description:
        'Software Engineering final examination - Building 22, Room 105',
    date: DateTime.now().add(const Duration(days: 7, hours: 14)),
    sourceEmailId: 'e2',
  ),
  CalendarEvent(
    id: 'c5',
    title: 'Project Deadline',
    description: 'Submit your group project for CS101 before midnight.',
    date: DateTime.now(),
    sourceEmailId: 'e2',
  ),
  CalendarEvent(
    id: 'c6',
    title: 'SWE316 Quiz',
    description: 'Ch 4, 5, 6 covering design patterns.',
    date: DateTime.now().add(const Duration(hours: 4)),
    sourceEmailId: 'e2',
  ),
];
