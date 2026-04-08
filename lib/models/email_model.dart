enum EmailCategory {
  blackboard,
  registrar,
  direct,
  other
}

class EmailModel {
  final String id;
  final String fromAddress;
  final String body;
  final String subject;
  final String summary;
  final String classification;
  final DateTime timestamp;
  final DateTime? eventDate;
  final bool hasEvent;
  final String? courseCode;
  final EmailCategory category;

  bool get isImportant => classification == 'important';

  const EmailModel({
    required this.id,
    required this.fromAddress,
    required this.body,
    required this.subject,
    required this.summary,
    required this.classification,
    required this.timestamp,
    this.eventDate,
    this.hasEvent = false,
    this.courseCode,
    this.category = EmailCategory.other,
  });

  EmailModel copyWith({
    String? id,
    String? fromAddress,
    String? body,
    String? subject,
    String? summary,
    String? classification,
    DateTime? timestamp,
    DateTime? eventDate,
    bool? hasEvent,
    String? courseCode,
    EmailCategory? category,
  }) {
    return EmailModel(
      id: id ?? this.id,
      fromAddress: fromAddress ?? this.fromAddress,
      body: body ?? this.body,
      subject: subject ?? this.subject,
      summary: summary ?? this.summary,
      classification: classification ?? this.classification,
      timestamp: timestamp ?? this.timestamp,
      eventDate: eventDate ?? this.eventDate,
      hasEvent: hasEvent ?? this.hasEvent,
      courseCode: courseCode ?? this.courseCode,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'fromAddress': fromAddress,
      'body': body,
      'subject': subject,
      'summary': summary,
      'classification': classification,
      'timestamp': timestamp.toIso8601String(),
      'eventDate': eventDate?.toIso8601String(),
      'hasEvent': hasEvent,
      'courseCode': courseCode,
      'category': category.name,
    };
  }

  factory EmailModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return EmailModel(
      id: id,
      fromAddress: map['fromAddress'] as String? ?? '',
      body: map['body'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      classification: map['classification'] as String? ?? 'not_important',
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
      eventDate: map['eventDate'] != null ? DateTime.tryParse(map['eventDate'] as String) : null,
      hasEvent: map['hasEvent'] as bool? ?? false,
      courseCode: map['courseCode'] as String?,
      category: EmailCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => EmailCategory.other,
      ),
    );
  }
}

