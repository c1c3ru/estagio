import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_module.dart';
import 'core/theme/theme_service.dart';
import 'core/utils/module_guard.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await _initializeServices();
  
  runApp(ModularApp(module: AppModule(), child: const MyApp()));
}

Future<void> _initializeServices() async {
  final moduleGuard = ModuleGuard();
  
  // Load environment variables
  await _loadEnvironmentVariables();
  
  // Initialize external services with protection
  await Future.wait([
    moduleGuard.executeServiceOnce('supabase', _initializeSupabase),
    moduleGuard.executeServiceOnce('firebase', _initializeFirebase),
    moduleGuard.executeServiceOnce('theme_service', _initializeTheme),
  ]);
}

Future<void> _loadEnvironmentVariables() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ .env file not found, using default values');
    }
  }
}

Future<void> _initializeSupabase() async {
  final url = dotenv.env['SUPABASE_URL'];
  final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
  
  if (url == null || anonKey == null) {
    if (kDebugMode) {
      debugPrint('⚠️ Supabase credentials not found in .env');
    }
    return;
  }
  
  await Supabase.initialize(url: url, anonKey: anonKey);
  if (kDebugMode) {
    debugPrint('✅ Supabase initialized successfully');
  }
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      debugPrint('✅ Firebase initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Firebase initialization failed: $e');
    }
  }
}

Future<void> _initializeTheme() async {
  try {
    await ThemeService().initialize();
    if (kDebugMode) {
      debugPrint('✅ Theme service initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Theme service initialization failed: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sistema de Estágio',
      theme: _buildTheme(),
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
      debugShowCheckedModeBanner: false,
    );
  }
  
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
    );
  }
}
