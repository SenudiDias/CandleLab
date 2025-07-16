import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'custom_drawer.dart';
import 'making_screen6.dart';
import 'making_screen7.dart';
import '../models/candle_data.dart';
import 'dart:async';

class MakingScreen5 extends StatefulWidget {
  final CandleData candleData;

  const MakingScreen5({super.key, required this.candleData});

  @override
  State<MakingScreen5> createState() => _MakingScreen5State();
}

class _MakingScreen5State extends State<MakingScreen5> {
  final _formKey = GlobalKey<FormState>();
  final _supplierController = TextEditingController();
  final _weightController = TextEditingController();
  final _volumeController = TextEditingController();
  final _newScentTypeController = TextEditingController();
  final _percentageController = TextEditingController();
  final _costController = TextEditingController();

  String? _scentType;
  bool _isContentVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _updateCalculations();
    _weightController.addListener(_updateCalculations);
    _volumeController.addListener(_updateCalculations);

    Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isContentVisible = true;
        });
      }
    });
  }

  void _initializeData() {
    if (widget.candleData.scentDetail != null) {
      final scent = widget.candleData.scentDetail!;
      _scentType = scent.scentType;
      _supplierController.text = scent.supplier;
      _weightController.text = scent.weight.toString();
      _volumeController.text = scent.volume.toString();
    } else {
      // Set a default scent type if the list is not empty and no data exists
      if (CandleData.availableScentTypes.isNotEmpty) {
        _scentType = CandleData.availableScentTypes.first;
      }
    }
  }

  void _updateCalculations() {
    double scentWeight = double.tryParse(_weightController.text) ?? 0.0;
    double totalWaxWeight = widget.candleData.waxDetails.fold(
      0.0,
      (sum, detail) => sum + detail.weight,
    );
    double percentage = totalWaxWeight > 0
        ? (scentWeight / (scentWeight + totalWaxWeight)) * 100
        : 0.0;

    double volume = double.tryParse(_volumeController.text) ?? 0.0;
    double cost = (10.5 * volume) / 125; // Formula from original code

    if (mounted) {
      setState(() {
        _percentageController.text = percentage.toStringAsFixed(2);
        _costController.text = cost.toStringAsFixed(2);
      });
    }
  }

  @override
  void dispose() {
    _weightController.removeListener(_updateCalculations);
    _volumeController.removeListener(_updateCalculations);
    _supplierController.dispose();
    _weightController.dispose();
    _volumeController.dispose();
    _newScentTypeController.dispose();
    _percentageController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _saveDataAndNavigate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.candleData.scentDetail = ScentDetail(
      scentType: _scentType ?? '',
      supplier: _supplierController.text,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      percentage: double.tryParse(_percentageController.text) ?? 0.0,
      volume: double.tryParse(_volumeController.text) ?? 0.0,
      cost: double.tryParse(_costController.text) ?? 0.0,
    );

    Widget nextScreen;
    if (widget.candleData.isColoured == true) {
      nextScreen = MakingScreen6(candleData: widget.candleData);
    } else {
      nextScreen = MakingScreen7(candleData: widget.candleData);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
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
        CandleData.availableScentTypes.remove(scentType);
        if (_scentType == scentType) {
          _scentType = CandleData.availableScentTypes.first;
        }
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Making - Scent Details'),
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
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('h:mm a').format(now),
                      style: const TextStyle(
                        fontSize: 18.0,
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

                  _buildScentForm(),

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
                              fontSize: 22,
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

  Widget _buildScentForm() {
    return _buildFormCard(
      title: 'Scent Details',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey(
              CandleData.availableScentTypes.length.toString() +
                  (_scentType ?? ''),
            ),
            value: _scentType,
            decoration: const InputDecoration(labelText: 'Scent Type'),
            items: CandleData.availableScentTypes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(value),
                    if (value != _scentType)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 22,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => _deleteScentType(value),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _scentType = newValue;
              });
            },
            validator: (value) => (value == null || value.isEmpty)
                ? 'Please select a scent'
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: _newScentTypeController,
                  label: 'New Scent Type',
                  isOptional: true,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _addNewScentType,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('Add Scent'),
              ),
            ],
          ),
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
          Row(
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: _volumeController,
                  label: 'Volume',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextFormField(
                  controller: _costController,
                  label: 'Cost (\$)',
                  readOnly: true,
                ),
              ),
            ],
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
    bool isOptional = false,
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
        if (!isOptional && (value == null || value.isEmpty)) return 'Required';
        if (keyboardType == TextInputType.number) {
          final val = double.tryParse(value ?? '');
          if (val == null || val < 0) return 'Invalid';
        }
        return null;
      },
    );
  }
}
