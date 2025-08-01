import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'custom_drawer.dart';
import 'making_screen4.dart';
import 'making_screen5.dart';
import 'making_screen6.dart';
import 'making_screen7.dart';
import '../models/candle_data.dart';
import '../services/notification_service.dart';
import 'dart:async';

class MakingScreen3 extends StatefulWidget {
  final CandleData candleData;

  const MakingScreen3({super.key, required this.candleData});

  @override
  State<MakingScreen3> createState() => _MakingScreen3State();
}

class _MakingScreen3State extends State<MakingScreen3> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for Container form
  final _numberOfContainersController = TextEditingController();
  final _weightPerCandleController = TextEditingController();
  final _waxDepthController = TextEditingController();
  final _containerDiameterController = TextEditingController();
  final _containerCostController = TextEditingController();
  final _containerSupplierController = TextEditingController();

  // Controllers for Pillar form
  final _numberOfPillarsController = TextEditingController();
  final _pillarWaxWeightController = TextEditingController();
  final _pillarHeightController = TextEditingController();
  final _largestWidthController = TextEditingController();
  final _smallestWidthController = TextEditingController();

  // Controllers for Mould form
  final _mouldNumberController = TextEditingController();

  // State variables
  bool _containerHeated = false;
  String _mouldType = 'Melt';
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
    // Initialize from existing data if available
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
    } else if (widget.candleData.candleType == 'Container') {
      double totalWaxWeight = widget.candleData.waxDetails.fold(
        0.0,
        (sum, detail) => sum + detail.weight,
      );
      _weightPerCandleController.text = totalWaxWeight.toStringAsFixed(2);
    }

    if (widget.candleData.pillarDetail != null) {
      final pillar = widget.candleData.pillarDetail!;
      _numberOfPillarsController.text = pillar.numberOfPillars.toString();
      _pillarWaxWeightController.text = pillar.waxWeight.toString();
      _pillarHeightController.text = pillar.height.toString();
      _largestWidthController.text = pillar.largestWidth.toString();
      _smallestWidthController.text = pillar.smallestWidth.toString();
    } else if (widget.candleData.candleType == 'Pillar') {
      double totalWaxWeight = widget.candleData.waxDetails.fold(
        0.0,
        (sum, detail) => sum + detail.weight,
      );
      _pillarWaxWeightController.text = totalWaxWeight.toStringAsFixed(2);
    }

    if (widget.candleData.mouldDetail != null) {
      final mould = widget.candleData.mouldDetail!;
      _mouldNumberController.text = mould.number.toString();
      _mouldType = mould.type;
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
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

  void _saveDataAndNavigate() {
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do not proceed
    }

    // Save the data based on the candle type
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

    // Determine the next screen based on the candle properties
    Widget nextScreen;
    if (widget.candleData.isWicked == true) {
      nextScreen = MakingScreen4(candleData: widget.candleData);
    } else if (widget.candleData.isScented == true) {
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
        title: const Text('Making - Candle Details'),
        leading: Builder(
          builder: (context) => StreamBuilder<int>(
            stream: NotificationService.unreadCountStream,
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
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

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _buildFormContent(),
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

  Widget _buildFormContent() {
    switch (widget.candleData.candleType) {
      case 'Container':
        return _buildContainerForm(key: const ValueKey('container'));
      case 'Pillar':
        return _buildPillarForm(key: const ValueKey('pillar'));
      case 'Mould':
        return _buildMouldForm(key: const ValueKey('mould'));
      default:
        return Container(key: const ValueKey('empty'));
    }
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
            // UPDATED: Using the theme's surface color (white) instead of pink
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

  Widget _buildContainerForm({Key? key}) {
    return _buildFormCard(
      title: 'Container Details',
      child: Column(
        key: key,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: _numberOfContainersController,
                  label: 'No. of Containers',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextFormField(
                  controller: _weightPerCandleController,
                  label: 'Weight/candle (g)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: _waxDepthController,
                  label: 'Wax Depth (mm)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextFormField(
                  controller: _containerDiameterController,
                  label: 'Container Diameter (mm)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: _containerCostController,
                  label: 'Cost (\$)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextFormField(
                  controller: _containerSupplierController,
                  label: 'Supplier',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Container Heated:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(width: 10),
              Switch(
                value: _containerHeated,
                onChanged: (value) => setState(() => _containerHeated = value),
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              Text(
                _containerHeated ? 'Yes' : 'No',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillarForm({Key? key}) {
    return _buildFormCard(
      title: 'Pillar Details',
      child: Column(
        key: key,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: _numberOfPillarsController,
                  label: 'No. of Pillars',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextFormField(
                  controller: _pillarWaxWeightController,
                  label: 'Wax Weight (g)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextFormField(
            controller: _pillarHeightController,
            label: 'Height (mm)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: _largestWidthController,
                  label: 'Largest Width (mm)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextFormField(
                  controller: _smallestWidthController,
                  label: 'Smallest Width (mm)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMouldForm({Key? key}) {
    return _buildFormCard(
      title: 'Mould Details',
      child: Column(
        key: key,
        children: [
          // UPDATED: Dropdown now uses the global theme
          DropdownButtonFormField<String>(
            value: _mouldType,
            decoration: const InputDecoration(labelText: 'Type'),
            items: ['Melt', 'Wicked'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? newValue) =>
                setState(() => _mouldType = newValue!),
            validator: (value) => (value == null || value.isEmpty)
                ? 'Please select a type'
                : null,
          ),
          const SizedBox(height: 12),
          _buildTextFormField(
            controller: _mouldNumberController,
            label: 'Number',
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
  }) {
    // UPDATED: This now fully inherits its style from the global theme
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
