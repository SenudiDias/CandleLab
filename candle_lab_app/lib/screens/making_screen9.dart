import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'custom_drawer.dart';
import '../models/candle_data.dart';
import '../services/notification_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'dart:async';

class MakingScreen9 extends StatefulWidget {
  final CandleData candleData;

  const MakingScreen9({super.key, required this.candleData});

  @override
  State<MakingScreen9> createState() => _MakingScreen9State();
}

class _MakingScreen9State extends State<MakingScreen9> {
  bool _isContentVisible = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isContentVisible = true;
        });
      }
    });
  }

  Stream<DateTime> _dateTimeStream() async* {
    while (true) {
      yield DateTime.now();
      await Future.delayed(const Duration(minutes: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Making - Batch Output'),
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
                            fontSize: 10,
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
                        'Sample Name: ${widget.candleData.sampleName ?? "N/A"}',
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Candle Type: ${widget.candleData.candleType ?? "N/A"}',
                        style: textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                _buildOutputCard(),

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
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: const Text('Done'),
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

  Widget _buildOutputCard() {
    int numberOfCandles = 1;
    final candleType = widget.candleData.candleType;
    if (candleType == 'Container') {
      numberOfCandles =
          widget.candleData.containerDetail?.numberOfContainers ?? 1;
    } else if (candleType == 'Pillar') {
      numberOfCandles = widget.candleData.pillarDetail?.numberOfPillars ?? 1;
    } else if (candleType == 'Mould') {
      numberOfCandles = widget.candleData.mouldDetail?.number ?? 1;
    }
    if (numberOfCandles == 0) numberOfCandles = 1; // Avoid division by zero

    return _buildFormCard(
      title: 'Cost Breakdown (Per Candle)',
      child: Column(
        children: [
          _buildCostRow(
            label: 'Wax Cost',
            cost:
                widget.candleData.waxDetails.fold(
                  0.0,
                  (sum, wax) => sum + wax.cost,
                ) /
                numberOfCandles,
          ),
          if (widget.candleData.containerDetail != null)
            _buildCostRow(
              label: 'Container Cost',
              cost: widget.candleData.containerDetail!.cost / numberOfCandles,
            ),
          if (widget.candleData.wickDetail != null) ...[
            _buildCostRow(
              label: 'Wick Cost',
              cost: widget.candleData.wickDetail!.wickCost / numberOfCandles,
            ),
            _buildCostRow(
              label: 'Wick Sticker Cost',
              cost: widget.candleData.wickDetail!.stickerCost / numberOfCandles,
            ),
          ],
          if (widget.candleData.scentDetail != null)
            _buildCostRow(
              label: 'Fragrance Cost',
              cost: widget.candleData.scentDetail!.cost / numberOfCandles,
            ),
          if (widget.candleData.colourDetail != null)
            _buildCostRow(
              label: 'Colour Cost',
              cost: widget.candleData.colourDetail!.cost / numberOfCandles,
            ),
          const Divider(height: 20.0, thickness: 1.0),
          _buildCostRow(
            label: 'Total Cost',
            cost: (widget.candleData.totalCost ?? 0.0) / numberOfCandles,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow({
    required String label,
    required double cost,
    bool isTotal = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal ? textTheme.titleMedium : textTheme.bodyLarge,
          ),
          Text(
            '\$${cost.toStringAsFixed(2)}',
            style: isTotal ? textTheme.titleMedium : textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
