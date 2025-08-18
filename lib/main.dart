import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_module.dart';
import 'app_widget.dart';
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
  
  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
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
  // Prefer compile-time defines (e.g., injected by CI/CD) and fallback to .env
  final url = const String.fromEnvironment('SUPABASE_URL',
      defaultValue: '')
    .isNotEmpty
      ? const String.fromEnvironment('SUPABASE_URL')
      : (dotenv.env['SUPABASE_URL'] ?? '');
  final anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY',
      defaultValue: '')
    .isNotEmpty
      ? const String.fromEnvironment('SUPABASE_ANON_KEY')
      : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');

  if (url.isEmpty || anonKey.isEmpty) {
    if (kDebugMode) {
      debugPrint('⚠️ Supabase credentials not provided (env or defines)');
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


