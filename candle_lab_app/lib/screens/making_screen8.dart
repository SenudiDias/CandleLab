import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'custom_drawer.dart';
import 'making_screen9.dart';
import '../models/candle_data.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';
import 'dart:async';

class MakingScreen8 extends StatefulWidget {
  final CandleData candleData;

  const MakingScreen8({super.key, required this.candleData});

  @override
  State<MakingScreen8> createState() => _MakingScreen8State();
}

class _MakingScreen8State extends State<MakingScreen8> {
  final _formKey = GlobalKey<FormState>();
  final _coolDownController = TextEditingController();
  final _curingController = TextEditingController();
  final _burningDayController = TextEditingController();

  bool _isSaving = false;
  TimeOfDay? _selectedReminderTime;
  List<String> _photoPaths = [];
  DateTime? _calculatedBurningDay;
  bool _isContentVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _curingController.addListener(_updateBurningDay);

    Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isContentVisible = true;
        });
      }
    });
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

  Future<void> _saveDataAndNavigate() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to save data')),
        );
      }
      setState(() => _isSaving = false);
      return;
    }

    // Update cooling and curing details
    widget.candleData.coolingCuringDetail = CoolingCuringDetail(
      coolDownTime: double.tryParse(_coolDownController.text) ?? 0.0,
      curingDays: int.tryParse(_curingController.text) ?? 0,
      burningDay: _calculatedBurningDay,
      reminderTime: _selectedReminderTime,
      photoPaths: _photoPaths,
    );

    // Nullify details if their respective flags are false
    if (widget.candleData.isScented == false) {
      widget.candleData.scentDetail = null;
    }
    if (widget.candleData.isWicked == false) {
      widget.candleData.wickDetail = null;
    }
    if (widget.candleData.isColoured == false) {
      widget.candleData.colourDetail = null;
    }

    widget.candleData.totalCost = widget.candleData.calculateTotalCost();

    try {
      await FirestoreService().saveCandleData(widget.candleData);

      if (_calculatedBurningDay != null && _selectedReminderTime != null) {
        final reminderDateTime = DateTime(
          _calculatedBurningDay!.year,
          _calculatedBurningDay!.month,
          _calculatedBurningDay!.day,
          _selectedReminderTime!.hour,
          _selectedReminderTime!.minute,
        );

        await NotificationService.scheduleNotification(
          id:
              widget.candleData.id?.hashCode ??
              widget.candleData.sampleName.hashCode,
          title: 'Curing Complete!',
          body:
              'Your candle "${widget.candleData.sampleName}" is ready for burning.',
          scheduledDate: reminderDateTime,
          candleName: widget.candleData.sampleName ?? 'Unknown Candle',
          candleType: widget.candleData.candleType ?? 'Unknown',
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Candle data saved successfully')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MakingScreen9(candleData: widget.candleData),
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving data: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
    _curingController.removeListener(_updateBurningDay);
    _coolDownController.dispose();
    _curingController.dispose();
    _burningDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Making - Cooling & Curing'),
        actions: [
          StreamBuilder<DateTime>(
            stream: _dateTimeStream(),
            builder: (context, snapshot) {
              final now = snapshot.data ?? DateTime.now();
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('MMM d, yyyy').format(now),
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('h:mm a').format(now),
                      style: const TextStyle(
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
      drawer: const CustomDrawer(currentRoute: '/making'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: AnimatedOpacity(
            opacity: _isContentVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Sample Name: ${widget.candleData.sampleName}',
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Candle Type: ${widget.candleData.candleType}',
                          style: textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  _buildCoolingForm(),

                  const SizedBox(height: 32.0),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorScheme.primary),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 18,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveDataAndNavigate,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text('Next'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16.0),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildCoolingForm() {
    return _buildFormCard(
      title: 'Cooling & Curing Details',
      child: Column(
        children: [
          _buildTextFormField(
            controller: _coolDownController,
            label: 'Cool Down Time (h)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildTextFormField(
            controller: _curingController,
            label: 'Curing (days)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildTextFormField(
            controller: _burningDayController,
            label: 'Burning Day',
            readOnly: true,
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _selectReminderTime,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Reminder Time'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedReminderTime != null
                        ? _selectedReminderTime!.format(context)
                        : 'Set a time',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Icon(
                    Icons.access_time_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addPhoto,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Add Photo'),
            ),
          ),
          if (_photoPaths.isNotEmpty) ...[
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _photoPaths.map((path) {
                return Chip(
                  label: Text(path),
                  onDeleted: () => _removePhoto(path),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  deleteIconColor: Theme.of(context).colorScheme.primary,
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        fillColor: readOnly ? Colors.black.withOpacity(0.05) : null,
      ),
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
          : [],
      validator: (value) {
        if (readOnly) return null;
        if (value == null || value.isEmpty) return 'Required';
        if (keyboardType == TextInputType.number &&
            (double.tryParse(value) == null || double.parse(value) < 0)) {
          return 'Invalid';
        }
        return null;
      },
    );
  }
}
