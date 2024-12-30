import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_champ/components/navbar_widget.dart';
import 'package:task_champ/firebase_options.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'index.dart';
import 'package:flutter/services.dart';
import 'package:task_champ/controllers/health_data_controller.dart';
import 'package:task_champ/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Notification Service
  await NotificationService().init();

  // Register HealthDataController before running the app
  Get.put(HealthDataController());

  // Set edge-to-edge configuration
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparent status bar
    systemNavigationBarColor: Colors.transparent, // Transparent navigation bar
    statusBarIconBrightness: Brightness.dark, // Dark status bar icons
    systemNavigationBarIconBrightness:
        Brightness.dark, // Dark navigation bar icons
  ));

  // Enable edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  // Global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    print('Caught Flutter Framework Error: ${details.exception}');
    print('Stack Trace: ${details.stack}');

    // Optional: Log to a crash reporting service
    // FirebaseCrashlytics.instance.recordFlutterError(details);
  };

  // Catch any errors outside of the Flutter framework
  runZonedGuarded(() async {
    await FlutterFlowTheme.initialize();

    runApp(GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyApp(),
    ));
  }, (error, stackTrace) {
    // Catch any unhandled errors
    print('Uncaught error: $error');
    print('Stack trace: $stackTrace');

    // Optional: Log to a crash reporting service
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

Future<void> _checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (isLoggedIn) {
    Get.offAll(() => NavBarPage(initialPage: 'HomePage'));
  }
  await Future.delayed(const Duration(seconds: 1));
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _checkLoginStatus();
    _router = createRouter(_appStateNotifier);
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TaskChamp',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
        appBarTheme: AppBarTheme(
          // Remove default padding and make it edge-to-edge
          toolbarHeight: kToolbarHeight,
          titleSpacing: 0,
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
        appBarTheme: AppBarTheme(
          // Remove default padding and make it edge-to-edge
          toolbarHeight: kToolbarHeight,
          titleSpacing: 0,
          centerTitle: true,
        ),
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
