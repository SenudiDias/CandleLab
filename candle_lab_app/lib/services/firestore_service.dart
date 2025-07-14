import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:candle_lab_app/models/candle_data.dart';
import 'package:candle_lab_app/models/notification_data.dart';

class FirestoreService {
  final CollectionReference _candlesCollection = FirebaseFirestore.instance
      .collection('candles');
  final CollectionReference _notificationsCollection = FirebaseFirestore
      .instance
      .collection('notifications');

  // Save or update a CandleData object
  // Future<void> saveCandleData(CandleData candleData) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) {
  //     throw Exception('User not authenticated');
  //   }
  //   try {
  //     candleData.userId = user.uid; // Set userId
  //     final data = candleData.toJson();
  //     data['createdAt'] = DateTime.now().toIso8601String();
  //     if (candleData.id == null) {
  //       final docRef = await _candlesCollection.add(data);
  //       candleData.id = docRef.id;
  //     } else {
  //       await _candlesCollection.doc(candleData.id).set(data);
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to save candle data: $e');
  //   }
  // }

  Future<void> saveCandleData(CandleData candleData) async {
    final user = FirebaseAuth.instance.currentUser;
    print('Current user: ${user?.uid ?? "No user authenticated"}');
    if (user == null) {
      throw Exception('User not authenticated');
    }
    try {
      candleData.userId = user.uid; // Ensure userId is set
      final data = candleData.toJson();
      data['createdAt'] = DateTime.now().toIso8601String();
      if (candleData.id == null) {
        final docRef = await _candlesCollection.add(data);
        candleData.id = docRef.id;
        print('Candle saved with ID: ${candleData.id}');
      } else {
        await _candlesCollection.doc(candleData.id).set(data);
        print('Candle updated with ID: ${candleData.id}');
      }
    } catch (e) {
      print('Error saving candle data: $e');
      throw Exception('Failed to save candle data: $e');
    }
  }

  // Retrieve a CandleData object by ID
  Future<CandleData?> getCandleData(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    try {
      final doc = await _candlesCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['userId'] == user.uid) {
          return CandleData.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to retrieve candle data: $e');
    }
  }

  // Retrieve all CandleData objects for the logged-in user
  Future<List<CandleData>> getAllCandleData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    try {
      final querySnapshot = await _candlesCollection
          .where('userId', isEqualTo: user.uid)
          .get();
      return querySnapshot.docs
          .map((doc) => CandleData.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve all candle data: $e');
    }
  }

  // Save a NotificationData object
  Future<void> saveNotification(NotificationData notification) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    try {
      notification.userId = user.uid; // Set userId
      final data = notification.toJson();
      data['createdAt'] = notification.createdAt.toIso8601String();
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

  // Retrieve all notifications for the logged-in user, sorted by burningDay
  Future<List<NotificationData>> getAllNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    try {
      final querySnapshot = await _notificationsCollection
          .where('userId', isEqualTo: user.uid)
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

  // Get stream of unread notification count for the logged-in user
  Stream<int> getUnreadNotificationCount() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(0);
    }
    return _notificationsCollection
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    try {
      final doc = await _notificationsCollection.doc(notificationId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['userId'] == user.uid) {
          await _notificationsCollection.doc(notificationId).update({
            'isRead': true,
          });
        } else {
          throw Exception('Notification not found or access denied');
        }
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
}
