import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_drawer.dart';
import '../models/candle_data.dart';
import '../services/firestore_service.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _selectedType;
  double _meltPercentage = 0.0;
  double _meltTime = 0.0;
  double _meltDepth = 0.0;
  double _scentDistance = 0.0;
  String? _scentThrow;
  String? _sizeCategory;

  final List<String> _candleTypes = [
    'Container',
    'Pillar',
    'Mould',
    'Free pour',
  ];
  final List<String> _scentThrowOptions = [
    'Strong',
    'Moderate',
    'Weak',
    'No scent',
  ];
  final List<String> _sizeCategories = [
    '0-50g',
    '51-100g',
    '101-150g',
    '151-200g',
    '201-300g',
    '301-400g',
    '401-500g',
    '501-700g',
    '701-1000g',
  ];

  Stream<DateTime> _dateTimeStream() async* {
    while (true) {
      yield DateTime.now();
      await Future.delayed(const Duration(minutes: 1));
    }
  }

  void _showCandleDetails(BuildContext context, CandleData candle) {
    showDialog(
      context: context,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: colorScheme.background,
          title: Text(
            candle.sampleName ?? 'Unnamed Sample',
            style: textTheme.titleLarge?.copyWith(
              color: const Color(0xFF5D4037),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID', candle.id ?? 'N/A', textTheme),
                _buildDetailRow('Type', candle.candleType ?? 'N/A', textTheme),
                _buildDetailRow(
                  'Wax Types',
                  candle.waxTypes.join(', '),
                  textTheme,
                ),
                _buildDetailRow(
                  'Wicked',
                  candle.isWicked?.toString() ?? 'N/A',
                  textTheme,
                ),
                _buildDetailRow(
                  'Scented',
                  candle.isScented.toString(),
                  textTheme,
                ),
                _buildDetailRow(
                  'Coloured',
                  candle.isColoured.toString(),
                  textTheme,
                ),
                _buildDetailRow(
                  'Total Cost',
                  '\$${candle.totalCost?.toStringAsFixed(2) ?? 'N/A'}',
                  textTheme,
                ),
                _buildDetailRow(
                  'Created At',
                  candle.createdAt != null
                      ? DateFormat('MMM d, yyyy').format(candle.createdAt!)
                      : 'N/A',
                  textTheme,
                ),
                if (candle.waxDetails.isNotEmpty)
                  ...candle.waxDetails.asMap().entries.map(
                    (entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wax Detail ${entry.key + 1}',
                          style: textTheme.titleMedium,
                        ),
                        _buildDetailRow('Type', entry.value.waxType, textTheme),
                        _buildDetailRow(
                          'Product',
                          entry.value.product,
                          textTheme,
                        ),
                        _buildDetailRow(
                          'Supplier',
                          entry.value.supplier,
                          textTheme,
                        ),
                        _buildDetailRow(
                          'Weight',
                          '${entry.value.weight}g',
                          textTheme,
                        ),
                        _buildDetailRow(
                          'Percentage',
                          '${entry.value.percentage}%',
                          textTheme,
                        ),
                        _buildDetailRow(
                          'Cost per Kg',
                          '\$${entry.value.costPerKg}',
                          textTheme,
                        ),
                        _buildDetailRow(
                          'Cost',
                          '\$${entry.value.cost}',
                          textTheme,
                        ),
                      ],
                    ),
                  ),
                if (candle.containerDetail != null) ...[
                  Text('Container Detail', style: textTheme.titleMedium),
                  _buildDetailRow(
                    'Number of Containers',
                    candle.containerDetail!.numberOfContainers.toString(),
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Weight per Candle',
                    '${candle.containerDetail!.weightPerCandle}g',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Wax Depth',
                    '${candle.containerDetail!.waxDepth}mm',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Container Diameter',
                    '${candle.containerDetail!.containerDiameter}mm',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Cost',
                    '\$${candle.containerDetail!.cost}',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Heated',
                    candle.containerDetail!.containerHeated.toString(),
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Supplier',
                    candle.containerDetail!.supplier,
                    textTheme,
                  ),
                ],
                if (candle.pillarDetail != null) ...[
                  Text('Pillar Detail', style: textTheme.titleMedium),
                  _buildDetailRow(
                    'Number of Pillars',
                    candle.pillarDetail!.numberOfPillars.toString(),
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Wax Weight',
                    '${candle.pillarDetail!.waxWeight}g',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Height',
                    '${candle.pillarDetail!.height}mm',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Largest Width',
                    '${candle.pillarDetail!.largestWidth}mm',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Smallest Width',
                    '${candle.pillarDetail!.smallestWidth}mm',
                    textTheme,
                  ),
                ],
                if (candle.mouldDetail != null) ...[
                  Text('Mould Detail', style: textTheme.titleMedium),
                  _buildDetailRow('Type', candle.mouldDetail!.type, textTheme),
                  _buildDetailRow(
                    'Number',
                    candle.mouldDetail!.number.toString(),
                    textTheme,
                  ),
                ],
                if (candle.wickDetail != null) ...[
                  Text('Wick Detail', style: textTheme.titleMedium),
                  _buildDetailRow(
                    'Number of Wicks',
                    candle.wickDetail!.numberOfWicks.toString(),
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Wick Type',
                    candle.wickDetail!.wickType,
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Wick Cost',
                    '\$${candle.wickDetail!.wickCost}',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Sticker Cost',
                    '\$${candle.wickDetail!.stickerCost}',
                    textTheme,
                  ),
                ],
                if (candle.scentDetail != null) ...[
                  Text('Scent Detail', style: textTheme.titleMedium),
                  _buildDetailRow(
                    'Scent Type',
                    candle.scentDetail!.scentType,
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Supplier',
                    candle.scentDetail!.supplier,
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Weight',
                    '${candle.scentDetail!.weight}g',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Percentage',
                    '${candle.scentDetail!.percentage}%',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Volume',
                    '${candle.scentDetail!.volume}ml',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Cost',
                    '\$${candle.scentDetail!.cost}',
                    textTheme,
                  ),
                ],
                if (candle.colourDetail != null) ...[
                  Text('Colour Detail', style: textTheme.titleMedium),
                  _buildDetailRow(
                    'Colour',
                    candle.colourDetail!.colour,
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Supplier',
                    candle.colourDetail!.supplier,
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Weight',
                    '${candle.colourDetail!.weight}g',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Percentage',
                    '${candle.colourDetail!.percentage}%',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Cost',
                    '\$${candle.colourDetail!.cost}',
                    textTheme,
                  ),
                ],
                if (candle.temperatureDetail != null) ...[
                  Text('Temperature Detail', style: textTheme.titleMedium),
                  _buildDetailRow(
                    'Max Heated (C)',
                    '${candle.temperatureDetail!.maxHeatedC}°C',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Max Heated (F)',
                    '${candle.temperatureDetail!.maxHeatedF}°F',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Fragrance Mixing (C)',
                    '${candle.temperatureDetail!.fragranceMixingC}°C',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Fragrance Mixing (F)',
                    '${candle.temperatureDetail!.fragranceMixingF}°F',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Pouring (C)',
                    '${candle.temperatureDetail!.pouringC}°C',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Pouring (F)',
                    '${candle.temperatureDetail!.pouringF}°F',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Ambient Temp (C)',
                    '${candle.temperatureDetail!.ambientTempC}°C',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Ambient Temp (F)',
                    '${candle.temperatureDetail!.ambientTempF}°F',
                    textTheme,
                  ),
                ],
                if (candle.coolingCuringDetail != null) ...[
                  Text('Cooling/Curing Detail', style: textTheme.titleMedium),
                  _buildDetailRow(
                    'Cool Down Time',
                    '${candle.coolingCuringDetail!.coolDownTime}h',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Curing Days',
                    candle.coolingCuringDetail!.curingDays.toString(),
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Burning Day',
                    candle.coolingCuringDetail!.burningDay != null
                        ? DateFormat(
                            'MMM d, yyyy',
                          ).format(candle.coolingCuringDetail!.burningDay!)
                        : 'N/A',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Reminder Time',
                    candle.coolingCuringDetail!.reminderTime?.format(context) ??
                        'N/A',
                    textTheme,
                  ),
                ],
                if (candle.flameRecord != null) ...[
                  Text('Flame Record', style: textTheme.titleMedium),
                  ...candle.flameRecord!.flameSizes.entries.map(
                    (e) => _buildDetailRow(
                      'Flame Size at ${e.key}h',
                      e.value,
                      textTheme,
                    ),
                  ),
                  _buildDetailRow(
                    'Flickering',
                    candle.flameRecord!.flickering.toString(),
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Mushrooming',
                    candle.flameRecord!.mushrooming.toString(),
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Sooting',
                    candle.flameRecord!.sooting.toString(),
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Full Burning Time',
                    candle.flameRecord!.fullBurningTime?.inHours.toString() ??
                        'N/A',
                    textTheme,
                  ),
                  _buildDetailRow(
                    'Records',
                    candle.flameRecord!.records,
                    textTheme,
                  ),
                  if (candle.flameRecord!.scentThrow != null) ...[
                    Text('Scent Throw', style: textTheme.titleMedium),
                    _buildDetailRow(
                      'Cold Throw',
                      candle.flameRecord!.scentThrow!.coldThrow,
                      textTheme,
                    ),
                    ...candle.flameRecord!.scentThrow!.hotThrow.entries.map(
                      (e) => _buildDetailRow(
                        'Hot Throw at ${e.key}m',
                        e.value,
                        textTheme,
                      ),
                    ),
                  ],
                  if (candle.flameRecord!.meltMeasures.isNotEmpty)
                    ...candle.flameRecord!.meltMeasures.asMap().entries.map(
                      (e) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Melt Measure ${e.key + 1}',
                            style: textTheme.titleMedium,
                          ),
                          _buildDetailRow(
                            'Time',
                            '${e.value.time}h',
                            textTheme,
                          ),
                          _buildDetailRow(
                            'Melt Diameter',
                            '${e.value.meltDiameter}mm',
                            textTheme,
                          ),
                          _buildDetailRow(
                            'Melt Depth',
                            '${e.value.meltDepth}mm',
                            textTheme,
                          ),
                          _buildDetailRow(
                            'Full Melt',
                            '${(e.value.fullMelt * 100).toStringAsFixed(2)}%',
                            textTheme,
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final dateFormatter = DateFormat('MMM d, yyyy');
    final timeFormatter = DateFormat('HH:mm');
    final formattedDate = dateFormatter.format(now);
    final formattedTime = timeFormatter.format(now);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: const Text(
          'Analysis Charts',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
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
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: textTheme.bodyMedium?.copyWith(
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
      drawer: const CustomDrawer(currentRoute: '/analysis'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Candle Type Filter
                    Text('Candle Type', style: textTheme.titleLarge),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      children: _candleTypes
                          .map(
                            (type) => ChoiceChip(
                              label: Text(type),
                              selected: _selectedType == type,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedType = selected ? type : null;
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: colorScheme.primary,
                              labelStyle: TextStyle(
                                color: _selectedType == type
                                    ? Colors.white
                                    : colorScheme.onSurface,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16.0),
                    // Melt Filter
                    Text('Melt Percentage', style: textTheme.titleLarge),
                    Slider(
                      value: _meltPercentage,
                      min: 0.0,
                      max: 100.0,
                      divisions: 100,
                      label: '${_meltPercentage.toStringAsFixed(0)}%',
                      onChanged: (value) =>
                          setState(() => _meltPercentage = value),
                      activeColor: colorScheme.primary,
                    ),
                    Text('Melt Time (Hours)', style: textTheme.titleLarge),
                    Slider(
                      value: _meltTime,
                      min: 0.0,
                      max: 4.0,
                      divisions: 8,
                      label: '${_meltTime.toStringAsFixed(1)}h',
                      onChanged: (value) => setState(() => _meltTime = value),
                      activeColor: colorScheme.primary,
                    ),
                    const SizedBox(height: 16.0),
                    // Melt Depth Filter
                    Text('Melt Depth (mm)', style: textTheme.titleLarge),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => setState(() {
                            if (_meltDepth > 0) _meltDepth -= 1;
                          }),
                        ),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter melt depth',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            controller: TextEditingController(
                              text: _meltDepth.toStringAsFixed(1),
                            ),
                            onChanged: (value) {
                              final parsed = double.tryParse(value);
                              if (parsed != null && parsed >= 0) {
                                setState(() => _meltDepth = parsed);
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() => _meltDepth += 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    // Scent Throw Filter
                    Text(
                      'Scent Throw Distance (m)',
                      style: textTheme.titleLarge,
                    ),
                    Slider(
                      value: _scentDistance,
                      min: 0.0,
                      max: 5.0,
                      divisions: 50,
                      label: '${_scentDistance.toStringAsFixed(1)}m',
                      onChanged: (value) =>
                          setState(() => _scentDistance = value),
                      activeColor: colorScheme.primary,
                    ),
                    Text('Scent Throw', style: textTheme.titleLarge),
                    Wrap(
                      spacing: 8.0,
                      children: _scentThrowOptions
                          .map(
                            (throwType) => ChoiceChip(
                              label: Text(throwType),
                              selected: _scentThrow == throwType,
                              onSelected: (selected) {
                                setState(() {
                                  _scentThrow = selected ? throwType : null;
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: colorScheme.primary,
                              labelStyle: TextStyle(
                                color: _scentThrow == throwType
                                    ? Colors.white
                                    : colorScheme.onSurface,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16.0),
                    // Size Filter
                    Text('Size Category', style: textTheme.titleLarge),
                    Wrap(
                      spacing: 8.0,
                      children: _sizeCategories
                          .map(
                            (category) => ChoiceChip(
                              label: Text(category),
                              selected: _sizeCategory == category,
                              onSelected: (selected) {
                                setState(() {
                                  _sizeCategory = selected ? category : null;
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: colorScheme.primary,
                              labelStyle: TextStyle(
                                color: _sizeCategory == category
                                    ? Colors.white
                                    : colorScheme.onSurface,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16.0),
                    // Filtered Candles List
                    StreamBuilder<List<CandleData>>(
                      stream: _firestoreService.getFilteredCandles(
                        userId: user?.uid ?? '',
                        candleType: _selectedType,
                        // Only apply flame-related filters if flameRecord exists
                        meltPercentage: _meltPercentage > 0
                            ? _meltPercentage
                            : null,
                        meltTime: _meltTime > 0 ? _meltTime : null,
                        meltDepth: _meltDepth > 0 ? _meltDepth : null,
                        scentDistance: _scentDistance > 0 && _scentThrow != null
                            ? _scentDistance
                            : null,
                        scentThrow: _scentDistance > 0 && _scentThrow != null
                            ? _scentThrow
                            : null,
                        sizeCategory: _sizeCategory,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: textTheme.bodyLarge,
                            ),
                          );
                        }
                        final candles = snapshot.data ?? [];
                        if (candles.isEmpty) {
                          return Center(
                            child: Text(
                              'No candles match the selected filters.',
                              style: textTheme.bodyLarge,
                            ),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: candles.length,
                          itemBuilder: (context, index) {
                            final candle = candles[index];
                            return Card(
                              color: const Color(0xFFF9F1E7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 4.0,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(
                                  candle.sampleName ?? 'Unnamed Sample',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF5D4037),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Type: ${candle.candleType ?? 'N/A'}'),
                                    Text(
                                      'Cost: \$${candle.totalCost?.toStringAsFixed(2) ?? 'N/A'}',
                                    ),
                                    Text(
                                      'Created: ${candle.createdAt != null ? DateFormat('MMM d, yyyy').format(candle.createdAt!) : 'N/A'}',
                                    ),
                                  ],
                                ),
                                onTap: () =>
                                    _showCandleDetails(context, candle),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
