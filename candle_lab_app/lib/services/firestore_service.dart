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
  Future<void> saveCandleData(CandleData candleData) async {
    final user = FirebaseAuth.instance.currentUser;
    print('Current user: ${user?.uid ?? "No user authenticated"}');
    if (user == null) {
      throw Exception('User not authenticated');
    }
    try {
      candleData.userId = user.uid;
      final data = candleData.toJson();
      data['createdAt'] = DateTime.now().toIso8601String();
      data['version'] =
          FieldValue.serverTimestamp(); // Add version for conflict detection
      if (candleData.id == null) {
        final docRef = await _candlesCollection.add(data);
        candleData.id = docRef.id;
        data['id'] = docRef.id;
        await _candlesCollection.doc(docRef.id).set(data);
        print('Candle saved with ID: ${candleData.id}');
      } else {
        final docSnapshot = await _candlesCollection.doc(candleData.id).get();
        if (docSnapshot.exists) {
          final existingData = docSnapshot.data() as Map<String, dynamic>;
          if (existingData['version'] != data['version']) {
            // Skip if version matches
            data['id'] = candleData.id;
            await _candlesCollection.doc(candleData.id).set(data);
            print('Candle updated with ID: ${candleData.id}');
          }
        }
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

  // Retrieve all CandleData objects for the logged-in user as a Stream
  Stream<QuerySnapshot> getCandlesByUser(String userId) {
    return _candlesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
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
      print('Error saving notification: $e');
      throw Exception('Failed to save notification: $e');
    }
  }

  // Retrieve all notifications for the logged-in user as a Stream
  Stream<List<NotificationData>> getAllNotificationsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return _notificationsCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('burningDay', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => NotificationData.fromJson(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
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
            'manuallyReadAt': DateTime.now().toIso8601String(),
          });
          print('Notification $notificationId marked as read');
        } else {
          throw Exception('Notification not found or access denied');
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Stream<List<CandleData>> getFilteredCandles({
    required String userId,
    String? candleType,
    double? meltPercentage,
    double? meltTime,
    double? meltDepth,
    double? scentDistance,
    String? scentThrow,
    String? sizeCategory,
  }) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }
    Query query = _candlesCollection.where('userId', isEqualTo: userId);

    if (candleType != null) {
      query = query.where('candleType', isEqualTo: candleType);
    }

    return query.orderBy('totalCost', descending: false).snapshots().map((
      snapshot,
    ) {
      final candles = snapshot.docs
          .map((doc) => CandleData.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return candles.where((candle) {
        bool matches = true;

        // Apply flame-related filters only if flameRecord exists
        if ((meltPercentage != null ||
                meltTime != null ||
                meltDepth != null ||
                scentDistance != null ||
                scentThrow != null) &&
            candle.flameRecord == null) {
          return false;
        }

        // Melt Filter
        if (meltPercentage != null &&
            meltTime != null &&
            candle.flameRecord != null) {
          final meltMeasure = candle.flameRecord!.meltMeasures.firstWhere(
            (m) => m.time == meltTime,
            orElse: () => MeltMeasure(time: meltTime!),
          );
          matches = matches && (meltMeasure.fullMelt * 100) >= meltPercentage;
        }

        // Melt Depth Filter
        if (meltDepth != null &&
            meltTime != null &&
            candle.flameRecord != null) {
          final meltMeasure = candle.flameRecord!.meltMeasures.firstWhere(
            (m) => m.time == meltTime,
            orElse: () => MeltMeasure(time: meltTime!),
          );
          if (meltDepth == 0.0) {
            matches = matches && meltMeasure.meltDepth == 0.0;
          } else {
            matches =
                matches &&
                meltMeasure.meltDepth > 0.0 &&
                meltMeasure.meltDepth >= meltDepth - 2 &&
                meltMeasure.meltDepth <= meltDepth + 2;
          }
        }

        // Scent Throw Filter
        if (scentDistance != null &&
            scentThrow != null &&
            candle.flameRecord != null &&
            candle.flameRecord!.scentThrow != null) {
          final hotThrow =
              candle.flameRecord!.scentThrow!.hotThrow[scentDistance] ?? '';
          matches = matches && hotThrow == scentThrow;
        } else if (scentDistance != null && scentThrow != null) {
          matches =
              false; // Exclude candles if scent filter is active but scentThrow is null
        }

        // Size Filter
        if (sizeCategory != null) {
          final totalWaxWeight = candle.waxDetails.fold<double>(
            0.0,
            (sum, detail) => sum + detail.weight,
          );
          final range = sizeCategory
              .split('-')
              .map((s) => double.parse(s.replaceAll('g', '')))
              .toList();
          matches =
              matches &&
              totalWaxWeight >= range[0] &&
              (range.length > 1 ? totalWaxWeight <= range[1] : true);
        }

        return matches;
      }).toList();
    });
  }

  // Update the markNotificationAsUnread method in firestore_service.dart
  Future<void> markNotificationAsUnread(String notificationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    try {
      final doc = await _notificationsCollection.doc(notificationId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // Only mark as unread if it was never manually read
        if (data['userId'] == user.uid && data['manuallyReadAt'] == null) {
          await _notificationsCollection.doc(notificationId).update({
            'isRead': false,
          });
          print('Notification $notificationId marked as unread');
        }
      }
    } catch (e) {
      print('Error marking notification as unread: $e');
      throw Exception('Failed to mark notification as unread: $e');
    }
  }

  // Add this new method to firestore_service.dart
  Future<List<NotificationData>> getAllNotificationsOnce() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    final snapshot = await _notificationsCollection
        .where('userId', isEqualTo: user.uid)
        .get();
    return snapshot.docs
        .map(
          (doc) =>
              NotificationData.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }
}
