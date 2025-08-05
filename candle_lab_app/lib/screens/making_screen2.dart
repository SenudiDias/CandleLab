import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'custom_drawer.dart';
import 'making_screen3.dart';
import '../models/candle_data.dart';

import 'dart:async';
import '../services/notification_service.dart';

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

  // For fade-in animation
  bool _isContentVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeWaxDetails();
    _initializeControllers();
    _calculateValues();

    // Trigger the fade-in animation
    Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isContentVisible = true;
        });
      }
    });
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
        text: detail.weight == 0.0 ? '' : detail.weight.toString(),
      );
      costPerKgControllers[waxType] = TextEditingController(
        text: detail.costPerKg == 0.0 ? '' : detail.costPerKg.toString(),
      );
    }
  }

  @override
  void dispose() {
    productControllers.values.forEach((controller) => controller.dispose());
    supplierControllers.values.forEach((controller) => controller.dispose());
    weightControllers.values.forEach((controller) => controller.dispose());
    costPerKgControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  double get totalWeight =>
      waxDetails.fold(0.0, (sum, detail) => sum + detail.weight);
  double get totalCost =>
      waxDetails.fold(0.0, (sum, detail) => sum + detail.cost);

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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Reusable decoration with shadow from global theme
    final cardDecoration = BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.07),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

    return Scaffold(
      // All colors and fonts are now inherited from the global theme in main.dart
      appBar: AppBar(
        title: const Text('Making - Wax Details'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: StreamBuilder<int>(
              stream: NotificationService.unreadCountStream,
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;
                return Stack(
                  children: [
                    const Icon(Icons.menu, color: Colors.white),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
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
                    child: Text(
                      'Sample Name: ${widget.candleData.sampleName}',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Text('Wax Details', style: textTheme.titleLarge),
                  const SizedBox(height: 16.0),
                  ...waxDetails.map(
                    (detail) => _buildWaxDetailCard(detail, cardDecoration),
                  ),
                  const SizedBox(height: 24.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Weight: ${totalWeight.toStringAsFixed(2)} g',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Total Cost: ${totalCost.toStringAsFixed(2)}',
                          style: textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
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
                          // Style is inherited from theme
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

  Widget _buildWaxDetailCard(WaxDetail detail, BoxDecoration decoration) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: decoration,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                detail.waxType,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildTextFormField(
              controller: productControllers[detail.waxType]!,
              label: 'Product',
              onChanged: (value) =>
                  _updateWaxDetail(detail.waxType, 'product', value),
            ),
            const SizedBox(height: 12.0),
            _buildTextFormField(
              controller: supplierControllers[detail.waxType]!,
              label: 'Supplier',
              onChanged: (value) =>
                  _updateWaxDetail(detail.waxType, 'supplier', value),
            ),
            const SizedBox(height: 12.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: weightControllers[detail.waxType]!,
                    label: 'Weight (g)',
                    hint: '0.0',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    onChanged: (value) =>
                        _updateWaxDetail(detail.waxType, 'weight', value),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0)
                        return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildTextFormField(
                    controller: costPerKgControllers[detail.waxType]!,
                    label: 'Cost per 1 kg',
                    hint: '0.0',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    onChanged: (value) =>
                        _updateWaxDetail(detail.waxType, 'costPerKg', value),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0)
                        return 'Invalid';
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
                  child: _buildInfoBox(
                    'Percentage',
                    '${detail.percentage.toStringAsFixed(2)}%',
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildInfoBox('Cost', detail.cost.toStringAsFixed(2)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for text form fields to reduce duplication
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
      style: Theme.of(context).textTheme.bodyLarge,
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) return 'Required';
            return null;
          },
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }

  // Helper widget for the grey info boxes
  Widget _buildInfoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
