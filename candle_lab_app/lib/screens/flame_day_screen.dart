import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:candle_lab_app/models/candle_data.dart';
import 'package:candle_lab_app/services/firestore_service.dart';
import '../services/notification_service.dart';
import 'custom_drawer.dart';
import 'making_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/image_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FlameDayScreen extends StatefulWidget {
  const FlameDayScreen({super.key});

  @override
  State<FlameDayScreen> createState() => _FlameDayScreenState();
}

class _FlameDayScreenState extends State<FlameDayScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isContentVisible = false;

  Stream<DateTime> _dateTimeStream() async* {
    while (true) {
      yield DateTime.now();
      await Future.delayed(const Duration(minutes: 1));
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isContentVisible = true;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Flame Day',
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: StreamBuilder<int>(
              stream: NotificationService.unreadCountStream,
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;
                return Stack(
                  children: [
                    const Icon(Icons.menu, color: Colors.white),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          StreamBuilder<DateTime>(
            stream: _dateTimeStream(),
            builder: (context, snapshot) {
              final now = snapshot.data ?? DateTime.now();
              final dateFormatter = DateFormat('MMM d, yyyy');
              final timeFormatter = DateFormat('h:mm a');
              final formattedDate = dateFormatter.format(now);
              final formattedTime = timeFormatter.format(now);
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedDate,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(currentRoute: '/flame_day'),
      body: userId == null
          ? Center(
              child: Text(
                'Please log in to view your samples.',
                style: textTheme.bodyLarge,
              ),
            )
          : AnimatedOpacity(
              opacity: _isContentVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by sample name',
                        prefixIcon: Icon(
                          Icons.search,
                          color: colorScheme.onSurface,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                      ),
                      style: textTheme.bodyLarge,
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestoreService.getCandlesByUser(userId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          print('StreamBuilder error: ${snapshot.error}');
                          return Center(
                            child: Text(
                              'Error loading samples.',
                              style: textTheme.bodyLarge,
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              'No samples found.',
                              style: textTheme.bodyLarge,
                            ),
                          );
                        }

                        final candles =
                            snapshot.data!.docs
                                .asMap()
                                .entries
                                .map((entry) {
                                  final index = entry.key;
                                  final doc = entry.value;
                                  try {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    data['id'] = doc.id;
                                    return CandleData.fromJson(data);
                                  } catch (e) {
                                    print(
                                      'Error parsing candle at index $index: $e',
                                    );
                                    return null;
                                  }
                                })
                                .where((candle) => candle != null)
                                .cast<CandleData>()
                                .where(
                                  (candle) =>
                                      _searchQuery.isEmpty ||
                                      candle.sampleName?.toLowerCase().contains(
                                            _searchQuery.toLowerCase(),
                                          ) ==
                                          true,
                                )
                                .where((candle) {
                                  if (candle.coolingCuringDetail?.burningDay ==
                                          null ||
                                      candle
                                              .coolingCuringDetail
                                              ?.reminderTime ==
                                          null) {
                                    return false;
                                  }
                                  final burnDateTime = DateTime(
                                    candle
                                        .coolingCuringDetail!
                                        .burningDay!
                                        .year,
                                    candle
                                        .coolingCuringDetail!
                                        .burningDay!
                                        .month,
                                    candle.coolingCuringDetail!.burningDay!.day,
                                    candle
                                        .coolingCuringDetail!
                                        .reminderTime!
                                        .hour,
                                    candle
                                        .coolingCuringDetail!
                                        .reminderTime!
                                        .minute,
                                  );
                                  return burnDateTime.isBefore(DateTime.now());
                                })
                                .toList()
                              ..sort((a, b) {
                                if (a.flameDate != null &&
                                    a.flameTime != null &&
                                    b.flameDate != null &&
                                    b.flameTime != null) {
                                  final aFlameDateTime = DateTime(
                                    a.flameDate!.year,
                                    a.flameDate!.month,
                                    a.flameDate!.day,
                                    a.flameTime!.hour,
                                    a.flameTime!.minute,
                                  );
                                  final bFlameDateTime = DateTime(
                                    b.flameDate!.year,
                                    b.flameDate!.month,
                                    b.flameDate!.day,
                                    b.flameTime!.hour,
                                    b.flameTime!.minute,
                                  );
                                  return aFlameDateTime.compareTo(
                                    bFlameDateTime,
                                  );
                                } else if (a.flameDate != null &&
                                    a.flameTime != null) {
                                  return -1;
                                } else if (b.flameDate != null &&
                                    b.flameTime != null) {
                                  return 1;
                                } else {
                                  final aBurnDateTime = DateTime(
                                    a.coolingCuringDetail!.burningDay!.year,
                                    a.coolingCuringDetail!.burningDay!.month,
                                    a.coolingCuringDetail!.burningDay!.day,
                                    a.coolingCuringDetail!.reminderTime!.hour,
                                    a.coolingCuringDetail!.reminderTime!.minute,
                                  );
                                  final bBurnDateTime = DateTime(
                                    b.coolingCuringDetail!.burningDay!.year,
                                    b.coolingCuringDetail!.burningDay!.month,
                                    b.coolingCuringDetail!.burningDay!.day,
                                    b.coolingCuringDetail!.reminderTime!.hour,
                                    b.coolingCuringDetail!.reminderTime!.minute,
                                  );
                                  return aBurnDateTime.compareTo(bBurnDateTime);
                                }
                              });

                        final unflamedCandles = candles
                            .where((candle) => !candle.isFlamed)
                            .toList();
                        final flamedCandles = candles
                            .where((candle) => candle.isFlamed)
                            .toList();

                        return ListView(
                          padding: const EdgeInsets.all(16.0),
                          children: [
                            if (unflamedCandles.isNotEmpty) ...[
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: unflamedCandles.length,
                                itemBuilder: (context, index) {
                                  final candle = unflamedCandles[index];
                                  final batchDate = candle.createdAt != null
                                      ? DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(candle.createdAt!)
                                      : 'N/A';
                                  final batchTime = candle.createdAt != null
                                      ? DateFormat(
                                          'hh:mm a',
                                        ).format(candle.createdAt!)
                                      : 'N/A';
                                  final flameDate = candle.flameDate != null
                                      ? DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(candle.flameDate!)
                                      : 'Not set';
                                  final flameTime = candle.flameTime != null
                                      ? candle.flameTime!.format(context)
                                      : 'Not set';
                                  final burnDate =
                                      candle.coolingCuringDetail?.burningDay !=
                                          null
                                      ? DateFormat('MMM dd, yyyy').format(
                                          candle
                                              .coolingCuringDetail!
                                              .burningDay!,
                                        )
                                      : 'Not set';
                                  final burnTime =
                                      candle
                                              .coolingCuringDetail
                                              ?.reminderTime !=
                                          null
                                      ? candle
                                            .coolingCuringDetail!
                                            .reminderTime!
                                            .format(context)
                                      : 'Not set';

                                  return Card(
                                    color: colorScheme.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    elevation: 4.0,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            candle.sampleName ??
                                                'Unnamed Sample',
                                            style: textTheme.titleLarge
                                                ?.copyWith(
                                                  color: colorScheme.secondary,
                                                ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            'Batch Date: $batchDate',
                                            style: textTheme.bodyMedium,
                                          ),
                                          Text(
                                            'Batch Time: $batchTime',
                                            style: textTheme.bodyMedium,
                                          ),
                                          Text(
                                            'Burn Date: $burnDate',
                                            style: textTheme.bodyMedium,
                                          ),
                                          Text(
                                            'Burn Time: $burnTime',
                                            style: textTheme.bodyMedium,
                                          ),
                                          Text(
                                            'Flame Date: $flameDate',
                                            style: textTheme.bodyMedium,
                                          ),
                                          Text(
                                            'Flame Time: $flameTime',
                                            style: textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 12.0),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: colorScheme.primary,
                                                  size: 20.0,
                                                ),
                                                tooltip: 'Edit Sample',
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MakingScreen(
                                                            initialCandleData:
                                                                candle,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.local_fire_department,
                                                  color: colorScheme.primary,
                                                  size: 20.0,
                                                ),
                                                tooltip:
                                                    'Set Flame Date & Time',
                                                onPressed: () =>
                                                    _showFlameDateTimePicker(
                                                      context,
                                                      candle,
                                                    ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.videocam,
                                                  color:
                                                      candle.flameDate !=
                                                              null &&
                                                          candle.flameTime !=
                                                              null
                                                      ? colorScheme.primary
                                                      : colorScheme.onSurface
                                                            .withOpacity(0.4),
                                                  size: 20.0,
                                                ),
                                                tooltip: 'Record Flame Data',
                                                onPressed:
                                                    candle.flameDate != null &&
                                                        candle.flameTime != null
                                                    ? () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                FlameRecordScreen(
                                                                  candle:
                                                                      candle,
                                                                ),
                                                          ),
                                                        );
                                                      }
                                                    : () {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              'Please set the flame date/time',
                                                            ),
                                                          ),
                                                        );
                                                      },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                            if (flamedCandles.isNotEmpty) ...[
                              const Divider(
                                color: Colors.grey,
                                thickness: 1.0,
                                indent: 16.0,
                                endIndent: 16.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  'Flamed Candles',
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: flamedCandles.length,
                                itemBuilder: (context, index) {
                                  final candle = flamedCandles[index];
                                  final batchDate = candle.createdAt != null
                                      ? DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(candle.createdAt!)
                                      : 'N/A';
                                  final batchTime = candle.createdAt != null
                                      ? DateFormat(
                                          'hh:mm a',
                                        ).format(candle.createdAt!)
                                      : 'N/A';
                                  final flameDate = candle.flameDate != null
                                      ? DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(candle.flameDate!)
                                      : 'Not set';
                                  final flameTime = candle.flameTime != null
                                      ? candle.flameTime!.format(context)
                                      : 'Not set';
                                  final burnDate =
                                      candle.coolingCuringDetail?.burningDay !=
                                          null
                                      ? DateFormat('MMM dd, yyyy').format(
                                          candle
                                              .coolingCuringDetail!
                                              .burningDay!,
                                        )
                                      : 'Not set';
                                  final burnTime =
                                      candle
                                              .coolingCuringDetail
                                              ?.reminderTime !=
                                          null
                                      ? candle
                                            .coolingCuringDetail!
                                            .reminderTime!
                                            .format(context)
                                      : 'Not set';

                                  return Card(
                                    color: colorScheme.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    elevation: 4.0,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                candle.sampleName ??
                                                    'Unnamed Sample',
                                                style: textTheme.titleLarge
                                                    ?.copyWith(
                                                      color:
                                                          colorScheme.secondary,
                                                    ),
                                              ),
                                              const SizedBox(width: 8.0),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 4.0,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.primary
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.0,
                                                      ),
                                                ),
                                                child: Text(
                                                  'Flamed',
                                                  style: textTheme.bodySmall
                                                      ?.copyWith(
                                                        color:
                                                            colorScheme.primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            'Batch Date: $batchDate',
                                            style: textTheme.bodyMedium,
                                          ),
                                          Text(
                                            'Batch Time: $batchTime',
                                            style: textTheme.bodyMedium,
                                          ),
                                          Text(
                                            'Burn Date: $burnDate',
                                            style: textTheme.bodyMedium,
                                          ),
                                          Text(
                                            'Burn Time: $burnTime',
                                            style: textTheme.bodyMedium,
                                          ),
                                          Text(
                                            'Flame Date: $flameDate',
                                            style: textTheme.bodyMedium,
                                          ),
                                          Text(
                                            'Flame Time: $flameTime',
                                            style: textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 12.0),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: colorScheme.primary,
                                                  size: 20.0,
                                                ),
                                                tooltip: 'Edit Sample',
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MakingScreen(
                                                            initialCandleData:
                                                                candle,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.local_fire_department,
                                                  color: colorScheme.primary,
                                                  size: 20.0,
                                                ),
                                                tooltip:
                                                    'Set Flame Date & Time',
                                                onPressed: () =>
                                                    _showFlameDateTimePicker(
                                                      context,
                                                      candle,
                                                    ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.videocam,
                                                  color:
                                                      candle.flameDate !=
                                                              null &&
                                                          candle.flameTime !=
                                                              null
                                                      ? colorScheme.primary
                                                      : colorScheme.onSurface
                                                            .withOpacity(0.4),
                                                  size: 20.0,
                                                ),
                                                tooltip: 'Record Flame Data',
                                                onPressed:
                                                    candle.flameDate != null &&
                                                        candle.flameTime != null
                                                    ? () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                FlameRecordScreen(
                                                                  candle:
                                                                      candle,
                                                                ),
                                                          ),
                                                        );
                                                      }
                                                    : () {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              'Please set the flame date/time',
                                                            ),
                                                          ),
                                                        );
                                                      },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                            if (unflamedCandles.isEmpty &&
                                flamedCandles.isEmpty)
                              Center(
                                child: Text(
                                  'No matching samples found.',
                                  style: textTheme.bodyLarge,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showFlameDateTimePicker(BuildContext context, CandleData candle) async {
    final DateTime initialDate = candle.flameDate ?? DateTime.now();
    final TimeOfDay initialTime = candle.flameTime ?? TimeOfDay.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (pickedTime != null && mounted) {
        setState(() {
          candle.flameDate = pickedDate;
          candle.flameTime = pickedTime;
        });

        try {
          await _firestoreService.saveCandleData(candle);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Flame date and time updated')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating flame date: $e')),
            );
          }
        }
      }
    }
  }
}

