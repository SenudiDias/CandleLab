import 'package:flutter/material.dart';
import '../models/candle_data.dart';

class MakingScreen4 extends StatelessWidget {
  final CandleData candleData;

  const MakingScreen4({super.key, required this.candleData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Making - Final Step',
          style: TextStyle(fontFamily: 'Georgia', color: Colors.white),
        ),
        backgroundColor: const Color(0xFF795548),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color(0xFFF5F5DC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF795548),
                size: 100.0,
              ),
              const SizedBox(height: 24.0),
              const Text(
                'You\'ve reached the final step!',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                  color: Color(0xFF5D4037),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12.0),
              Text(
                'Sample: ${candleData.sampleName}\nCandle Type: ${candleData.candleType}',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Georgia',
                  color: Color(0xFF5D4037),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF795548),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 12.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Back to Edit',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Georgia',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
