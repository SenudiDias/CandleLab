import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'custom_drawer.dart';
import 'making_screen4.dart';
import '../models/candle_data.dart'; // Import shared models

class MakingScreen3 extends StatefulWidget {
  final CandleData candleData;

  const MakingScreen3({super.key, required this.candleData});

  @override
  State<MakingScreen3> createState() => _MakingScreen3State();
}

class _MakingScreen3State extends State<MakingScreen3> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numberOfContainersController =
      TextEditingController();
  final TextEditingController _weightPerCandleController =
      TextEditingController();
  final TextEditingController _waxDepthController = TextEditingController();
  final TextEditingController _containerDiameterController =
      TextEditingController();
  final TextEditingController _containerCostController =
      TextEditingController();
  final TextEditingController _containerSupplierController =
      TextEditingController();
  final TextEditingController _numberOfPillarsController =
      TextEditingController();
  final TextEditingController _pillarWaxWeightController =
      TextEditingController();
  final TextEditingController _pillarHeightController = TextEditingController();
  final TextEditingController _largestWidthController = TextEditingController();
  final TextEditingController _smallestWidthController =
      TextEditingController();
  final TextEditingController _mouldNumberController = TextEditingController();

  bool _containerHeated = false;
  String _mouldType = 'Melt';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.candleData.containerDetail != null) {
      final container = widget.candleData.containerDetail!;
      _numberOfContainersController.text = container.numberOfContainers
          .toString();
      _weightPerCandleController.text = container.weightPerCandle.toString();
      _waxDepthController.text = container.waxDepth.toString();
      _containerDiameterController.text = container.containerDiameter
          .toString();
      _containerCostController.text = container.cost.toString();
      _containerSupplierController.text = container.supplier;
      _containerHeated = container.containerHeated;
    } else {
      double totalWaxWeight = widget.candleData.waxDetails.fold(
        0.0,
        (sum, detail) => sum + detail.weight,
      );
      _weightPerCandleController.text = totalWaxWeight.toString();
    }

    if (widget.candleData.pillarDetail != null) {
      final pillar = widget.candleData.pillarDetail!;
      _numberOfPillarsController.text = pillar.numberOfPillars.toString();
      _pillarWaxWeightController.text = pillar.waxWeight.toString();
      _pillarHeightController.text = pillar.height.toString();
      _largestWidthController.text = pillar.largestWidth.toString();
      _smallestWidthController.text = pillar.smallestWidth.toString();
    } else {
      double totalWaxWeight = widget.candleData.waxDetails.fold(
        0.0,
        (sum, detail) => sum + detail.weight,
      );
      _pillarWaxWeightController.text = totalWaxWeight.toString();
    }

    if (widget.candleData.mouldDetail != null) {
      final mould = widget.candleData.mouldDetail!;
      _mouldNumberController.text = mould.number.toString();
      _mouldType = mould.type;
    }
  }

  @override
  void dispose() {
    _numberOfContainersController.dispose();
    _weightPerCandleController.dispose();
    _waxDepthController.dispose();
    _containerDiameterController.dispose();
    _containerCostController.dispose();
    _containerSupplierController.dispose();
    _numberOfPillarsController.dispose();
    _pillarWaxWeightController.dispose();
    _pillarHeightController.dispose();
    _largestWidthController.dispose();
    _smallestWidthController.dispose();
    _mouldNumberController.dispose();
    super.dispose();
  }

  void _saveData() {
    if (widget.candleData.candleType == 'Container') {
      widget.candleData.containerDetail = ContainerDetail(
        numberOfContainers:
            int.tryParse(_numberOfContainersController.text) ?? 0,
        weightPerCandle:
            double.tryParse(_weightPerCandleController.text) ?? 0.0,
        waxDepth: double.tryParse(_waxDepthController.text) ?? 0.0,
        containerDiameter:
            double.tryParse(_containerDiameterController.text) ?? 0.0,
        cost: double.tryParse(_containerCostController.text) ?? 0.0,
        containerHeated: _containerHeated,
        supplier: _containerSupplierController.text,
      );
    } else if (widget.candleData.candleType == 'Pillar') {
      widget.candleData.pillarDetail = PillarDetail(
        numberOfPillars: int.tryParse(_numberOfPillarsController.text) ?? 0,
        waxWeight: double.tryParse(_pillarWaxWeightController.text) ?? 0.0,
        height: double.tryParse(_pillarHeightController.text) ?? 0.0,
        largestWidth: double.tryParse(_largestWidthController.text) ?? 0.0,
        smallestWidth: double.tryParse(_smallestWidthController.text) ?? 0.0,
      );
    } else if (widget.candleData.candleType == 'Mould') {
      widget.candleData.mouldDetail = MouldDetail(
        type: _mouldType,
        number: int.tryParse(_mouldNumberController.text) ?? 0,
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
        backgroundColor: const Color(0xFF795548),
        title: const Text(
          'Making - Candle Details',
          style: TextStyle(fontFamily: 'Georgia', color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
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
                if (widget.candleData.candleType == 'Container') ...[
                  _buildContainerForm(),
                ] else if (widget.candleData.candleType == 'Pillar') ...[
                  _buildPillarForm(),
                ] else if (widget.candleData.candleType == 'Mould') ...[
                  _buildMouldForm(),
                ],
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
                                builder: (context) => MakingScreen4(
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

  Widget _buildContainerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Container Details',
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
                        controller: _numberOfContainersController,
                        decoration: const InputDecoration(
                          labelText: 'No. of Containers',
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
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: TextFormField(
                        controller: _weightPerCandleController,
                        decoration: const InputDecoration(
                          labelText: 'Weight/candle (g)',
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _waxDepthController,
                        decoration: const InputDecoration(
                          labelText: 'Wax Depth (mm)',
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
                            return 'Invalid depth';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: TextFormField(
                        controller: _containerDiameterController,
                        decoration: const InputDecoration(
                          labelText: 'Container Diameter (mm)',
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
                            return 'Invalid diameter';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _containerCostController,
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
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: TextFormField(
                        controller: _containerSupplierController,
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    const Text(
                      'Container Heated: ',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Georgia',
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    Switch(
                      value: _containerHeated,
                      onChanged: (value) {
                        setState(() {
                          _containerHeated = value;
                        });
                      },
                      activeColor: const Color(0xFF795548),
                    ),
                    Text(
                      _containerHeated ? 'Yes' : 'No',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Georgia',
                        color: Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPillarForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pillar Details',
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
                        controller: _numberOfPillarsController,
                        decoration: const InputDecoration(
                          labelText: 'No. of Pillars',
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
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: TextFormField(
                        controller: _pillarWaxWeightController,
                        decoration: const InputDecoration(
                          labelText: 'Wax Weight (g)',
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _pillarHeightController,
                  decoration: const InputDecoration(
                    labelText: 'Height (mm)',
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
                      return 'Invalid height';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _largestWidthController,
                        decoration: const InputDecoration(
                          labelText: 'Largest Width (mm)',
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
                            return 'Invalid width';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: TextFormField(
                        controller: _smallestWidthController,
                        decoration: const InputDecoration(
                          labelText: 'Smallest Width (mm)',
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
                            return 'Invalid width';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMouldForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mould Details',
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
                DropdownButtonFormField<String>(
                  value: _mouldType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: ['Melt', 'Wicked'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _mouldType = newValue!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _mouldNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Number',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
