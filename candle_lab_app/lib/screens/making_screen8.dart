import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'custom_drawer.dart';
import 'making_screen9.dart';
import '../models/candle_data.dart';
import '../services/notification_service.dart';

class MakingScreen8 extends StatefulWidget {
  final CandleData candleData;

  const MakingScreen8({super.key, required this.candleData});

  @override
  State<MakingScreen8> createState() => _MakingScreen8State();
}

class _MakingScreen8State extends State<MakingScreen8> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _coolDownController = TextEditingController();
  final TextEditingController _curingController = TextEditingController();
  final TextEditingController _burningDayController = TextEditingController();

  TimeOfDay? _selectedReminderTime;
  List<String> _photoPaths = [];
  DateTime? _calculatedBurningDay;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _curingController.addListener(_updateBurningDay);
  }

  void _initializeData() {
    if (widget.candleData.coolingCuringDetail != null) {
      final detail = widget.candleData.coolingCuringDetail!;
      _coolDownController.text = detail.coolDownTime.toString();
      _curingController.text = detail.curingDays.toString();
      _burningDayController.text = detail.burningDay != null
          ? DateFormat('MMM d, yyyy').format(detail.burningDay!)
          : '';
      _selectedReminderTime = detail.reminderTime;
      _photoPaths = List.from(detail.photoPaths);
      _calculatedBurningDay = detail.burningDay;
    }
  }

  void _updateBurningDay() {
    final curingDays = int.tryParse(_curingController.text);
    if (curingDays != null && curingDays > 0) {
      setState(() {
        _calculatedBurningDay = DateTime.now().add(Duration(days: curingDays));
        _burningDayController.text = DateFormat(
          'MMM d, yyyy',
        ).format(_calculatedBurningDay!);
      });
    } else {
      setState(() {
        _calculatedBurningDay = null;
        _burningDayController.text = '';
      });
    }
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedReminderTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedReminderTime = picked;
      });
    }
  }

  void _addPhoto() {
    setState(() {
      _photoPaths.add('cooling_photo_${_photoPaths.length + 1}.jpg');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Photo added (simulated)')));
    });
  }

  void _removePhoto(String path) {
    setState(() {
      _photoPaths.remove(path);
    });
  }

  void _saveData() {
    final curingDays = int.tryParse(_curingController.text) ?? 0;
    final coolDownTime = double.tryParse(_coolDownController.text) ?? 0.0;

    widget.candleData.coolingCuringDetail = CoolingCuringDetail(
      coolDownTime: coolDownTime,
      curingDays: curingDays,
      burningDay: _calculatedBurningDay,
      reminderTime: _selectedReminderTime,
      photoPaths: _photoPaths,
    );

    // Schedule notification if reminder time is set
    if (_calculatedBurningDay != null && _selectedReminderTime != null) {
      final reminderDateTime = DateTime(
        _calculatedBurningDay!.year,
        _calculatedBurningDay!.month,
        _calculatedBurningDay!.day,
        _selectedReminderTime!.hour,
        _selectedReminderTime!.minute,
      );

      NotificationService.scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'Curing Complete!',
        body:
            'Your candle "${widget.candleData.sampleName}" is ready for burning.',
        scheduledDate: reminderDateTime,
        candleName: widget.candleData.sampleName ?? 'Unknown Candle',
      );
    }
  }

  Stream<DateTime> _dateTimeStream() async* {
    while (true) {
      yield DateTime.now();
      await Future.delayed(const Duration(minutes: 1));
    }
  }

  @override
  void dispose() {
    _coolDownController.dispose();
    _curingController.dispose();
    _burningDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF795548),
        title: const Text(
          'Making - Cooling & Curing',
          style: TextStyle(fontFamily: 'Georgia', color: Colors.white),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
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
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(currentRoute: '/making'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D4037).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sample: ${widget.candleData.sampleName}',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Georgia',
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Candle Type: ${widget.candleData.candleType}',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Georgia',
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Cooling & Curing Details',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                    color: Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 16.0),
                Card(
                  elevation: 3.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _coolDownController,
                          decoration: const InputDecoration(
                            labelText: 'Cool Down Time (h)',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'Georgia',
                            color: Color(0xFF5D4037),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _curingController,
                          decoration: const InputDecoration(
                            labelText: 'Curing (days)',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'Georgia',
                            color: Color(0xFF5D4037),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _burningDayController,
                          decoration: const InputDecoration(
                            labelText: 'Burning Day',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          readOnly: true,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'Georgia',
                            color: Color(0xFF5D4037),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4.0),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedReminderTime != null
                                          ? 'Reminder: ${_selectedReminderTime!.format(context)}'
                                          : 'No reminder set',
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        fontFamily: 'Georgia',
                                        color: Color(0xFF5D4037),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _selectReminderTime,
                                      icon: const Icon(Icons.access_time),
                                      color: const Color(0xFF795548),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _addPhoto,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF795548),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                ),
                                child: const Text(
                                  'Add Photo',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontFamily: 'Georgia',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_photoPaths.isNotEmpty) ...[
                          const SizedBox(height: 16.0),
                          const Text(
                            'Photos',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Georgia',
                              color: Color(0xFF5D4037),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _photoPaths.map((path) {
                              return Chip(
                                label: Text(
                                  path,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontFamily: 'Georgia',
                                    color: Color(0xFF5D4037),
                                  ),
                                ),
                                deleteIcon: const Icon(Icons.cancel, size: 18),
                                onDeleted: () => _removePhoto(path),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                            fontFamily: 'Georgia',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _saveData();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MakingScreen9(
                                  candleData: widget.candleData,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF795548),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                            fontFamily: 'Georgia',
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