class FlameRecordScreen extends StatefulWidget {
  final CandleData candle;

  const FlameRecordScreen({super.key, required this.candle});

  @override
  State<FlameRecordScreen> createState() => _FlameRecordScreenState();
}

class _FlameSaveProgressDialog extends StatefulWidget {
  final int totalSteps;
  final Future<bool> Function(void Function(int)) onSave;

  const _FlameSaveProgressDialog({
    required this.totalSteps,
    required this.onSave,
  });

  @override
  State<_FlameSaveProgressDialog> createState() =>
      _FlameSaveProgressDialogState();
}

class _FlameSaveProgressDialogState extends State<_FlameSaveProgressDialog> {
  int _completedSteps = 0;

  @override
  void initState() {
    super.initState();
    _startSaveOperation();
  }

  Future<void> _startSaveOperation() async {
    final success = await widget.onSave(_updateProgress);
    if (mounted) {
      Navigator.of(context).pop(success);
    }
  }

  void _updateProgress(int steps) {
    if (mounted) {
      setState(() {
        _completedSteps = steps;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Saving Flame Data...'),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_completedSteps / widget.totalSteps).clamp(0.0, 1.0),
          ),
          const SizedBox(height: 8),
          Text(
            '${((_completedSteps / widget.totalSteps) * 100).toStringAsFixed(0)}%',
          ),
        ],
      ),
    );
  }
}

