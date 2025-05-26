class Event {
  final int? id;
  final String title;
  final String description;
  final String location;
  final String eventDate;
  final int? createdBy;
  final String? createdAt;
  final String? creatorName;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.eventDate,
    this.createdBy,
    this.createdAt,
    this.creatorName,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      eventDate: json['event_date'] ?? '',
      createdBy: json['created_by'] != null ? int.parse(json['created_by'].toString()) : null,
      createdAt: json['created_at'],
      creatorName: json['creator_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'event_date': eventDate,
      'created_by': createdBy,
    };
  }
}