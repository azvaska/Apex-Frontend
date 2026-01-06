class ReportAttachment {
  final String id;
  final String url;
  final String? mimeType;
  final int? sizeBytes;
  final DateTime createdAt;

  const ReportAttachment({
    required this.id,
    required this.url,
    required this.createdAt,
    this.mimeType,
    this.sizeBytes,
  });

  factory ReportAttachment.fromJson(Map<String, dynamic> json) {
    return ReportAttachment(
      id: json['id'] as String,
      url: json['url'] as String,
      mimeType: json['mimeType'] as String?,
      sizeBytes: json['sizeBytes'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class ReportUserSummary {
  final String id;
  final String email;
  final String name;
  final String surname;
  final String? profileImage;

  const ReportUserSummary({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    this.profileImage,
  });

  factory ReportUserSummary.fromJson(Map<String, dynamic> json) {
    return ReportUserSummary(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      profileImage: json['profileImage'] as String?,
    );
  }
}

class ReportAreaSummary {
  final String id;
  final String name;

  const ReportAreaSummary({
    required this.id,
    required this.name,
  });

  factory ReportAreaSummary.fromJson(Map<String, dynamic> json) {
    return ReportAreaSummary(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class ReportComment {
  final String id;
  final String text;
  final ReportUserSummary user;
  final DateTime createdAt;

  const ReportComment({
    required this.id,
    required this.text,
    required this.user,
    required this.createdAt,
  });

  factory ReportComment.fromJson(Map<String, dynamic> json) {
    return ReportComment(
      id: json['id'] as String,
      text: json['text'] as String,
      user: ReportUserSummary.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class Report {
  final String id;
  final String title;
  final String text;
  final bool active;
  final ReportUserSummary user;
  final ReportAreaSummary area;
  final List<ReportAttachment> attachments;
  final List<ReportComment> comments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Report({
    required this.id,
    required this.title,
    required this.text,
    required this.active,
    required this.user,
    required this.area,
    required this.attachments,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
  });

  String? get coverUrl => attachments.isNotEmpty ? attachments.first.url : null;

  factory Report.fromJson(Map<String, dynamic> json) {
    final attachments = (json['attachments'] as List<dynamic>? ?? [])
        .map((item) => ReportAttachment.fromJson(item as Map<String, dynamic>))
        .toList();
    final comments = (json['comments'] as List<dynamic>? ?? [])
        .map((item) => ReportComment.fromJson(item as Map<String, dynamic>))
        .toList();
    return Report(
      id: json['id'] as String,
      title: json['title'] as String,
      text: json['text'] as String,
      active: json['active'] as bool? ?? true,
      user: ReportUserSummary.fromJson(json['user'] as Map<String, dynamic>),
      area: ReportAreaSummary.fromJson(json['area'] as Map<String, dynamic>),
      attachments: attachments,
      comments: comments,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class AreaOfInterest {
  final String id;
  final String name;

  const AreaOfInterest({
    required this.id,
    required this.name,
  });

  factory AreaOfInterest.fromJson(Map<String, dynamic> json) {
    return AreaOfInterest(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
