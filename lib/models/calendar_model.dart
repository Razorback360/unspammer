class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  // Empty string for manually-created events; email id for email-derived events.
  final String sourceEmailId;

  bool get isEmailDerived => sourceEmailId.isNotEmpty;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.sourceEmailId,
  });

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? sourceEmailId,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      sourceEmailId: sourceEmailId ?? this.sourceEmailId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'sourceEmailId': sourceEmailId,
    };
  }

  factory CalendarEvent.fromMap(Map<dynamic, dynamic> map, String id) {
    return CalendarEvent(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      sourceEmailId: map['sourceEmailId'] as String? ?? '',
    );
  }
}
