class ContributionModel {
  final String type;
  final String value;

  ContributionModel({required this.type, required this.value});

  factory ContributionModel.fromJson(Map<String, dynamic> json) {
    return ContributionModel(
      type: json['type'] ?? '',
      value: json['value'] ?? '',
    );
  }
}

class HistoryModel {
  final String historyId;
  final String eventId;
  final String title;
  final String hostName;
  final String date;
  final String locationName;
  final String type;
  final String status;
  final bool isPriority;
  final List<ContributionModel> contributions;

  HistoryModel({
    required this.historyId,
    required this.eventId,
    required this.title,
    required this.hostName,
    required this.date,
    required this.locationName,
    required this.type,
    required this.status,
    required this.isPriority,
    required this.contributions,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      historyId: json['historyId'] ?? '',
      eventId: json['eventId'] ?? '',
      title: json['title'] ?? '',
      hostName: json['hostName'] ?? '',
      date: json['date'] ?? '',
      locationName: json['locationName'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      isPriority: json['isPriority'] ?? false,
      contributions: (json['contributions'] as List? ?? [])
          .map((c) => ContributionModel.fromJson(c))
          .toList(),
    );
  }
}
