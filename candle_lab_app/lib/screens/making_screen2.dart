import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'custom_drawer.dart';
import 'making_screen3.dart';
import '../models/candle_data.dart'; // Import shared models

class MakingScreen2 extends StatefulWidget {
  final CandleData candleData;

  const MakingScreen2({super.key, required this.candleData});

  @override
  State<MakingScreen2> createState() => _MakingScreen2State();
}

class _MakingScreen2State extends State<MakingScreen2> {
  final _formKey = GlobalKey<FormState>();
  late List<WaxDetail> waxDetails;
  late Map<String, TextEditingController> productControllers;
  late Map<String, TextEditingController> supplierControllers;
  late Map<String, TextEditingController> weightControllers;
  late Map<String, TextEditingController> costPerKgControllers;

  @override
  void initState() {
    super.initState();
    _initializeWaxDetails();
    _initializeControllers();
    _calculateValues();
  }

  void _initializeWaxDetails() {
    waxDetails = widget.candleData.waxTypes.map((waxType) {
      final existing = widget.candleData.waxDetails.firstWhere(
        (d) => d.waxType == waxType,
        orElse: () => WaxDetail(waxType: waxType),
      );
      return WaxDetail(
        waxType: waxType,
        product: existing.product,
        supplier: existing.supplier,
        weight: existing.weight,
        percentage: existing.percentage,
        costPerKg: existing.costPerKg,
        cost: existing.cost,
      );
    }).toList();
  }

  void _initializeControllers() {
    productControllers = {};
    supplierControllers = {};
    weightControllers = {};
    costPerKgControllers = {};

    for (String waxType in widget.candleData.waxTypes) {
      final detail = waxDetails.firstWhere((d) => d.waxType == waxType);
      productControllers[waxType] = TextEditingController(text: detail.product);
      supplierControllers[waxType] = TextEditingController(
        text: detail.supplier,
      );
      weightControllers[waxType] = TextEditingController(
        text: detail.weight.toString(),
      );
      costPerKgControllers[waxType] = TextEditingController(
        text: detail.costPerKg.toString(),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in productControllers.values) {
      controller.dispose();
    }
    for (var controller in supplierControllers.values) {
      controller.dispose();
    }
    for (var controller in weightControllers.values) {
      controller.dispose();
    }
    for (var controller in costPerKgControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double get totalWeight {
    return waxDetails.fold(0.0, (sum, detail) => sum + detail.weight);
  }

  double get totalCost {
    return waxDetails.fold(0.0, (sum, detail) => sum + detail.cost);
  }

  void _calculateValues() {
    setState(() {
      double total = totalWeight;
      for (var detail in waxDetails) {
        detail.percentage = total > 0 ? (detail.weight / total) * 100 : 0.0;
        detail.cost = detail.costPerKg * (detail.weight / 1000);
      }
    });
  }

  void _updateWaxDetail(String waxType, String field, String value) {
    var detail = waxDetails.firstWhere((d) => d.waxType == waxType);

    switch (field) {
      case 'product':
        detail.product = value;
        break;
      case 'supplier':
        detail.supplier = value;
        break;
      case 'weight':
        detail.weight = double.tryParse(value) ?? 0.0;
        break;
      case 'costPerKg':
        detail.costPerKg = double.tryParse(value) ?? 0.0;
        break;
    }

    _calculateValues();
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
          'Making - Wax Details',
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
                  child: Text(
                    'Sample: ${widget.candleData.sampleName}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Georgia',
                      color: Color(0xFF5D4037),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Wax Details',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                    color: Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 16.0),
                ...waxDetails.map((detail) => _buildWaxDetailCard(detail)),
                const SizedBox(height: 20.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF795548).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: const Color(0xFF795548),
                      width: 2.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Weight: ${totalWeight.toStringAsFixed(2)} g',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Georgia',
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Total Cost: ${totalCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Georgia',
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ],
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
                            widget.candleData.waxDetails = waxDetails;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MakingScreen3(
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

  Widget _buildWaxDetailCard(WaxDetail detail) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFF795548),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                detail.waxType,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Georgia',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16.0),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: productControllers[detail.waxType],
                        decoration: const InputDecoration(
                          labelText: 'Product',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Georgia',
                          color: Color(0xFF5D4037),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        onChanged: (value) =>
                            _updateWaxDetail(detail.waxType, 'product', value),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: TextFormField(
                        controller: supplierControllers[detail.waxType],
                        decoration: const InputDecoration(
                          labelText: 'Supplier',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Georgia',
                          color: Color(0xFF5D4037),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        onChanged: (value) =>
                            _updateWaxDetail(detail.waxType, 'supplier', value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: weightControllers[detail.waxType],
                        decoration: const InputDecoration(
                          labelText: 'Weight (g)',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Georgia',
                          color: Color(0xFF5D4037),
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
                        onChanged: (value) =>
                            _updateWaxDetail(detail.waxType, 'weight', value),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: TextFormField(
                        controller: costPerKgControllers[detail.waxType],
                        decoration: const InputDecoration(
                          labelText: 'Cost per 1 kg',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Georgia',
                          color: Color(0xFF5D4037),
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
                            return 'Invalid cost';
                          }
                          return null;
                        },
                        onChanged: (value) => _updateWaxDetail(
                          detail.waxType,
                          'costPerKg',
                          value,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Percentage (%)',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                                fontFamily: 'Georgia',
                              ),
                            ),
                            Text(
                              '${detail.percentage.toStringAsFixed(2)}%',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D4037),
                                fontFamily: 'Georgia',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cost',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                                fontFamily: 'Georgia',
                              ),
                            ),
                            Text(
                              detail.cost.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D4037),
                                fontFamily: 'Georgia',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
