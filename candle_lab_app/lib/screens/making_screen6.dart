import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'custom_drawer.dart';
import 'making_screen7.dart';
import '../models/candle_data.dart';
import 'dart:async';

class MakingScreen6 extends StatefulWidget {
  final CandleData candleData;

  const MakingScreen6({super.key, required this.candleData});

  @override
  State<MakingScreen6> createState() => _MakingScreen6State();
}

class _MakingScreen6State extends State<MakingScreen6> {
  final _formKey = GlobalKey<FormState>();
  final _colourController = TextEditingController();
  final _supplierController = TextEditingController();
  final _weightController = TextEditingController();
  final _costController = TextEditingController();
  final _percentageController = TextEditingController();

  bool _isContentVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _updatePercentage();
    _weightController.addListener(_updatePercentage);

    Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isContentVisible = true;
        });
      }
    });
  }

  void _initializeData() {
    if (widget.candleData.colourDetail != null) {
      final colour = widget.candleData.colourDetail!;
      _colourController.text = colour.colour;
      _supplierController.text = colour.supplier;
      _weightController.text = colour.weight.toString();
      _costController.text = colour.cost.toString();
    }
  }

  void _updatePercentage() {
    double colourWeight = double.tryParse(_weightController.text) ?? 0.0;
    double scentWeight = widget.candleData.scentDetail?.weight ?? 0.0;
    double totalWaxWeight = widget.candleData.waxDetails.fold(
      0.0,
      (sum, detail) => sum + detail.weight,
    );
    double percentage = totalWaxWeight > 0
        ? (colourWeight / (scentWeight + colourWeight + totalWaxWeight)) * 100
        : 0.0;

    if (mounted) {
      setState(() {
        _percentageController.text = percentage.toStringAsFixed(2);
      });
    }
  }

  @override
  void dispose() {
    _weightController.removeListener(_updatePercentage);
    _colourController.dispose();
    _supplierController.dispose();
    _weightController.dispose();
    _costController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  void _saveDataAndNavigate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.candleData.colourDetail = ColourDetail(
      colour: _colourController.text,
      supplier: _supplierController.text,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      percentage: double.tryParse(_percentageController.text) ?? 0.0,
      cost: double.tryParse(_costController.text) ?? 0.0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MakingScreen7(candleData: widget.candleData),
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
        title: const Text('Making - Colour Details'),
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

                  _buildColourForm(),

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

  Widget _buildColourForm() {
    return _buildFormCard(
      title: 'Colour Details',
      child: Column(
        children: [
          _buildTextFormField(controller: _colourController, label: 'Colour'),
          const SizedBox(height: 12),
          _buildTextFormField(
            controller: _supplierController,
            label: 'Supplier',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: _weightController,
                  label: 'Weight (g)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextFormField(
                  controller: _percentageController,
                  label: 'Percentage (%)',
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextFormField(
            controller: _costController,
            label: 'Cost (\$)',
            keyboardType: TextInputType.number,
          ),
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
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
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
