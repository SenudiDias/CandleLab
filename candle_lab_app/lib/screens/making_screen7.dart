import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'custom_drawer.dart';
import 'making_screen8.dart';
import '../models/candle_data.dart';

class MakingScreen7 extends StatefulWidget {
  final CandleData candleData;

  const MakingScreen7({super.key, required this.candleData});

  @override
  State<MakingScreen7> createState() => _MakingScreen7State();
}

class _MakingScreen7State extends State<MakingScreen7> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _maxHeatedCController = TextEditingController();
  final TextEditingController _maxHeatedFController = TextEditingController();
  final TextEditingController _fragranceMixingCController =
      TextEditingController();
  final TextEditingController _fragranceMixingFController =
      TextEditingController();
  final TextEditingController _pouringCController = TextEditingController();
  final TextEditingController _pouringFController = TextEditingController();
  final TextEditingController _ambientTempCController = TextEditingController();
  final TextEditingController _ambientTempFController = TextEditingController();

  final FocusNode _maxHeatedCFocus = FocusNode();
  final FocusNode _maxHeatedFFocus = FocusNode();
  final FocusNode _fragranceMixingCFocus = FocusNode();
  final FocusNode _fragranceMixingFFocus = FocusNode();
  final FocusNode _pouringCFocus = FocusNode();
  final FocusNode _pouringFFocus = FocusNode();
  final FocusNode _ambientTempCFocus = FocusNode();
  final FocusNode _ambientTempFFocus = FocusNode();

  List<String> _photoPaths = [];
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _addTemperatureListeners();
  }

  void _initializeData() {
    if (widget.candleData.temperatureDetail != null) {
      final temp = widget.candleData.temperatureDetail!;
      _maxHeatedCController.text = temp.maxHeatedC.toStringAsFixed(2);
      _maxHeatedFController.text = temp.maxHeatedF.toStringAsFixed(2);
      _fragranceMixingCController.text = temp.fragranceMixingC.toStringAsFixed(
        2,
      );
      _fragranceMixingFController.text = temp.fragranceMixingF.toStringAsFixed(
        2,
      );
      _pouringCController.text = temp.pouringC.toStringAsFixed(2);
      _pouringFController.text = temp.pouringF.toStringAsFixed(2);
      _ambientTempCController.text = temp.ambientTempC.toStringAsFixed(2);
      _ambientTempFController.text = temp.ambientTempF.toStringAsFixed(2);
      _photoPaths = List.from(temp.photoPaths);
    }
  }

  void _addTemperatureListeners() {
    // Add text change listeners for real-time conversion
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

    // Keep focus listeners for formatting when field loses focus
    _maxHeatedCFocus.addListener(
      () => _handleFocusChange(_maxHeatedCFocus, _maxHeatedCController),
    );

    _maxHeatedFFocus.addListener(
      () => _handleFocusChange(_maxHeatedFFocus, _maxHeatedFController),
    );

    _fragranceMixingCFocus.addListener(
      () => _handleFocusChange(
        _fragranceMixingCFocus,
        _fragranceMixingCController,
      ),
    );

    _fragranceMixingFFocus.addListener(
      () => _handleFocusChange(
        _fragranceMixingFFocus,
        _fragranceMixingFController,
      ),
    );

    _pouringCFocus.addListener(
      () => _handleFocusChange(_pouringCFocus, _pouringCController),
    );

    _pouringFFocus.addListener(
      () => _handleFocusChange(_pouringFFocus, _pouringFController),
    );

    _ambientTempCFocus.addListener(
      () => _handleFocusChange(_ambientTempCFocus, _ambientTempCController),
    );

    _ambientTempFFocus.addListener(
      () => _handleFocusChange(_ambientTempFFocus, _ambientTempFController),
    );
  }

  void _convertTemperature(
    TextEditingController source,
    TextEditingController target, {
    required bool toFahrenheit,
  }) {
    // Prevent infinite loop during updates
    if (_isUpdating) return;

    final value = double.tryParse(source.text);
    if (value != null && source.text.isNotEmpty) {
      _isUpdating = true;

      String convertedValue;
      if (toFahrenheit) {
        convertedValue = (value * 9 / 5 + 32).toStringAsFixed(2);
      } else {
        convertedValue = ((value - 32) * 5 / 9).toStringAsFixed(2);
      }

      target.text = convertedValue;
      _isUpdating = false;
    } else if (source.text.isEmpty) {
      _isUpdating = true;
      target.text = '';
      _isUpdating = false;
    }
  }

  void _handleFocusChange(
    FocusNode focusNode,
    TextEditingController controller,
  ) {
    if (!focusNode.hasFocus) {
      final value = double.tryParse(controller.text);
      if (value != null) {
        setState(() {
          controller.text = value.toStringAsFixed(2);
        });
      }
    }
  }

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
    _maxHeatedCFocus.dispose();
    _maxHeatedFFocus.dispose();
    _fragranceMixingCFocus.dispose();
    _fragranceMixingFFocus.dispose();
    _pouringCFocus.dispose();
    _pouringFFocus.dispose();
    _ambientTempCFocus.dispose();
    _ambientTempFFocus.dispose();
    super.dispose();
  }

  void _saveData() {
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
  }

  Stream<DateTime> _dateTimeStream() async* {
    while (true) {
      yield DateTime.now();
      await Future.delayed(const Duration(minutes: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF795548), // Brown
        title: const Text(
          'Making - Temperature Details',
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
              final timeFormatter = DateFormat('h:mm a'); // 12-hour format
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
                  'Temperature Details',
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
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _maxHeatedCController,
                                focusNode: _maxHeatedCFocus,
                                decoration: const InputDecoration(
                                  labelText: 'Max Heated (°C)',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^-?\d*\.?\d{0,2}'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid temperature';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Georgia',
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: TextFormField(
                                controller: _maxHeatedFController,
                                focusNode: _maxHeatedFFocus,
                                decoration: const InputDecoration(
                                  labelText: 'Max Heated (°F)',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^-?\d*\.?\d{0,2}'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid temperature';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Georgia',
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _fragranceMixingCController,
                                focusNode: _fragranceMixingCFocus,
                                decoration: const InputDecoration(
                                  labelText: 'Fragrance Mixing (°C)',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^-?\d*\.?\d{0,2}'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid temperature';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Georgia',
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: TextFormField(
                                controller: _fragranceMixingFController,
                                focusNode: _fragranceMixingFFocus,
                                decoration: const InputDecoration(
                                  labelText: 'Fragrance Mixing (°F)',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^-?\d*\.?\d{0,2}'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid temperature';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Georgia',
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _pouringCController,
                                focusNode: _pouringCFocus,
                                decoration: const InputDecoration(
                                  labelText: 'Pouring (°C)',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^-?\d*\.?\d{0,2}'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid temperature';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Georgia',
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: TextFormField(
                                controller: _pouringFController,
                                focusNode: _pouringFFocus,
                                decoration: const InputDecoration(
                                  labelText: 'Pouring (°F)',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^-?\d*\.?\d{0,2}'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid temperature';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Georgia',
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _ambientTempCController,
                                focusNode: _ambientTempCFocus,
                                decoration: const InputDecoration(
                                  labelText: 'Ambient Temp (°C)',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^-?\d*\.?\d{0,2}'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid temperature';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Georgia',
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: TextFormField(
                                controller: _ambientTempFController,
                                focusNode: _ambientTempFFocus,
                                decoration: const InputDecoration(
                                  labelText: 'Ambient Temp (°F)',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^-?\d*\.?\d{0,2}'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid temperature';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Georgia',
                                  color: Color(0xFF5D4037),
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
                                builder: (context) => MakingScreen8(
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
