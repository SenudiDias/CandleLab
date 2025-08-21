import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupNotificationListener(); // Set up listener immediately
    NotificationService.startNotificationWatcher(context); // Start watcher
  }

  void _setupNotificationListener() {
    final navigatorContext = _navigatorKey.currentContext;
    if (navigatorContext != null) {
      print('Notification listener set up with navigator context');
      NotificationService.checkAndTriggerInAppNotificationWithContext(
        navigatorContext,
      );
    } else {
      print('Navigator context not ready, scheduling retry');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setupNotificationListener();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App resumed, refreshing notification listener');
      _setupNotificationListener();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NotificationService.disposeNotificationService();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Candle Lab',
      builder: (context, child) {
        return Overlay(
          key: _overlayKey,
          initialEntries: [OverlayEntry(builder: (_) => child!)],
        );
      },
      theme: ThemeData(
        fontFamily: 'ThSarabunNew',
        scaffoldBackgroundColor: const Color(0xFFF5F5DC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF795548),
          primary: const Color(0xFF795548),
          secondary: const Color(0xFF5D4037),
          background: const Color(0xFFF5F5DC),
          surface: const Color(0xFFF9F1E7),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: const Color(0xFF5D4037),
          onSurface: const Color(0xFF5D4037),
          error: Colors.redAccent,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF795548),
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: TextStyle(
            fontFamily: 'ThSarabunNew',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFF795548), width: 2.0),
          ),
          labelStyle: const TextStyle(color: Color(0xFF5D4037), fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF795548),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 14.0,
            ),
            textStyle: const TextStyle(
              fontFamily: 'ThSarabunNew',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D4037),
          ),
          titleMedium: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D4037),
          ),
          bodyLarge: TextStyle(fontSize: 14.0, color: Color(0xFF5D4037)),
          bodyMedium: TextStyle(fontSize: 12.0, color: Color(0xFF5D4037)),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return MyHomeScreen(user: snapshot.data);
        },
      ),
    );
  }
}

class MyHomeScreen extends StatefulWidget {
  final User? user;

  const MyHomeScreen({super.key, required this.user});

  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Listener setup handled by _MyAppState
  }

  @override
  Widget build(BuildContext context) {
    return widget.user != null ? const HomeScreen() : const LoginScreen();
  }
}
