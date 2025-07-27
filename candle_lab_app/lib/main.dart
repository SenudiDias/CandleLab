import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Candle Lab',
      theme: ThemeData(
        // 1. Set the default font family for the entire app.
        // Make sure the name matches the 'family' you defined in pubspec.yaml.
        fontFamily: 'ThSarabunNew',

        // 2. Set the background color.
        scaffoldBackgroundColor: const Color(0xFFF5F5DC), // Beige
        // 3. Define a consistent color scheme based on the brown shades.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF795548), // Brown
          primary: const Color(0xFF795548), // Main interactive color
          secondary: const Color(0xFF5D4037), // Darker brown for text/elements
          background: const Color(0xFFF5F5DC), // Beige
          surface: const Color(0xFFF9F1E7), // Card/dialog backgrounds
          onPrimary: Colors.white, // Text/icons on primary color
          onSecondary: Colors.white, // Text/icons on secondary color
          onBackground: const Color(0xFF5D4037), // Text on beige background
          onSurface: const Color(0xFF5D4037), // Text on cards/dialogs
          error: Colors.redAccent,
          onError: Colors.white,
        ),

        // 4. Define a global style for AppBars.
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF795548), // Brown
          foregroundColor: Colors.white, // For title, icons
          elevation: 2,
          titleTextStyle: TextStyle(
            fontFamily: 'ThSarabunNew',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        // 5. Define a global style for TextFormFields and Dropdowns.
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

        // 6. Define a global style for ElevatedButtons.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF795548), // Primary brown
            foregroundColor: Colors.white, // Text color
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

        // 7. Define default text styles.
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D4037),
          ),
          titleMedium: TextStyle(
            fontSize: 18.0,
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
          // If user is logged in, go to HomeScreen; otherwise, LoginScreen
          return snapshot.hasData ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
