import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:candle_lab_app/models/candle_data.dart';
import 'package:candle_lab_app/models/notification_data.dart';

class FirestoreService {
  final CollectionReference _candlesCollection = FirebaseFirestore.instance
      .collection('candles');
  final CollectionReference _notificationsCollection = FirebaseFirestore
      .instance
      .collection('notifications');

  // Save or update a CandleData object
  Future<void> saveCandleData(CandleData candleData) async {
    try {
      final data = candleData.toJson();
      data['createdAt'] = DateTime.now().toIso8601String();
      if (candleData.id == null) {
        final docRef = await _candlesCollection.add(data);
        candleData.id = docRef.id;
      } else {
        await _candlesCollection.doc(candleData.id).set(data);
      }
    } catch (e) {
      throw Exception('Failed to save candle data: $e');
    }
  }

  // Retrieve a CandleData object by ID
  Future<CandleData?> getCandleData(String id) async {
    try {
      final doc = await _candlesCollection.doc(id).get();
      if (doc.exists) {
        return CandleData.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to retrieve candle data: $e');
    }
  }

  // Retrieve all CandleData objects
  Future<List<CandleData>> getAllCandleData() async {
    try {
      final querySnapshot = await _candlesCollection.get();
      return querySnapshot.docs
          .map((doc) => CandleData.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve all candle data: $e');
    }
  }

  // Save a NotificationData object
  Future<void> saveNotification(NotificationData notification) async {
    try {
      final data = notification.toJson();
      data['createdAt'] = DateTime.now().toIso8601String();
      if (notification.id == null) {
        final docRef = await _notificationsCollection.add(data);
        notification.id = docRef.id;
      } else {
        await _notificationsCollection.doc(notification.id).set(data);
      }
    } catch (e) {
      throw Exception('Failed to save notification: $e');
    }
  }

  // Retrieve all notifications, sorted by burningDay
  Future<List<NotificationData>> getAllNotifications() async {
    try {
      final querySnapshot = await _notificationsCollection
          .orderBy('burningDay', descending: false)
          .get();
      return querySnapshot.docs
          .map(
            (doc) =>
                NotificationData.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve notifications: $e');
    }
  }

  // Get stream of unread notification count
  Stream<int> getUnreadNotificationCount() {
    return _notificationsCollection
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
}
