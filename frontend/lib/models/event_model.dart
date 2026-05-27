class EventModel {
  final String id;
  final String title;
  final String type;
  final String locationName;
  final String date;
  final String? startTime;
  final String? endTime;
  final String? imageUrl;
  final String status;
  final bool isPriority;
  final int? guestsAttended;
  final int? guestsExpected;
  final int? guestsTotal;
  final int? progressPercentage;

  EventModel({
    required this.id,
    required this.title,
    required this.type,
    required this.locationName,
    required this.date,
    this.startTime,
    this.endTime,
    this.imageUrl,
    required this.status,
    required this.isPriority,
    this.guestsAttended,
    this.guestsExpected,
    this.guestsTotal,
    this.progressPercentage,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      locationName: json['locationName'],
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      imageUrl: json['imageUrl'],
      status: json['status'],
      isPriority: json['isPriority'] ?? false,
      guestsAttended: json['guestsAttended'],
      guestsExpected: json['guestsExpected'],
      guestsTotal: json['guestsTotal'],
      progressPercentage: json['progressPercentage'],
    );
  }
}
