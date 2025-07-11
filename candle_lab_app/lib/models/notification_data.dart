import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationData {
  String? id; // Firestore document ID
  String candleId; // Reference to the CandleData document
  String candleName; // Name of the candle (sampleName)
  DateTime burningDay; // When the candle is ready
  bool isRead; // Whether the notification has been read
  DateTime createdAt; // When the notification was created

  NotificationData({
    this.id,
    required this.candleId,
    required this.candleName,
    required this.burningDay,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'candleId': candleId,
    'candleName': candleName,
    'burningDay': burningDay.toIso8601String(),
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
  };

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      NotificationData(
        id: json['id'],
        candleId: json['candleId'],
        candleName: json['candleName'],
        burningDay: DateTime.parse(json['burningDay']),
        isRead: json['isRead'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
      );
}
