
class NotificationData {
  String? id; // Firestore document ID
  String? userId; // Added userId field
  String candleId; // Reference to the CandleData document
  String candleName; // Name of the candle (sampleName)
  String candleType; // Type of the candle (e.g., Container, Pillar, Mould)
  DateTime burningDay; // When the candle is ready
  bool isRead; // Whether the notification has been read
  DateTime createdAt; // When the notification was created
  DateTime? manuallyReadAt;

  NotificationData({
    this.id,
    this.userId,
    required this.candleId,
    required this.candleName,
    required this.candleType, // Required parameter
    required this.burningDay,
    this.isRead = false,
    required this.createdAt,
    this.manuallyReadAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'candleId': candleId,
    'candleName': candleName,
    'candleType': candleType, // Added to JSON
    'burningDay': burningDay.toIso8601String(),
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
    'manuallyReadAt': manuallyReadAt?.toIso8601String(),
  };

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      NotificationData(
        id: json['id'],
        userId: json['userId'],
        candleId: json['candleId'],
        candleName: json['candleName'],
        candleType:
            json['candleType'] ?? 'Unknown', // Default to 'Unknown' if missing
        burningDay: DateTime.parse(json['burningDay']),
        isRead: json['isRead'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        manuallyReadAt: json['manuallyReadAt'] != null
            ? DateTime.parse(json['manuallyReadAt'])
            : null,
      );
}