class _FlameRecordScreenState extends State<FlameRecordScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late FlameRecord flameRecord;
  late TextEditingController _recordsController;
  final ImagePicker _picker = ImagePicker();
  final List<double> _flameSizeTimes = [0, 0.5, 1];
  bool _isContentVisible = false;
  final List<double> _meltMeasureTimes = [0.5, 1.0, 1.5];
  final Map<double, TextEditingController> _diameterControllers = {};
  final Map<double, TextEditingController> _depthControllers = {};
  bool _isSaving = false;
  final List<File> _tempImageFiles = [];

  @override
  void initState() {
    super.initState();
    flameRecord = widget.candle.flameRecord ?? FlameRecord();
    _recordsController = TextEditingController(text: flameRecord.records);
    flameRecord.flameSizes.forEach((time, _) {
      if (!_flameSizeTimes.contains(time)) {
        _flameSizeTimes.add(time);
      }
    });
    for (var measure in flameRecord.meltMeasures) {
      if (!_meltMeasureTimes.contains(measure.time)) {
        _meltMeasureTimes.add(measure.time);
      }
      // Initialize controllers for existing melt measures
      String formatDouble(double value) {
        if (value == 0.0) return '';
        final intValue = value.toInt();
        return value == intValue.toDouble()
            ? intValue.toString()
            : value.toString();
      }

      _diameterControllers[measure.time] = TextEditingController(
        text: formatDouble(measure.meltDiameter),
      );
      _depthControllers[measure.time] = TextEditingController(
        text: formatDouble(measure.meltDepth),
      );
    }
    _flameSizeTimes.sort();
    _meltMeasureTimes.sort();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isContentVisible = true;
      });
    });
  }

  @override
  void dispose() {
    _recordsController.dispose();
    _diameterControllers.forEach((_, controller) => controller.dispose());
    _depthControllers.forEach((_, controller) => controller.dispose());
    _diameterControllers.clear();
    _depthControllers.clear();
    super.dispose();
  }

  Future<void> _showEnlargedPhoto({
    String? url,
    File? file,
    double time = 0,
  }) async {
    if (url == null && file == null) return;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              InteractiveViewer(
                child: url != null && url.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.contain,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                    : Image.file(file!, fit: BoxFit.contain),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                  onPressed: () async {
                    setState(() => _isSaving = true);
                    try {
                      if (time == 0) {
                        // General photos
                        if (url != null) {
                          await ImageService.deleteImage(url);
                          flameRecord.photoUrls.remove(url);
                        } else if (file != null) {
                          _tempImageFiles.remove(file);
                        }
                      } else {
                        // Melt measure photos
                        final index = flameRecord.meltMeasures.indexWhere(
                          (m) => m.time == time,
                        );
                        if (index != -1) {
                          final measure = flameRecord.meltMeasures[index];
                          if (url != null) {
                            await ImageService.deleteImage(url);
                            measure.photoUrls.remove(url);
                          } else if (file != null) {
                            measure.tempPhotos.remove(file);
                          }
                        }
                      }
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete photo: $e')),
                      );
                    } finally {
                      setState(() => _isSaving = false);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveFlameRecord() async {
    try {
      widget.candle.flameRecord = flameRecord;
      await _firestoreService.saveCandleData(widget.candle);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving flame record: $e')),
        );
      }
    }
  }

  Future<void> _addPhoto({bool fromCamera = false}) async {
    final image = await ImageService.pickImage(fromCamera: fromCamera);
    if (image != null && mounted) {
      setState(() {
        _tempImageFiles.add(image); // Store File object, not path
      });
      _saveFlameRecord();
    }
  }

  void _addFlameSizeTime() {
    setState(() {
      final lastTime = _flameSizeTimes.isNotEmpty ? _flameSizeTimes.last : 1;
      _flameSizeTimes.add(lastTime + 0.5);
      flameRecord.flameSizes[lastTime + 0.5] = '';
    });
    _saveFlameRecord();
  }

  void _deleteFlameSizeTime(double time) {
    if (_flameSizeTimes.length > 3) {
      setState(() {
        _flameSizeTimes.remove(time);
        flameRecord.flameSizes.remove(time);
      });
      _saveFlameRecord();
    }
  }

  void _addMeltMeasureTime() {
    setState(() {
      final lastTime = _meltMeasureTimes.isNotEmpty
          ? _meltMeasureTimes.last
          : 1.5;
      final newTime = lastTime + 0.5;
      _meltMeasureTimes.add(newTime);
      flameRecord.meltMeasures.add(MeltMeasure(time: newTime, photoUrls: []));
      _diameterControllers[newTime] = TextEditingController();
      _depthControllers[newTime] = TextEditingController();
    });
    _saveFlameRecord();
  }

  void _deleteMeltMeasureTime(double time) {
    if (_meltMeasureTimes.length > 3) {
      setState(() {
        _meltMeasureTimes.remove(time);
        flameRecord.meltMeasures.removeWhere((measure) => measure.time == time);
        _diameterControllers[time]?.dispose();
        _depthControllers[time]?.dispose();
        _diameterControllers.remove(time);
        _depthControllers.remove(time);
      });
      _saveFlameRecord();
    }
  }

  Future<void> _addMeltMeasurePhoto(
    double time, {
    bool fromCamera = false,
  }) async {
    final image = await ImageService.pickImage(fromCamera: fromCamera);
    if (image != null) {
      setState(() {
        final index = flameRecord.meltMeasures.indexWhere(
          (m) => m.time == time,
        );
        MeltMeasure measure;
        if (index == -1) {
          measure = MeltMeasure(time: time);
          flameRecord.meltMeasures.add(measure);
        } else {
          measure = flameRecord.meltMeasures[index];
        }
        measure.tempPhotos.add(image);
      });
      _saveFlameRecord(); // Optional: Save partial data
    }
  }

  Future<bool> _performSaveOperation(void Function(int) updateProgress) async {
    int completedSteps = 0;
    try {
      // Count total steps
      int totalImageUploads = 0;

      // General photos
      if (_tempImageFiles.isNotEmpty) {
        totalImageUploads++;
      }

      // Melt measure photos
      for (var measure in widget.candle.flameRecord!.meltMeasures) {
        if (measure.tempPhotos.isNotEmpty) {
          totalImageUploads++;
        }
      }

      // Upload general photos
      if (_tempImageFiles.isNotEmpty) {
        final urls = await ImageService.uploadImages(
          _tempImageFiles, // This should be List<File>
          'candles/${widget.candle.userId}/${widget.candle.id}/images/flame/general',
          onProgress: (index, total) {
            updateProgress(++completedSteps);
          },
        );
        flameRecord.photoUrls.addAll(urls);
        _tempImageFiles.clear();
        updateProgress(++completedSteps);
      }

      // Upload melt measure photos
      for (var measure in widget.candle.flameRecord!.meltMeasures) {
        if (measure.tempPhotos.isNotEmpty) {
          final urls = await ImageService.uploadImages(
            measure.tempPhotos,
            'candles/${widget.candle.userId}/${widget.candle.id}/images/flame/${measure.time}',
            onProgress: (index, total) {
              updateProgress(++completedSteps);
            },
          );
          measure.photoUrls.addAll(urls);
          measure.tempPhotos.clear();
          updateProgress(++completedSteps);
        }
      }

      // Final save
      widget.candle.isFlamed = true;
      await FirestoreService().saveCandleData(widget.candle);
      updateProgress(++completedSteps);

      return true;
    } catch (e) {
      print('Save process failed: $e');
      return false;
    }
  }

  Future<void> _markAsFlamed() async {
    setState(() => _isSaving = true);
    // Calculate total steps
    int totalSteps = 1; // Final save
    for (var measure in widget.candle.flameRecord!.meltMeasures) {
      if (measure.tempPhotos.isNotEmpty) {
        totalSteps++; // Each melt measure with photos
      }
    }

    // Show progress dialog
    final saveSuccess = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _FlameSaveProgressDialog(
          totalSteps: totalSteps,
          onSave: (updateProgress) => _performSaveOperation(updateProgress),
        );
      },
    );

    if (mounted) {
      setState(() => _isSaving = false);

      if (saveSuccess == true) {
        // Navigate back to FlameDayScreen
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Candle successfully marked as flamed!'),
          ),
        );
      } else if (saveSuccess == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save flame data')),
        );
      }
    }
  }

  Future<void> _clearFlameRecord() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Flame Record'),
        content: const Text(
          'Are you sure you want to clear all flame record data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        flameRecord = FlameRecord();
        widget.candle.flameRecord = null;
        _recordsController.text = '';
        _diameterControllers.forEach((time, controller) => controller.clear());
        _depthControllers.forEach((time, controller) => controller.clear());
      });
      try {
        await _firestoreService.saveCandleData(widget.candle);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Flame record cleared')));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error clearing flame record: $e')),
          );
        }
      }
    }
  }

  Future<void> _showBurningTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: flameRecord.fullBurningTime != null
          ? TimeOfDay(
              hour: flameRecord.fullBurningTime!.inMinutes ~/ 60,
              minute: flameRecord.fullBurningTime!.inMinutes % 60,
            )
          : const TimeOfDay(hour: 0, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        flameRecord.fullBurningTime = Duration(
          hours: picked.hour,
          minutes: picked.minute,
        );
      });
      await _saveFlameRecord();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isContainerOrPillar =
        widget.candle.candleType == 'Container' ||
        widget.candle.candleType == 'Pillar';
    final referenceDiameter = widget.candle.candleType == 'Container'
        ? (widget.candle.containerDetail?.containerDiameter ?? 1.0)
        : (widget.candle.pillarDetail?.largestWidth ?? 1.0);
    final isScented = widget.candle.isScented == true;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Record Flame Data - ${widget.candle.sampleName ?? 'Unnamed'}',
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
        ),
      ),
      body: AnimatedOpacity(
        opacity: _isContentVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Flame Size',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        ..._flameSizeTimes.map((time) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '$time hours',
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Wrap(
                                    spacing: 8.0,
                                    children:
                                        [
                                          {
                                            'icon': Icons.local_fire_department,
                                            'size': 28.0,
                                            'value': 'Too Big',
                                          },
                                          {
                                            'icon': Icons.local_fire_department,
                                            'size': 20.0,
                                            'value': 'Perfect',
                                          },
                                          {
                                            'icon': Icons.local_fire_department,
                                            'size': 16.0,
                                            'value': 'Too Small',
                                          },
                                        ].map((option) {
                                          return ChoiceChip(
                                            avatar: Icon(
                                              option['icon'] as IconData,
                                              size: option['size'] as double,
                                              color:
                                                  flameRecord
                                                          .flameSizes[time] ==
                                                      option['value']
                                                  ? colorScheme.onPrimary
                                                  : colorScheme.onSurface
                                                        .withOpacity(0.4),
                                            ),
                                            label: const SizedBox.shrink(),
                                            selected:
                                                flameRecord.flameSizes[time] ==
                                                option['value'],
                                            selectedColor: colorScheme.primary,
                                            backgroundColor:
                                                colorScheme.surface,
                                            showCheckmark: false,
                                            onSelected: (_) {
                                              setState(() {
                                                flameRecord.flameSizes[time] =
                                                    option['value'] as String;
                                              });
                                              _saveFlameRecord();
                                            },
                                          );
                                        }).toList(),
                                  ),
                                ),
                                if (_flameSizeTimes.length > 3 && time > 1)
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: colorScheme.error,
                                      size: 20.0,
                                    ),
                                    tooltip: 'Delete Time',
                                    onPressed: () => _deleteFlameSizeTime(time),
                                  ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 12.0),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _addFlameSizeTime,
                            icon: Icon(
                              Icons.add,
                              color: colorScheme.onPrimary,
                              size: 20.0,
                            ),
                            label: Text(
                              'Add 0.5 Hour Interval',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 10.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Card(
                        color: colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Flickering',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              Wrap(
                                spacing: 12.0,
                                children: ['Yes', 'No'].map((value) {
                                  return ChoiceChip(
                                    label: Text(
                                      value,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color:
                                            (flameRecord.flickering
                                                    ? 'Yes'
                                                    : 'No') ==
                                                value
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                    selected:
                                        (flameRecord.flickering
                                            ? 'Yes'
                                            : 'No') ==
                                        value,
                                    selectedColor: colorScheme.primary,
                                    backgroundColor: colorScheme.surface,
                                    showCheckmark: false,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onSelected: (_) {
                                      setState(() {
                                        flameRecord.flickering = value == 'Yes';
                                      });
                                      _saveFlameRecord();
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Card(
                        color: colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mushrooming',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              Wrap(
                                spacing: 12.0,
                                children: ['Yes', 'No'].map((value) {
                                  return ChoiceChip(
                                    label: Text(
                                      value,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color:
                                            (flameRecord.mushrooming
                                                    ? 'Yes'
                                                    : 'No') ==
                                                value
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                    selected:
                                        (flameRecord.mushrooming
                                            ? 'Yes'
                                            : 'No') ==
                                        value,
                                    selectedColor: colorScheme.primary,
                                    backgroundColor: colorScheme.surface,
                                    showCheckmark: false,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onSelected: (_) {
                                      setState(() {
                                        flameRecord.mushrooming =
                                            value == 'Yes';
                                      });
                                      _saveFlameRecord();
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Card(
                        color: colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sooting',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              Wrap(
                                spacing: 12.0,
                                children: ['Yes', 'No'].map((value) {
                                  return ChoiceChip(
                                    label: Text(
                                      value,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color:
                                            (flameRecord.sooting
                                                    ? 'Yes'
                                                    : 'No') ==
                                                value
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                    selected:
                                        (flameRecord.sooting ? 'Yes' : 'No') ==
                                        value,
                                    selectedColor: colorScheme.primary,
                                    backgroundColor: colorScheme.surface,
                                    showCheckmark: false,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onSelected: (_) {
                                      setState(() {
                                        flameRecord.sooting = value == 'Yes';
                                      });
                                      _saveFlameRecord();
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Card(
                        color: colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Full Burning Time',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              InkWell(
                                onTap: _showBurningTimePicker,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 12.0,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: colorScheme.primary,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        flameRecord.fullBurningTime != null
                                            ? '${flameRecord.fullBurningTime!.inMinutes ~/ 60}h ${flameRecord.fullBurningTime!.inMinutes % 60}m'
                                            : 'Select time',
                                        style: textTheme.bodyMedium,
                                      ),
                                      Icon(
                                        Icons.access_time,
                                        color: colorScheme.primary,
                                        size: 20.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Card(
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Records',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        TextField(
                          controller: _recordsController,
                          decoration: InputDecoration(
                            labelText: 'Notes',
                            hintText: 'Enter your notes',
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0,
                            ),
                          ),
                          style: textTheme.bodyMedium,
                          maxLines: 2,
                          onChanged: (value) {
                            setState(() {
                              flameRecord.records = value;
                            });
                            _saveFlameRecord();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Card(
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Photos',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Center(
                          child: Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(Icons.add_a_photo_outlined),
                              onPressed: () {
                                final RenderBox button =
                                    context.findRenderObject() as RenderBox;
                                final RenderBox overlay =
                                    Overlay.of(
                                          context,
                                        ).context.findRenderObject()
                                        as RenderBox;
                                final RelativeRect position =
                                    RelativeRect.fromRect(
                                      Rect.fromPoints(
                                        button.localToGlobal(
                                          Offset.zero,
                                          ancestor: overlay,
                                        ),
                                        button.localToGlobal(
                                          button.size.bottomRight(Offset.zero),
                                          ancestor: overlay,
                                        ),
                                      ),
                                      Offset.zero & overlay.size,
                                    );

                                showMenu<String>(
                                  context: context,
                                  position: position,
                                  items: [
                                    const PopupMenuItem<String>(
                                      value: 'camera',
                                      child: ListTile(
                                        leading: Icon(Icons.camera_alt),
                                        title: Text('Take a photo'),
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'gallery',
                                      child: ListTile(
                                        leading: Icon(Icons.photo_library),
                                        title: Text('Choose from gallery'),
                                      ),
                                    ),
                                  ],
                                ).then((value) {
                                  if (value == 'camera') {
                                    _addPhoto(fromCamera: true);
                                  } else if (value == 'gallery') {
                                    _addPhoto(fromCamera: false);
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        if (_tempImageFiles.isNotEmpty ||
                            flameRecord.photoUrls.isNotEmpty) ...[
                          const SizedBox(height: 16.0),
                          // In the photos section, replace the current ListView with this:
                          SizedBox(
                            height: 80,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                // Display temporary files - use Image.file
                                ..._tempImageFiles.map(
                                  (file) => GestureDetector(
                                    onTap: () =>
                                        _showEnlargedPhoto(file: file, time: 0),
                                    child: Container(
                                      margin: const EdgeInsets.all(4.0),
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                        border: Border.all(
                                          color: colorScheme.primary
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                        child: Image.file(
                                          file,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                print(
                                                  'Error loading file: $error',
                                                );
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    size: 20,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                ...flameRecord.photoUrls
                                    .where((url) => url.startsWith('http'))
                                    .map(
                                      (url) => GestureDetector(
                                        onTap: () => _showEnlargedPhoto(
                                          url: url,
                                          time: 0,
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.all(4.0),
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            border: Border.all(
                                              color: colorScheme.primary
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: url,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              progressIndicatorBuilder:
                                                  (
                                                    context,
                                                    url,
                                                    downloadProgress,
                                                  ) => Container(
                                                    color: Colors.grey[200],
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress,
                                                            strokeWidth: 2,
                                                          ),
                                                    ),
                                                  ),
                                              errorWidget: (context, url, error) {
                                                print(
                                                  'Error loading URL: $url, Error: $error',
                                                );
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    size: 20,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // const SizedBox(height: 16.0),
                if (isScented) ...[
                  Divider(
                    color: colorScheme.primary.withOpacity(0.3),
                    thickness: 1.0,
                    indent: 16.0,
                    endIndent: 16.0,
                  ),
                  const SizedBox(height: 16.0),
                  Card(
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Scent Throw',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            'Cold Throw',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Center(
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children:
                                  [
                                    'Strong',
                                    'Moderate',
                                    'Weak',
                                    'No scent',
                                  ].map((value) {
                                    return ChoiceChip(
                                      label: Text(
                                        value,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color:
                                              (flameRecord
                                                          .scentThrow
                                                          ?.coldThrow ??
                                                      '') ==
                                                  value
                                              ? colorScheme.onPrimary
                                              : colorScheme.onSurface,
                                        ),
                                      ),
                                      selected:
                                          (flameRecord.scentThrow?.coldThrow ??
                                              '') ==
                                          value,
                                      selectedColor: colorScheme.primary,
                                      backgroundColor: colorScheme.surface,
                                      showCheckmark: false,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      onSelected: (_) {
                                        setState(() {
                                          flameRecord.scentThrow ??=
                                              ScentThrow();
                                          flameRecord.scentThrow!.coldThrow =
                                              value;
                                        });
                                        _saveFlameRecord();
                                      },
                                    );
                                  }).toList(),
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            'Hot Throw',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          ...[0.5, 1.0, 2.0, 4.0].map((distance) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$distance m',
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Center(
                                    child: Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children:
                                          [
                                            'Strong',
                                            'Moderate',
                                            'Weak',
                                            'No scent',
                                          ].map((value) {
                                            return ChoiceChip(
                                              label: Text(
                                                value,
                                                style: textTheme.bodyMedium
                                                    ?.copyWith(
                                                      color:
                                                          (flameRecord
                                                                      .scentThrow
                                                                      ?.hotThrow[distance] ??
                                                                  '') ==
                                                              value
                                                          ? colorScheme
                                                                .onPrimary
                                                          : colorScheme
                                                                .onSurface,
                                                    ),
                                              ),
                                              selected:
                                                  (flameRecord
                                                          .scentThrow
                                                          ?.hotThrow[distance] ??
                                                      '') ==
                                                  value,
                                              selectedColor:
                                                  colorScheme.primary,
                                              backgroundColor:
                                                  colorScheme.surface,
                                              showCheckmark: false,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              onSelected: (_) {
                                                setState(() {
                                                  flameRecord.scentThrow ??=
                                                      ScentThrow();
                                                  flameRecord
                                                          .scentThrow!
                                                          .hotThrow[distance] =
                                                      value;
                                                });
                                                _saveFlameRecord();
                                              },
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
                if (isContainerOrPillar) ...[
                  const SizedBox(height: 16.0),
                  Divider(
                    color: colorScheme.primary.withOpacity(0.3),
                    thickness: 1.0,
                    indent: 16.0,
                    endIndent: 16.0,
                  ),
                  const SizedBox(height: 16.0),
                  Card(
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Melt Measure',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          ..._meltMeasureTimes.map((time) {
                            final measure = flameRecord.meltMeasures.firstWhere(
                              (m) => m.time == time,
                              orElse: () =>
                                  MeltMeasure(time: time, photoUrls: []),
                            );
                            _diameterControllers.putIfAbsent(
                              time,
                              () => TextEditingController(
                                text: measure.meltDiameter == 0.0
                                    ? ''
                                    : measure.meltDiameter.toInt() ==
                                          measure.meltDiameter
                                    ? measure.meltDiameter.toInt().toString()
                                    : measure.meltDiameter.toString(),
                              ),
                            );
                            _depthControllers.putIfAbsent(
                              time,
                              () => TextEditingController(
                                text: measure.meltDepth == 0.0
                                    ? ''
                                    : measure.meltDepth.toInt() ==
                                          measure.meltDepth
                                    ? measure.meltDepth.toInt().toString()
                                    : measure.meltDepth.toString(),
                              ),
                            );

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Time header
                                  Text(
                                    '$time hours',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 12.0),

                                  // Text fields row
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: TextField(
                                          controller:
                                              _diameterControllers[time],
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: InputDecoration(
                                            labelText: 'Diameter (cm)',
                                            border: const OutlineInputBorder(),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 8.0,
                                                ),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              measure.meltDiameter =
                                                  double.tryParse(value) ?? 0.0;
                                            });
                                            _saveFlameRecord();
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                      Expanded(
                                        flex: 3,
                                        child: TextField(
                                          controller: _depthControllers[time],
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: InputDecoration(
                                            labelText: 'Depth (cm)',
                                            border: const OutlineInputBorder(),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 8.0,
                                                ),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              measure.meltDepth =
                                                  double.tryParse(value) ?? 0.0;
                                            });
                                            _saveFlameRecord();
                                          },
                                        ),
                                      ),
                                      if (_meltMeasureTimes.length > 3 &&
                                          time > 1)
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: colorScheme.error,
                                            size: 20.0,
                                          ),
                                          tooltip: 'Delete Time',
                                          onPressed: () =>
                                              _deleteMeltMeasureTime(time),
                                        ),
                                    ],
                                  ),

                                  // Camera button and photos section - BELOW the text fields
                                  const SizedBox(height: 12.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Camera button
                                      Builder(
                                        builder: (context) => IconButton(
                                          icon: Icon(
                                            Icons.add_a_photo,
                                            color: colorScheme.primary,
                                            size: 24.0,
                                          ),
                                          tooltip: 'Add Photo',
                                          onPressed: () {
                                            final RenderBox button =
                                                context.findRenderObject()
                                                    as RenderBox;
                                            final RenderBox overlay =
                                                Overlay.of(
                                                      context,
                                                    ).context.findRenderObject()
                                                    as RenderBox;
                                            final RelativeRect position =
                                                RelativeRect.fromRect(
                                                  Rect.fromPoints(
                                                    button.localToGlobal(
                                                      Offset.zero,
                                                      ancestor: overlay,
                                                    ),
                                                    button.localToGlobal(
                                                      button.size.bottomRight(
                                                        Offset.zero,
                                                      ),
                                                      ancestor: overlay,
                                                    ),
                                                  ),
                                                  Offset.zero & overlay.size,
                                                );

                                            showMenu<String>(
                                              context: context,
                                              position: position,
                                              items: [
                                                const PopupMenuItem<String>(
                                                  value: 'camera',
                                                  child: ListTile(
                                                    leading: Icon(
                                                      Icons.camera_alt,
                                                    ),
                                                    title: Text('Take a photo'),
                                                  ),
                                                ),
                                                const PopupMenuItem<String>(
                                                  value: 'gallery',
                                                  child: ListTile(
                                                    leading: Icon(
                                                      Icons.photo_library,
                                                    ),
                                                    title: Text(
                                                      'Choose from gallery',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ).then((value) {
                                              if (value == 'camera') {
                                                _addMeltMeasurePhoto(
                                                  time,
                                                  fromCamera: true,
                                                );
                                              } else if (value == 'gallery') {
                                                _addMeltMeasurePhoto(
                                                  time,
                                                  fromCamera: false,
                                                );
                                              }
                                            });
                                          },
                                        ),
                                      ),

                                      // Photo thumbnails
                                      Expanded(
                                        child: Wrap(
                                          alignment: WrapAlignment.end,
                                          spacing: 8.0,
                                          children: [
                                            ...measure.tempPhotos.map(
                                              (file) => GestureDetector(
                                                onTap: () => _showEnlargedPhoto(
                                                  file: file,
                                                  time: time,
                                                ),
                                                child: Image.file(
                                                  file,
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            ...measure.photoUrls.map(
                                              (url) => GestureDetector(
                                                onTap: () => _showEnlargedPhoto(
                                                  url: url,
                                                  time: time,
                                                ),
                                                child: CachedNetworkImage(
                                                  imageUrl: url,
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                  progressIndicatorBuilder:
                                                      (
                                                        context,
                                                        url,
                                                        downloadProgress,
                                                      ) => Container(
                                                        color: Colors.grey[200],
                                                        child: Center(
                                                          child: CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress,
                                                            strokeWidth: 2,
                                                          ),
                                                        ),
                                                      ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const Icon(
                                                            Icons.error,
                                                          ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 12.0),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _addMeltMeasureTime,
                              icon: Icon(
                                Icons.add,
                                color: colorScheme.onPrimary,
                                size: 20.0,
                              ),
                              label: Text(
                                'Add 0.5 Hour Interval',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 10.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearFlameRecord,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.error),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                        ),
                        child: Text(
                          'Clear',
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _markAsFlamed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Text(
                                'Done',
                                style: textTheme.titleLarge?.copyWith(
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
