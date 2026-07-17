import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/language_provider.dart';
import 'firebase_options.dart';
import 'home_screen.dart';
import 'information_tools_screen.dart';
import 'map_tools_screen.dart';
import 'meet_in_middle_screen.dart';
import 'level_meter_screen.dart';
import 'oxygen_level_screen.dart';
import 'voice_navigation_screen.dart';
import 'parking_screen.dart';
import 'altitude_screen.dart';
import 'cameras_screen.dart';
import 'world_clock_screen.dart';
import 'spalsh/calculation_screen.dart';
import 'nearby_places_screen.dart';
import 'spalsh/spalsh_screen.dart';
import 'saved_parkings_screen.dart';
import 'street_view_screen.dart';
import 'live_stream_player_screen.dart';
import 'asia_screen.dart';
import 'countries_info_screen.dart';
import 'settings_screen.dart';
import 'feedback_screen.dart';
import 'live_sensor_screen.dart';
import 'speedometer_screen.dart';
import 'compass_screen.dart';
import 'live_weather_screen.dart';
import 'gps_camera_screen.dart';
import 'find_distance_screen.dart';
import 'globe_screen.dart';
import 'earth_map_screen.dart';
import 'traffic_finder_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase successfully connected and initialized!");
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = ref.watch(languageProvider);

    return MaterialApp(
      title: 'Explore Earth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      locale: Locale(langCode),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('es'),
        Locale('fr'),
        Locale('de'),
        Locale('ur'),
        Locale('hi'),
      ],
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/information_tools': (context) => const InformationToolsScreen(),
        '/map_tools': (context) => const MapToolsScreen(),
        '/meet_in_middle': (context) => const MeetInMiddleScreen(),
        '/level_meter': (context) => const LevelMeterScreen(),
        '/oxygen_level': (context) => const OxygenLevelScreen(),
        '/voice_navigation': (context) => const VoiceNavigationScreen(),
        '/parking': (context) => const ParkingScreen(),
        '/altitude_finder': (context) => const AltitudeScreen(),
        '/cameras': (context) => const CamerasScreen(),
        '/world_clock': (context) => const WorldClockScreen(),
        '/calculation_tools': (context) => const CalculationToolsScreen(),
        '/nearby_places': (context) => const NearbyPlacesScreen(),
        '/saved_parkings': (context) => const SavedParkingsScreen(),
        '/street_view': (context) => const StreetViewScreen(),
        '/live_stream_player': (context) => const LiveStreamPlayerScreen(),
        '/asia': (context) => const AsiaScreen(),
        '/countries_info': (context) => const CountriesInfoScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/feedback': (context) => const FeedbackScreen(),
        '/live_sensor': (context) => const LiveSensorScreen(),
        '/speedometer': (context) => const SpeedometerScreen(),
        '/compass': (context) => const CompassScreen(),
        '/live_weather': (context) => const LiveWeatherScreen(),
        '/gps_camera': (context) => const GPSCameraScreen(),
        '/find_distance': (context) => const FindDistanceScreen(),
        '/globe': (context) => const GlobeScreen(),
        '/earth_map': (context) => const EarthMapScreen(),
        '/traffic_finder': (context) => const TrafficFinderScreen(),
      },
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
          children: [
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
      ),
    );
  }
}
