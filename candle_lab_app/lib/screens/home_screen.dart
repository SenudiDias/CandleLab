import 'package:flutter/material.dart';
import 'custom_drawer.dart';
import 'making_screen.dart';
import 'flame_day_screen.dart';
import 'analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isContentVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isContentVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Candle Lab',
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: colorScheme.onPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const CustomDrawer(currentRoute: '/home'),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: AnimatedOpacity(
            opacity: _isContentVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MakingScreen(),
                      ),
                    );
                  },
                  style: Theme.of(context).elevatedButtonTheme.style,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: colorScheme.onPrimary,
                        size: 20.0,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'Making',
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FlameDayScreen(),
                      ),
                    );
                  },
                  style: Theme.of(context).elevatedButtonTheme.style,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: colorScheme.onPrimary,
                        size: 20.0,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'Flame Day',
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalysisScreen(),
                      ),
                    );
                  },
                  style: Theme.of(context).elevatedButtonTheme.style,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart,
                        color: colorScheme.onPrimary,
                        size: 20.0,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'Analysis Charts',
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
