class EmailModel {
  final String id;
  final String fromAddress;
  final String body;
  final String subject;
  final String summary;
  final String classification;
  final DateTime timestamp;

  const EmailModel({
    required this.id,
    required this.fromAddress,
    required this.body,
    required this.subject,
    required this.summary,
    required this.classification,
    required this.timestamp,
  });

  EmailModel copyWith({
    String? id,
    String? fromAddress,
    String? body,
    String? subject,
    String? summary,
    String? classification,
    DateTime? timestamp,
  }) {
    return EmailModel(
      id: id ?? this.id,
      fromAddress: fromAddress ?? this.fromAddress,
      body: body ?? this.body,
      subject: subject ?? this.subject,
      summary: summary ?? this.summary,
      classification: classification ?? this.classification,
      timestamp: timestamp ?? this.timestamp,
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
    );
  }
}

