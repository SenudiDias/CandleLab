import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'custom_drawer.dart';
import 'making_screen5.dart';
import 'making_screen6.dart';
import 'making_screen7.dart';
import '../models/candle_data.dart';
import 'dart:async';

class MakingScreen4 extends StatefulWidget {
  final CandleData candleData;

  const MakingScreen4({super.key, required this.candleData});

  @override
  State<MakingScreen4> createState() => _MakingScreen4State();
}

class _MakingScreen4State extends State<MakingScreen4> {
  final _formKey = GlobalKey<FormState>();
  final _numberOfWicksController = TextEditingController();
  final _wickCostController = TextEditingController();
  final _stickerCostController = TextEditingController();
  final _wickTypeController = TextEditingController();

  bool _isContentVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    // Trigger the fade-in animation
    Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isContentVisible = true;
        });
      }
    });
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

  void _saveDataAndNavigate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.candleData.wickDetail = WickDetail(
      numberOfWicks: int.tryParse(_numberOfWicksController.text) ?? 0,
      wickType: _wickTypeController.text,
      wickCost: double.tryParse(_wickCostController.text) ?? 0.0,
      stickerCost: double.tryParse(_stickerCostController.text) ?? 0.0,
    );

    Widget nextScreen;
    if (widget.candleData.isScented == true) {
      nextScreen = MakingScreen5(candleData: widget.candleData);
    } else if (widget.candleData.isColoured == true) {
      nextScreen = MakingScreen6(candleData: widget.candleData);
    } else {
      nextScreen = MakingScreen7(candleData: widget.candleData);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
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
        title: const Text('Making - Wick Details'),
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

                  _buildWickForm(),

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
            color: Theme.of(context).colorScheme.surface, // White background
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

  Widget _buildWickForm() {
    return _buildFormCard(
      title: 'Wick Details',
      child: Column(
        children: [
          _buildTextFormField(
            controller: _numberOfWicksController,
            label: 'Number of Wicks',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildTextFormField(
            controller: _wickTypeController,
            label: 'Wick Type',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: _wickCostController,
                  label: 'Cost of Wick (\$)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextFormField(
                  controller: _stickerCostController,
                  label: 'Cost of Sticker (\$)',
                  keyboardType: TextInputType.number,
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
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : [],
      validator: (value) {
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
