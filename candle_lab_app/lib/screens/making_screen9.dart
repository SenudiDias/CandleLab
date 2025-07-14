import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'custom_drawer.dart';
import '../models/candle_data.dart';
import '../services/notification_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class MakingScreen9 extends StatefulWidget {
  final CandleData candleData;

  const MakingScreen9({super.key, required this.candleData});

  @override
  State<MakingScreen9> createState() => _MakingScreen9State();
}

class _MakingScreen9State extends State<MakingScreen9> {
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF795548),
        title: const Text(
          'Making - Batch Output',
          style: TextStyle(fontFamily: 'Georgia', color: Colors.white),
        ),
        leading: Builder(
          builder: (context) => StreamBuilder<int>(
            stream: NotificationService.unreadCountStream,
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
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
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
                      'Sample: ${widget.candleData.sampleName ?? "Unknown"}',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Candle Type: ${widget.candleData.candleType ?? "Unknown"}',
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
                'Cost Breakdown (Per Candle)',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wax Cost
                      _buildCostRow(
                        label: 'Wax Cost',
                        cost: widget.candleData.waxDetails.fold(
                          0.0,
                          (sum, wax) =>
                              sum +
                              (wax.cost /
                                  (widget.candleData.candleType == 'Container'
                                      ? (widget
                                                .candleData
                                                .containerDetail
                                                ?.numberOfContainers ??
                                            1)
                                      : widget.candleData.candleType == 'Pillar'
                                      ? (widget
                                                .candleData
                                                .pillarDetail
                                                ?.numberOfPillars ??
                                            1)
                                      : widget.candleData.candleType == 'Mould'
                                      ? (widget
                                                .candleData
                                                .mouldDetail
                                                ?.number ??
                                            1)
                                      : 1)),
                        ),
                      ),
                      // Container Cost
                      if (widget.candleData.candleType == 'Container' &&
                          widget.candleData.containerDetail != null)
                        _buildCostRow(
                          label: 'Container Cost',
                          cost:
                              widget.candleData.containerDetail!.cost /
                              (widget
                                          .candleData
                                          .containerDetail!
                                          .numberOfContainers >
                                      0
                                  ? widget
                                        .candleData
                                        .containerDetail!
                                        .numberOfContainers
                                  : 1),
                        ),
                      // Wick and Wick Sticker Costs
                      if ((widget.candleData.isWicked == true ||
                              widget.candleData.candleType == 'Container' ||
                              widget.candleData.candleType == 'Pillar') &&
                          widget.candleData.wickDetail != null) ...[
                        _buildCostRow(
                          label: 'Wick Cost',
                          cost:
                              widget.candleData.wickDetail!.wickCost /
                              (widget.candleData.candleType == 'Container'
                                  ? (widget
                                            .candleData
                                            .containerDetail
                                            ?.numberOfContainers ??
                                        1)
                                  : widget.candleData.candleType == 'Pillar'
                                  ? (widget
                                            .candleData
                                            .pillarDetail
                                            ?.numberOfPillars ??
                                        1)
                                  : widget.candleData.candleType == 'Mould'
                                  ? (widget.candleData.mouldDetail?.number ?? 1)
                                  : 1),
                        ),
                        _buildCostRow(
                          label: 'Wick Sticker Cost',
                          cost:
                              widget.candleData.wickDetail!.stickerCost /
                              (widget.candleData.candleType == 'Container'
                                  ? (widget
                                            .candleData
                                            .containerDetail
                                            ?.numberOfContainers ??
                                        1)
                                  : widget.candleData.candleType == 'Pillar'
                                  ? (widget
                                            .candleData
                                            .pillarDetail
                                            ?.numberOfPillars ??
                                        1)
                                  : widget.candleData.candleType == 'Mould'
                                  ? (widget.candleData.mouldDetail?.number ?? 1)
                                  : 1),
                        ),
                      ],
                      // Fragrance Cost
                      if (widget.candleData.isScented &&
                          widget.candleData.scentDetail != null)
                        _buildCostRow(
                          label: 'Fragrance Cost',
                          cost:
                              widget.candleData.scentDetail!.cost /
                              (widget.candleData.candleType == 'Container'
                                  ? (widget
                                            .candleData
                                            .containerDetail
                                            ?.numberOfContainers ??
                                        1)
                                  : widget.candleData.candleType == 'Pillar'
                                  ? (widget
                                            .candleData
                                            .pillarDetail
                                            ?.numberOfPillars ??
                                        1)
                                  : widget.candleData.candleType == 'Mould'
                                  ? (widget.candleData.mouldDetail?.number ?? 1)
                                  : 1),
                        ),
                      // Colour Cost
                      if (widget.candleData.isColoured &&
                          widget.candleData.colourDetail != null)
                        _buildCostRow(
                          label: 'Colour Cost',
                          cost:
                              widget.candleData.colourDetail!.cost /
                              (widget.candleData.candleType == 'Container'
                                  ? (widget
                                            .candleData
                                            .containerDetail
                                            ?.numberOfContainers ??
                                        1)
                                  : widget.candleData.candleType == 'Pillar'
                                  ? (widget
                                            .candleData
                                            .pillarDetail
                                            ?.numberOfPillars ??
                                        1)
                                  : widget.candleData.candleType == 'Mould'
                                  ? (widget.candleData.mouldDetail?.number ?? 1)
                                  : 1),
                        ),
                      // Divider
                      const Divider(height: 20.0, thickness: 1.0),
                      // Total Cost
                      _buildCostRow(
                        label: 'Total Cost',
                        cost: widget.candleData.totalCost ?? 0.0,
                        isTotal: true,
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF795548),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text(
                        'Done',
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
    );
  }

  Widget _buildCostRow({
    required String label,
    required double cost,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              fontFamily: 'Georgia',
              color: const Color(0xFF5D4037),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${cost.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16.0,
              fontFamily: 'Georgia',
              color: const Color(0xFF5D4037),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
