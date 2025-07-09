import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'custom_drawer.dart';
import 'making_screen7.dart';
import '../models/candle_data.dart';

class MakingScreen6 extends StatefulWidget {
  final CandleData candleData;

  const MakingScreen6({super.key, required this.candleData});

  @override
  State<MakingScreen6> createState() => _MakingScreen6State();
}

class _MakingScreen6State extends State<MakingScreen6> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _colourController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  double _percentage = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _updatePercentage();
    _weightController.addListener(_updatePercentage);
  }

  void _initializeData() {
    if (widget.candleData.colourDetail != null) {
      final colour = widget.candleData.colourDetail!;
      _colourController.text = colour.colour;
      _supplierController.text = colour.supplier;
      _weightController.text = colour.weight.toString();
      _costController.text = colour.cost.toString();
      _percentage = colour.percentage;
    }
  }

  void _updatePercentage() {
    setState(() {
      double colourWeight = double.tryParse(_weightController.text) ?? 0.0;
      double totalWaxWeight = widget.candleData.waxDetails.fold(
        0.0,
        (sum, detail) => sum + detail.weight,
      );
      _percentage = totalWaxWeight > 0
          ? (colourWeight / totalWaxWeight) * 100
          : 0.0;

      _percentageController.text = _percentage.toStringAsFixed(2);
    });
  }

  @override
  void dispose() {
    _colourController.dispose();
    _supplierController.dispose();
    _weightController.removeListener(_updatePercentage);
    _weightController.dispose();
    _costController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  void _saveData() {
    widget.candleData.colourDetail = ColourDetail(
      colour: _colourController.text,
      supplier: _supplierController.text,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      percentage: _percentage,
      cost: double.tryParse(_costController.text) ?? 0.0,
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
          'Making - Colour Details',
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
                  'Colour Details',
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
                          controller: _colourController,
                          decoration: const InputDecoration(
                            labelText: 'Colour',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Colour is required';
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
                          controller: _supplierController,
                          decoration: const InputDecoration(
                            labelText: 'Supplier',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Supplier is required';
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
                        TextFormField(
                          controller: _costController,
                          decoration: const InputDecoration(
                            labelText: 'Cost (\$)',
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
                                double.parse(value) < 0) {
                              return 'Invalid cost';
                            }
                            return null;
                          },
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'Georgia',
                            color: Color(0xFF5D4037),
                          ),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MakingScreen7(
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
