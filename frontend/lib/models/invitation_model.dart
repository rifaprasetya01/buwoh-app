class InvitationModel {
  final String eventId;
  final String type;
  final String title;
  final String hostName;
  final String date;
  final String time;
  final String locationName;
  final double? distanceKm;
  final String imageUrl;
  final bool isBalasBudi;
  final bool hasSubmitted;

  InvitationModel({
    required this.eventId,
    required this.type,
    required this.title,
    required this.hostName,
    required this.date,
    required this.time,
    required this.locationName,
    required this.distanceKm,
    required this.imageUrl,
    required this.isBalasBudi,
    required this.hasSubmitted,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      eventId: json['eventId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      hostName: json['hostName'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      locationName: json['locationName'] ?? '',
      distanceKm: json['distanceKm']?.toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      isBalasBudi: json['isBalasBudi'] ?? false,
      hasSubmitted: json['hasSubmitted'] ?? false,
    );
  }
}
