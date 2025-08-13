import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'custom_drawer.dart';
import 'making_screen9.dart';
import '../models/candle_data.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';
import 'dart:async';
import 'dart:io';
import '../services/image_service.dart';

class MakingScreen8 extends StatefulWidget {
  final CandleData candleData;

  const MakingScreen8({super.key, required this.candleData});

  @override
  State<MakingScreen8> createState() => _MakingScreen8State();
}

class _SaveProgressDialog extends StatefulWidget {
  final int totalSteps;
  final Future<bool> Function(void Function(int)) onSave;

  const _SaveProgressDialog({required this.totalSteps, required this.onSave});

  @override
  State<_SaveProgressDialog> createState() => _SaveProgressDialogState();
}

class _SaveProgressDialogState extends State<_SaveProgressDialog> {
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
          const Text('Saving Candle Data...'),
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

class _MakingScreen8State extends State<MakingScreen8> {
  final _formKey = GlobalKey<FormState>();
  final _coolDownController = TextEditingController();
  final _curingController = TextEditingController();
  final _burningDayController = TextEditingController();

  bool _isSaving = false;
  TimeOfDay? _selectedReminderTime;
  List<String> _photoUrls = [];
  List<File> _tempImageFiles = [];
  DateTime? _calculatedBurningDay;
  bool _isContentVisible = false;
  StreamSubscription? _candleSubscription;
  int _totalSteps = 1;

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
    _subscribeToCandles();
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
      _photoUrls = List.from(detail.photoUrls);
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

  Future<void> _addPhoto({bool fromCamera = false}) async {
    final image = await ImageService.pickImage(fromCamera: fromCamera);
    if (image != null) {
      setState(() => _tempImageFiles.add(image));
    }
  }

  Future<void> _showEnlargedPhoto({String? url, File? file}) async {
    if (url == null && file == null) return;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              InteractiveViewer(
                child: url != null
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
                      if (url != null) {
                        await ImageService.deleteImage(url);
                        setState(() => _photoUrls.remove(url));
                      } else if (file != null) {
                        setState(() => _tempImageFiles.remove(file));
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

  Future<void> _saveDataAndNavigate() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Calculate total steps
      int totalSteps = 2; // Initial and final saves
      totalSteps +=
          widget.candleData.temperatureDetail?.tempImageFiles?.length ?? 0;
      totalSteps += _tempImageFiles.length;

      // Show progress dialog
      final saveSuccess = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return _SaveProgressDialog(
            totalSteps: totalSteps,
            onSave: (updateProgress) => _performSaveOperation(updateProgress),
          );
        },
      );

      if (saveSuccess == true && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MakingScreen9(candleData: widget.candleData),
          ),
        );
      } else if (saveSuccess == false && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save data')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<bool> _performSaveOperation(void Function(int) updateProgress) async {
    int completedSteps = 0;
    try {
      // Update candle data
      widget.candleData.coolingCuringDetail = CoolingCuringDetail(
        coolDownTime: double.tryParse(_coolDownController.text) ?? 0.0,
        curingDays: int.tryParse(_curingController.text) ?? 0,
        burningDay: _calculatedBurningDay,
        reminderTime: _selectedReminderTime,
        photoUrls: _photoUrls,
        tempImageFiles: [],
      );

      widget.candleData.totalCost = widget.candleData.calculateTotalCost();

      // Initial save if new candle
      if (widget.candleData.id == null) {
        await FirestoreService().saveCandleData(widget.candleData);
        updateProgress(++completedSteps);
      }

      // Upload temperature images
      if (widget.candleData.temperatureDetail?.tempImageFiles?.isNotEmpty ??
          false) {
        final urls = await ImageService.uploadImages(
          widget.candleData.temperatureDetail!.tempImageFiles!,
          'candles/${widget.candleData.userId}/${widget.candleData.id}/images/temp',
          onProgress: (index, total) {
            updateProgress(++completedSteps);
          },
        );
        widget.candleData.temperatureDetail!.photoUrls.addAll(urls);
        widget.candleData.temperatureDetail!.tempImageFiles!.clear();
      }

      // Upload cooling images
      if (_tempImageFiles.isNotEmpty) {
        final urls = await ImageService.uploadImages(
          _tempImageFiles,
          'candles/${widget.candleData.userId}/${widget.candleData.id}/images/cool',
          onProgress: (index, total) {
            updateProgress(++completedSteps);
          },
        );
        widget.candleData.coolingCuringDetail!.photoUrls.addAll(urls);
        _tempImageFiles.clear();
      }

      // Final save
      await FirestoreService().saveCandleData(widget.candleData);
      updateProgress(++completedSteps);

      // Schedule notification if needed
      if (_selectedReminderTime != null && _calculatedBurningDay != null) {
        final notificationTime = DateTime(
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
          scheduledDate: notificationTime,
          candleName: widget.candleData.sampleName ?? 'Unknown Candle',
          candleType: widget.candleData.candleType ?? 'Unknown',
        );
      }

      return true;
    } catch (e) {
      print('Save process failed: $e');
      return false;
    }
  }

  void _subscribeToCandles() {
    if (mounted) {
      _candleSubscription?.cancel();
      _candleSubscription = FirestoreService()
          .getCandlesByUser(widget.candleData.userId ?? '')
          .listen((snapshot) {});
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
    _candleSubscription?.cancel();
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
        leading: Builder(
          builder: (context) => StreamBuilder<int>(
            stream: NotificationService.unreadCountStream,
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
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
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.add_a_photo_outlined),
                onPressed: () {
                  final RenderBox button =
                      context.findRenderObject() as RenderBox;
                  final RenderBox overlay =
                      Overlay.of(context).context.findRenderObject()
                          as RenderBox;
                  final RelativeRect position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(Offset.zero, ancestor: overlay),
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
          if (_photoUrls.isNotEmpty || _tempImageFiles.isNotEmpty) ...[
            const SizedBox(height: 16.0),
            Wrap(
              children: [
                ..._tempImageFiles.map(
                  (file) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap: () => _showEnlargedPhoto(file: file),
                      child: Image.file(file, width: 60, height: 60),
                    ),
                  ),
                ),
                ..._photoUrls.map(
                  (url) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap: () => _showEnlargedPhoto(url: url),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        width: 60,
                        height: 60,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ],
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
