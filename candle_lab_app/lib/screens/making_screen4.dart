import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'custom_drawer.dart';
import 'making_screen5.dart';
import 'making_screen6.dart';
import 'making_screen7.dart';
import '../models/candle_data.dart';

class MakingScreen4 extends StatefulWidget {
  final CandleData candleData;

  const MakingScreen4({super.key, required this.candleData});

  @override
  State<MakingScreen4> createState() => _MakingScreen4State();
}

class _MakingScreen4State extends State<MakingScreen4> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numberOfWicksController =
      TextEditingController();
  final TextEditingController _wickCostController = TextEditingController();
  final TextEditingController _stickerCostController = TextEditingController();
  final TextEditingController _wickTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.candleData.wickDetail != null) {
      final wick = widget.candleData.wickDetail!;
      _numberOfWicksController.text = wick.numberOfWicks.toString();
      _wickTypeController.text = wick.wickType;
      _wickCostController.text = wick.wickCost.toString();
      _stickerCostController.text = wick.stickerCost.toString();
    }
  }

  @override
  void dispose() {
    _numberOfWicksController.dispose();
    _wickCostController.dispose();
    _stickerCostController.dispose();
    _wickTypeController.dispose();
    super.dispose();
  }

  void _saveData() {
    widget.candleData.wickDetail = WickDetail(
      numberOfWicks: int.tryParse(_numberOfWicksController.text) ?? 0,
      wickType: _wickTypeController.text,
      wickCost: double.tryParse(_wickCostController.text) ?? 0.0,
      stickerCost: double.tryParse(_stickerCostController.text) ?? 0.0,
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
          'Making - Wick Details',
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
                  'Wick Details',
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
                          controller: _numberOfWicksController,
                          decoration: const InputDecoration(
                            labelText: 'Number of Wicks',
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
                            if (int.tryParse(value) == null ||
                                int.parse(value) <= 0) {
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
                          controller: _wickTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Wick Type',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Wick type is required';
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
                                controller: _wickCostController,
                                decoration: const InputDecoration(
                                  labelText: 'Cost of Wick (\$)',
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
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: TextFormField(
                                controller: _stickerCostController,
                                decoration: const InputDecoration(
                                  labelText: 'Cost of Sticker (\$)',
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
                            if (widget.candleData.isScented == true) {
                              nextScreen = MakingScreen5(
                                candleData: widget.candleData,
                              );
                            } else if (widget.candleData.isColoured == true) {
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
