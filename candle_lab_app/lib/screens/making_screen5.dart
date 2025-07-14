import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'custom_drawer.dart';
import 'making_screen6.dart';
import 'making_screen7.dart';
import '../models/candle_data.dart';

class MakingScreen5 extends StatefulWidget {
  final CandleData candleData;

  const MakingScreen5({super.key, required this.candleData});

  @override
  State<MakingScreen5> createState() => _MakingScreen5State();
}

class _MakingScreen5State extends State<MakingScreen5> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _newScentTypeController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  String _scentType = 'Seasalt';
  double _percentage = 0.0;
  double _cost = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _updateCalculations();
    _weightController.addListener(_updateCalculations);
    _volumeController.addListener(_updateCalculations);
  }

  void _initializeData() {
    if (widget.candleData.scentDetail != null) {
      final scent = widget.candleData.scentDetail!;
      _scentType = scent.scentType;
      _supplierController.text = scent.supplier;
      _weightController.text = scent.weight.toString();
      _volumeController.text = scent.volume.toString();
      _percentage = scent.percentage;
      _cost = scent.cost;
    }
  }

  void _updateCalculations() {
    setState(() {
      double scentWeight = double.tryParse(_weightController.text) ?? 0.0;
      double totalWaxWeight = widget.candleData.waxDetails.fold(
        0.0,
        (sum, detail) => sum + detail.weight,
      );
      _percentage = totalWaxWeight > 0
          ? (scentWeight / totalWaxWeight) * 100
          : 0.0;
      double volume = double.tryParse(_volumeController.text) ?? 0.0;
      _cost = (10.5 * volume) / 125;

      // Set values in the controllers
      _percentageController.text = _percentage.toStringAsFixed(2);
      _costController.text = _cost.toStringAsFixed(2);
    });
  }

  @override
  void dispose() {
    _supplierController.dispose();
    _weightController.removeListener(_updateCalculations);
    _weightController.dispose();
    _volumeController.removeListener(_updateCalculations);
    _volumeController.dispose();
    _newScentTypeController.dispose();
    _percentageController.dispose();
    _costController.dispose();

    super.dispose();
  }

  void _saveData() {
    widget.candleData.scentDetail = ScentDetail(
      scentType: _scentType,
      supplier: _supplierController.text,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      percentage: _percentage,
      volume: double.tryParse(_volumeController.text) ?? 0.0,
      cost: _cost,
    );
  }

  void _addNewScentType() {
    final newScent = _newScentTypeController.text.trim();
    if (newScent.isNotEmpty &&
        !CandleData.availableScentTypes.contains(newScent)) {
      setState(() {
        CandleData.availableScentTypes.add(newScent);
        _scentType = newScent;
        _newScentTypeController.clear();
      });
    }
  }

  void _deleteScentType(String scentType) {
    if (CandleData.availableScentTypes.length > 1) {
      setState(() {
        if (_scentType == scentType) {
          // Set to a new default before removing
          final newList = CandleData.availableScentTypes
              .where((e) => e != scentType)
              .toList();
          _scentType = newList.first;
        }
        CandleData.availableScentTypes.remove(scentType);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete the last scent type')),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF795548), // Brown
        title: const Text(
          'Making - Scent Details',
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
                  'Scent Details',
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
                        // Dropdown on its own row
                        DropdownButtonFormField<String>(
                          key: ValueKey(
                            CandleData.availableScentTypes.join(),
                          ), // <--- force rebuild
                          value: _scentType,
                          decoration: const InputDecoration(
                            labelText: 'Scent Type',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: CandleData.availableScentTypes.map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    value,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: 'Georgia',
                                      color: Color(0xFF5D4037),
                                    ),
                                  ),
                                  if (value != _scentType)
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () {
                                        _deleteScentType(value);
                                      },
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _scentType = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a scent type';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12.0),

                        // New Scent + Button aligned horizontally
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _newScentTypeController,
                                decoration: const InputDecoration(
                                  labelText: 'New Scent Type',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Georgia',
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            ElevatedButton(
                              onPressed: _addNewScentType,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF795548),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 16.0,
                                ),
                              ),
                              child: const Text(
                                'Add Scent',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Georgia',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _supplierController,
                          decoration: const InputDecoration(
                            labelText: 'Supplier',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
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
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _weightController,
                                decoration: const InputDecoration(
                                  labelText: 'Weight (g)',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null ||
                                      double.parse(value) <= 0) {
                                    return 'Invalid weight';
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
                                controller: _percentageController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Percentage (%)',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Color(0xFFE0E0E0),
                                ),
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
                                controller: _volumeController,
                                decoration: const InputDecoration(
                                  labelText: 'Volume',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null ||
                                      double.parse(value) <= 0) {
                                    return 'Invalid volume';
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
                                controller: _costController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Cost (\$)',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Color(0xFFE0E0E0),
                                ),
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Georgia',
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                            Widget nextScreen;
                            if (widget.candleData.isColoured == true) {
                              nextScreen = MakingScreen6(
                                candleData: widget.candleData,
                              );
                            } else {
                              nextScreen = MakingScreen7(
                                candleData: widget.candleData,
                              );
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => nextScreen,
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
