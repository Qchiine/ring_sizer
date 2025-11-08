class Measurement {
  final String measurementId;
  final String userId;
  final String type;
  final double valueMm;
  final int? standardSize;
  final DateTime date;

  Measurement({
    required this.measurementId,
    required this.userId,
    required this.type,
    required this.valueMm,
    this.standardSize,
    required this.date,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      measurementId: json['_id'] ?? json['measurementId'],
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      valueMm: (json['valueMm'] as num?)?.toDouble() ?? 0.0,
      standardSize: (json['standardSize'] as num?)?.toInt(),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }
}
