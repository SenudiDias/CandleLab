import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'custom_drawer.dart';
import 'making_screen8.dart';
import '../models/candle_data.dart';
import '../services/notification_service.dart';
import 'dart:async';

class MakingScreen7 extends StatefulWidget {
  final CandleData candleData;

  const MakingScreen7({super.key, required this.candleData});

  @override
  State<MakingScreen7> createState() => _MakingScreen7State();
}

class _MakingScreen7State extends State<MakingScreen7> {
  final _formKey = GlobalKey<FormState>();
  final _maxHeatedCController = TextEditingController();
  final _maxHeatedFController = TextEditingController();
  final _fragranceMixingCController = TextEditingController();
  final _fragranceMixingFController = TextEditingController();
  final _pouringCController = TextEditingController();
  final _pouringFController = TextEditingController();
  final _ambientTempCController = TextEditingController();
  final _ambientTempFController = TextEditingController();

  List<String> _photoPaths = [];
  bool _isUpdating = false;
  bool _isContentVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _addTemperatureListeners();

    Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isContentVisible = true;
        });
      }
    });
  }

  void _initializeData() {
    if (widget.candleData.temperatureDetail != null) {
      final temp = widget.candleData.temperatureDetail!;
      _maxHeatedCController.text = temp.maxHeatedC.toStringAsFixed(1);
      _maxHeatedFController.text = temp.maxHeatedF.toStringAsFixed(1);
      _fragranceMixingCController.text = temp.fragranceMixingC.toStringAsFixed(
        1,
      );
      _fragranceMixingFController.text = temp.fragranceMixingF.toStringAsFixed(
        1,
      );
      _pouringCController.text = temp.pouringC.toStringAsFixed(1);
      _pouringFController.text = temp.pouringF.toStringAsFixed(1);
      _ambientTempCController.text = temp.ambientTempC.toStringAsFixed(1);
      _ambientTempFController.text = temp.ambientTempF.toStringAsFixed(1);
      _photoPaths = List.from(temp.photoPaths);
    }
  }

  void _addTemperatureListeners() {
    _maxHeatedCController.addListener(
      () => _convertTemperature(
        _maxHeatedCController,
        _maxHeatedFController,
        toFahrenheit: true,
      ),
    );
    _maxHeatedFController.addListener(
      () => _convertTemperature(
        _maxHeatedFController,
        _maxHeatedCController,
        toFahrenheit: false,
      ),
    );
    _fragranceMixingCController.addListener(
      () => _convertTemperature(
        _fragranceMixingCController,
        _fragranceMixingFController,
        toFahrenheit: true,
      ),
    );
    _fragranceMixingFController.addListener(
      () => _convertTemperature(
        _fragranceMixingFController,
        _fragranceMixingCController,
        toFahrenheit: false,
      ),
    );
    _pouringCController.addListener(
      () => _convertTemperature(
        _pouringCController,
        _pouringFController,
        toFahrenheit: true,
      ),
    );
    _pouringFController.addListener(
      () => _convertTemperature(
        _pouringFController,
        _pouringCController,
        toFahrenheit: false,
      ),
    );
    _ambientTempCController.addListener(
      () => _convertTemperature(
        _ambientTempCController,
        _ambientTempFController,
        toFahrenheit: true,
      ),
    );
    _ambientTempFController.addListener(
      () => _convertTemperature(
        _ambientTempFController,
        _ambientTempCController,
        toFahrenheit: false,
      ),
    );
  }

  void _convertTemperature(
    TextEditingController source,
    TextEditingController target, {
    required bool toFahrenheit,
  }) {
    if (_isUpdating) return;
    final value = double.tryParse(source.text);
    if (value != null) {
      _isUpdating = true;
      double convertedValue = toFahrenheit
          ? (value * 9 / 5 + 32)
          : ((value - 32) * 5 / 9);
      target.text = convertedValue.toStringAsFixed(1);
      _isUpdating = false;
    } else if (source.text.isEmpty) {
      _isUpdating = true;
      target.text = '';
      _isUpdating = false;
    }
  }

  // This is a simulation. In a real app, you would use image_picker.
  void _addPhoto() {
    setState(() {
      _photoPaths.add('photo${_photoPaths.length + 1}.jpg');
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

  @override
  void dispose() {
    _maxHeatedCController.dispose();
    _maxHeatedFController.dispose();
    _fragranceMixingCController.dispose();
    _fragranceMixingFController.dispose();
    _pouringCController.dispose();
    _pouringFController.dispose();
    _ambientTempCController.dispose();
    _ambientTempFController.dispose();
    super.dispose();
  }

  void _saveDataAndNavigate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.candleData.temperatureDetail = TemperatureDetail(
      maxHeatedC: double.tryParse(_maxHeatedCController.text) ?? 0.0,
      maxHeatedF: double.tryParse(_maxHeatedFController.text) ?? 0.0,
      fragranceMixingC:
          double.tryParse(_fragranceMixingCController.text) ?? 0.0,
      fragranceMixingF:
          double.tryParse(_fragranceMixingFController.text) ?? 0.0,
      pouringC: double.tryParse(_pouringCController.text) ?? 0.0,
      pouringF: double.tryParse(_pouringFController.text) ?? 0.0,
      ambientTempC: double.tryParse(_ambientTempCController.text) ?? 0.0,
      ambientTempF: double.tryParse(_ambientTempFController.text) ?? 0.0,
      photoPaths: _photoPaths,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MakingScreen8(candleData: widget.candleData),
      ),
    );
  }

  Stream<DateTime> _dateTimeStream() async* {
    while (true) {
      yield DateTime.now();
      await Future.delayed(const Duration(minutes: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Making - Temperature'),
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

                  _buildTemperatureForm(),

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
                          onPressed: _saveDataAndNavigate,
                          child: const Text('Next'),
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

  Widget _buildTemperatureForm() {
    return _buildFormCard(
      title: 'Temperature Details',
      child: Column(
        children: [
          _buildTempRow(
            celsiusController: _maxHeatedCController,
            fahrenheitController: _maxHeatedFController,
            label: 'Max Heated',
          ),
          const SizedBox(height: 12),
          _buildTempRow(
            celsiusController: _fragranceMixingCController,
            fahrenheitController: _fragranceMixingFController,
            label: 'Fragrance Mixing',
          ),
          const SizedBox(height: 12),
          _buildTempRow(
            celsiusController: _pouringCController,
            fahrenheitController: _pouringFController,
            label: 'Pouring',
          ),
          const SizedBox(height: 12),
          _buildTempRow(
            celsiusController: _ambientTempCController,
            fahrenheitController: _ambientTempFController,
            label: 'Ambient Temp',
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

  Widget _buildTempRow({
    required TextEditingController celsiusController,
    required TextEditingController fahrenheitController,
    required String label,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildTextFormField(
            controller: celsiusController,
            label: '$label (°C)',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTextFormField(
            controller: fahrenheitController,
            label: '$label (°F)',
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (double.tryParse(value) == null) return 'Invalid';
        return null;
      },
    );
  }
}
